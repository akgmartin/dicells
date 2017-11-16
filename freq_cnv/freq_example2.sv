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

/* This is an example showing how to run a double frequency data pipeline */
module base_afreq_example2#(parameter width=1)
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

   // control running in low frequency domain 
   base_areg#(.lbl(3'b011),.width(width*2)) is1_reg
     (.clk(clk_lo),.reset(reset_lo),
      .i_v(i_v),.i_r(i_r),.i_d({i_d0,i_d1}),
      .o_v(s1_v),.o_r(s1_r),.o_d({s1_d0,s1_d1})
      );

   wire 	    s2_v, s3_r, s3_en;
   base_alatch_oe#(.width(1)) is1_lat
     (.clk(clk_lo),.reset(reset_lo),
      .i_v(s1_v),.i_r(s1_r),.i_d(1'b0),
      .o_v(s2_v),.o_r(s2_r),.o_d(),.o_en(s2_en)
      );

   wire 	    s3_v, s3_r, s3_en;
   base_alatch_oe#(.width(1)) is1_lat
     (.clk(clk_lo),.reset(reset_lo),
      .i_v(s2_v),.i_r(s2_r),.i_d(1'b0),
      .o_v(s3_v),.o_r(s3_r),.o_d(),.o_en(s3_en)
      );

   wire [width-1:0] s3_d0, s3_d1;
   base_areg$(.lbl(3'b011),.width(width*2)) is4_oreg
     (.clk(clk_lo),.reset(reset_lo),
      .i_v(s3_v),.i_r(s3_r),.i_d({s3_d0,s3_d1}),.
      .o_v(o_v),.o_r(o_r),.o_d({o_d0,o_d1}));


   // data path running in the high frequency domain 
   wire [width-1:0] t0_din = clk_lo ? s1_d0 : s1_d1;
   base_vlat_en#(.width(width)) it0_lat(.clk(clk_hi),.reset(1'b0),.din(t0_din),.q(t0_d),.en(s2_en));
   base_vlat_en#(.width(width)) it0_lat(.clk(clk_hi),.reset(1'b0),.din(t0_d),  .q(t1_d),.en(s2_en));
   base_vlat_en#(.width(width)) it0_lat(.clk(clk_hi),.reset(1'b0),.din(t1_d),  .q(t2_d),.en(s3_en));
   base_vlat_en#(.width(width)) it0_lat(.clk(clk_hi),.reset(1'b0),.din(t2_d),  .q(t3_d),.en(s3_en));

   assign s3_d0 = t3_d;
   assign s3_d1 = t2_d;
   
   
endmodule // base_afreq_example

      

   


		    
  
    

    
