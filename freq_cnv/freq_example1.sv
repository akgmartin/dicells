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

/* This is an example showing how to shift from a low frequency clock (clk_lo) to a clock (clk_hi) that is double the frequency (and synchronous with) clk_lo, and back again */
module freq_example1#(parameter width=1)
   (input clk_lo,
    input reset_lo,

    output i_r,
    input  i_v,
    input [width-1:0] i_d0,
    input [width-1:0] i_d1,


    input o_r,
    output o_v,
    output [width-1:0] o_d0,
    output [width-1:0] o_d1

    input clk_hi,
    input reset_hi,
    );


   // example converting to a high (double) frequency domain and then back.
   // the .lbl() parameters to the registers can by anything.  I have chosen 3'b011 arbitrarily

   // sx signals are in the low frequency domain
   wire   s1_v, s1_r;
   wire [width-1:0] s1_d0;
   wire [width-1:0] s1_d1;

   // optional input register (in low frequency domain)
   base_areg#(.lbl(3'b011),.width(width*2)) ireg
     (.clk(clk_lo),.reset(reset_lo),
      .i_v(i_v),.i_r(i_r),.i_d({i_d0,i_d1}),
      .o_v(s1_v),.o_r(s1_r),.o_d({s1_d0,s1_d1})
      );

   // tx signals are in the high frequency domain 
   wire 	    t1_v, t1_r;
   wire [width-1:0] t1_d;
   // convert up to the high frequeny domain 
   base_afreq_up#(.width(width) iup
     (.clk_lo(clk_lo),
      .i_v(s1_v),.i_r(s1_r),.i_d0(s1_d0),.i_d1(s1_d1),
      .o_v(t1_v),.o_r(t1_r),
      .o_d(t1_d)
      );			

   // an example high-freqncy pipeline 
   wire 	    t2_v, t2_r;
   wire [width-1:0] t2_d;
   base_areg#(.lbl(3'b011)).width(width) it2_reg
     (.clk(clk_hi),.reset(reset_hi),
      .i_v(t1_v),.i_r(t1_r),.i_d(t1_d),
      .o_v(t2_v),.o_r(t2_r),.o_d(t2_d));

   wire 	    t3_v, t3_r;
   wire [width-1:0] t3_d;
   base_areg#(.lbl(3'b011)).width(width) it4_reg
     (.clk(clk_hi),.reset(reset_hi),
      .i_v(t2_v),.i_r(t2_r),.i_d(t2_d),
      .o_v(t3_v),.o_r(t3_r),.o_d(t3_d));

   // convert back down to low freqency domain 
   base_afreq_dn idn
     (.clk_hi(clk_hi),.reset_hi(reset_hi),
      .i_v(t3_v),.i_r(t3_r),.i_d(t3_d),

      .clk_lo(clk_lo),.reset_lo(reset_lo),
      .o_v(s2_v),.o_r(s2_r),.o_d0(s2_d0),.o_d1(s2_d1));

   // optional output register (in high frequency domain)
   base_areg#(.lbl(3'b011),.width(2*width)) is3_reg
     (.clk(clk_lo),.reset(reset_lo),
      .i_v(s2_v),.i_r(s2_r),.i_d({s2_d0,s2_d1}),
      .o_v(o_v),.o_r(o_r),.o_d({o_d0,.o_d1}));
endmodule // base_afreq_example

      

   


		    
  
    

    
