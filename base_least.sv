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
 
module base_least#
  (parameter ways=1,
   parameter kw=1, // key width
   parameter dw=1, // data width
   parameter aux_width=1
   )
   (input clk,
    input 		   reset,
    output 		   i_r,
    input 		   i_v,
    input [0:aux_width-1]  i_aux,
    input 		   o_r,
    output 		   o_v,
    
    input [0:ways*kw-1]    i_k,
    input [0:ways*dw-1]    i_d,
    input [0:ways-1] 	   i_dv,
    output [0:kw-1] 	   o_k,
    output [0:dw-1] 	   o_d,
    output 		   o_dv,
    output [0:aux_width-1] o_aux
    );

   generate
      if (ways < 2)
	begin : gen1
	   base_alatch#(.width(1+aux_width+kw+dw)) ilat
	     (.clk(clk),.reset(reset),
	      .i_v(i_v),.i_r(i_r),.i_d({i_dv,i_aux,i_k,i_d}),
	      .o_v(o_v),.o_r(o_r),.o_d({o_dv,o_aux,o_k,o_d})
	      );
	end
      else
	begin : gen2
	   localparam w0 = ways/2;
	   localparam w1 = ways-w0;
	   wire [0:kw-1] s1_k0, s1_k1;
	   wire [0:dw-1] s1_d0, s1_d1;
	   wire  	 s1_dv0, s1_dv1;
	   wire 	 s1_v, s1_r;
	   wire [0:aux_width-1] s1_aux;
	   if (ways == 2)
	     begin : gen3
		assign s1_aux = i_aux;
		assign {s1_k0,s1_k1} = i_k;
		assign {s1_d0,s1_d1} = i_d;
		assign {s1_dv0,s1_dv1} = i_dv;
		assign s1_v = i_v;
		assign i_r = s1_r;
	     end
	   else
	     begin : gen4
		wire [0:1] s0_v, s0_r, s1a_v, s1a_r;
		base_acombine#(.ni(1),.no(2)) icmb0(.i_v(i_v),.i_r(i_r),.o_v(s0_v),.o_r(s0_r));
	   	base_least#(.ways(w0),.kw(kw),.dw(dw),.aux_width(aux_width)) i0
		  (.clk(clk),.reset(reset),
		   .i_v(s0_v[0] ), .i_r(s0_r[0]), .i_k(i_k[0:w0*kw-1]),.i_d(i_d[0:w0*dw-1]),.i_dv(i_dv[0:w0-1]),.i_aux(i_aux),
		   .o_v(s1a_v[0]), .o_r(s1a_r[0]),  .o_k(s1_k0),   .o_d(s1_d0),.o_dv(s1_dv0),.o_aux(s1_aux));
		base_least#(.ways(w1),.kw(kw),.dw(dw)) i1
		  (.clk(clk),.reset(reset),
		   .i_v(s0_v[1]),.i_r(s0_r[1]), .i_k(i_k[w0*kw:ways*kw-1]),.i_d(i_d[w0*dw:ways*dw-1]),.i_dv(i_dv[w0:ways-1]),.i_aux(1'b0),
		   .o_v(s1a_v[1]),.o_r(s1a_r[1]), .o_k(s1_k1),   .o_d(s1_d1),.o_dv(s1_dv1),.o_aux());
		base_acombine#(.ni(2),.no(1)) icmb1(.i_v(s1a_v),.i_r(s1a_r),.o_v(s1_v),.o_r(s1_r));
	     end // block: gen4

	   wire s1_sel0 = s1_dv0 & ((s1_k0 < s1_k1) | ~s1_dv1);
	   wire [0:kw-1] s1_k = s1_sel0 ? s1_k0 : s1_k1;
	   wire [0:dw-1] s1_d = s1_sel0 ? s1_d0 : s1_d1;
	   wire 	 s1_dv = s1_dv0 | s1_dv1;
	   base_alatch#(.width(1+aux_width+kw+dw)) is1_lat0
	     (.clk(clk),.reset(reset),
	      .i_v(s1_v),.i_r(s1_r),.i_d({s1_dv,s1_aux,s1_k,s1_d}),
	      .o_v(o_v),.o_r(o_r),.o_d({o_dv,o_aux,o_k,o_d})
	      );
	end // block: gen2
   endgenerate
endmodule // base_least

