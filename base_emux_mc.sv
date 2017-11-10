/*
 * Copyright 2017 IBM Corporation
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Author: Andrew K Martin akmartin@us.ibm.com
 */
 
module base_emux_mc#
  (
   parameter width = 1,
   parameter ways = 2,
   parameter sel_width=$clog2(ways),
   parameter lsel_width = 3,
   parameter aux_width=1
   )
  (
   input 		    clk,
   input 		    reset,
   input [0:aux_width-1]    ain,
   input [0:(width*ways)-1] din,
   input [0:sel_width-1]    sel,
   output [0:width-1] 	    dout,
   output [0:aux_width-1]   aout
   
   );

   // extend select with to a multiple of lsel_width
   
   localparam esel_width = ((sel_width+lsel_width-1)/lsel_width)*lsel_width;
   wire [0:esel_width-1]    esel = sel;

   // extend data to match esel
   localparam 		    eways = 2**esel_width;
   localparam 		    epad = ((eways-ways)*width);

   
   wire [0:width*eways-1]   edin;
   generate
      if (epad == 0)
	assign edin = din;
      else
	assign edin = {din,{epad{1'b0}}};
   endgenerate

   localparam 		    lways = 2**lsel_width;
   wire [0:width-1] 	    s2_d;
   wire [0:aux_width-1]     s2_a;
   
   generate
      if (esel_width <= lsel_width)
	begin
	   // base case, simple mux followed by a register
	   wire [0:width-1] 	    din_array [0:eways-1];
	   assign s2_d = din_array[esel];
	   genvar 		    i;
	   for(i=0; i< eways; i=i+1)
	     begin :gen1
		assign din_array[i] = edin[i*width:(i+1)*width-1];
	     end
	   assign s2_a = ain;
	   base_vlat#(.width(width))     idlat(.clk(clk),.reset(reset),.din(s2_d),.q(dout));
	   base_vlat#(.width(aux_width)) ialat(.clk(clk),.reset(reset),.din(s2_a),.q(aout));
	end
      else
	begin
	   // recursive case, mux followed by mux
	   wire [0:lways*width-1] s1_d;
	   wire [0:lsel_width-1]  s1_s;
	   wire [0:aux_width-1]   s1_a;

	   genvar i;
	   localparam rways = eways/lways;
	   localparam rwidth=rways*width;

	   // itteration 0 of loop - used for aux data
	   base_emux_mc#(.aux_width(lsel_width+aux_width),.width(width),.ways(rways),.sel_width(esel_width-lsel_width),.lsel_width(lsel_width)) imux1
	     (.clk(clk),.reset(reset),
	      .ain({esel[0:lsel_width-1],ain}),.din(edin[0:rwidth-1]),.sel(esel[lsel_width:esel_width-1]),
	      .aout({s1_s,s1_a}),.dout(s1_d[0:width-1]));
	   // remaining itterations - no aux data
	   for(i=1; i<lways; i=i+1)
	     begin : gen2
		base_emux_mc#(.aux_width(1),.width(width),.ways(rways),.sel_width(esel_width-lsel_width),.lsel_width(lsel_width)) imux1
		 (.clk(clk),.reset(reset),.ain(1'b0),.din(edin[i*rwidth:(i+1)*rwidth-1]),.sel(esel[lsel_width:esel_width-1]),.aout(),.dout(s1_d[i*width:(i+1)*width-1]));
	     end
	   base_emux_mc#(.aux_width(aux_width),.width(width),.ways(lways),.sel_width(lsel_width),.lsel_width(lsel_width)) imux2
	     (.clk(clk),.reset(reset),.sel(s1_s),.ain(s1_a),.din(s1_d),.aout(aout),.dout(dout));
	end // else: !if(esel_width <= lsel_width)
   endgenerate
endmodule // base_emux_mc


   
     
   
