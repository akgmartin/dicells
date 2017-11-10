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
 
// split memory for non power-of-2 rams
module base_smem#
  (
   parameter width = 1,
   parameter addr_width = 1,
   parameter depth = 2 ** addr_width,
   parameter wdelay = 0
   )
   (
   input clk,
   input we,
   input [addr_width-1:0] wa,
   input [width-1:0] 	  wd,
   input re,
   input [addr_width-1:0] ra,
   output [width-1:0] 	  rd
    );
   

   wire 		  we_d;
   wire [addr_width-1:0]  wa_d;
   wire [width-1:0] 	  wd_d;

   base_delay#(.width(1+addr_width+width),.n(wdelay)) idel
     (
      .clk(clk),.reset(1'b0),
      .i_d({we,wa,wd}),
      .o_d({we_d,wa_d,wd_d})
      );

   generate
      if (depth == 2**addr_width || addr_width <= 9)
	base_mem#(.width(width),.addr_width(addr_width),.wdelay(0)) imem(.clk(clk),.we(we_d),.wa(wa_d),.wd(wd_d),.re(re),.ra(ra),.rd(rd));
      else
	begin : gen1
	   localparam awidth = $clog2(depth);
	   localparam depth1 = 2**(awidth-1);
	   localparam depth2 = depth-depth1;
	   localparam addr_width1 = awidth-1;
	   localparam addr_width2 = $clog2(depth2);
	   localparam sel_bit = awidth-1;
	   
	   wire we1 = ~wa_d[sel_bit] & we_d;
	   wire we2  = wa_d[sel_bit] & we_d;
	   wire [0:addr_width1-1] wa1 = wa_d[addr_width1-1:0];
	   wire [0:addr_width2-1] wa2 = wa_d[addr_width2-1:0];

	   wire [0:addr_width1-1] ra1 = ra[addr_width1-1:0];
	   wire [0:addr_width2-1] ra2 = ra[addr_width2-1:0];
	   wire [0:width-1] 	  rd1, rd2;
	   
	   wire r_sel;
	   base_vlat_en#(.width(1)) ird_sel_lat(.clk(clk),.reset(1'b0),.din(ra[sel_bit]),.q(r_sel),.enable(re));
	   base_mem#(.width(width),.addr_width(addr_width1),.depth(depth1),.wdelay(0)) imem1(.clk(clk),.we(we1),.wa(wa1),.wd(wd_d),.re(re),.ra(ra1),.rd(rd1));
	   base_mem#(.width(width),.addr_width(addr_width2),.depth(depth2),.wdelay(0)) imem2(.clk(clk),.we(we2),.wa(wa2),.wd(wd_d),.re(re),.ra(ra2),.rd(rd2));
	   assign rd = r_sel ? rd2 : rd1;
	end // block: gen1
   endgenerate
endmodule // base_smem


   
   
		  
