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
module base_freq_dn#(parameter width=1)
  (input              clk_hi
   input 	      reset_hi,
   output 	      i_r,
   input 	      i_v,
   input [width-1:0]  i_d,

   input 	      clk_lo
   input 	      o_r,
   output 	      o_v,
   output [width-1:0] o_d0,
   output [width-1:0] o_d1
   );


   assign o_d1 = i_d;
   wire 	      s1_v, s1_r;
   wire [width-1:0]   s1_d;
   base_alatch#(.width(width)) ilat(.clk(clk_hi),.reset(reset_hi),.i_v(i_v),.i_r(i_r),.i_d(i_d),.o_v(s1_v),.o_r(s1_r),.o_d(o_d0));
   wire 	      s1_act = s1_r & s1_v;

   wire 	      s1_phase;
   base_vlat_en#(.width(1)) is1_phase_lat(.clk(clk_hi),.reset(reset_hi),.din(~s1_phsae),.q(s1_phase),.en(s1_act));

   wire 	      s1a_v, s1a_r;
   base_afilter is1_fltr(.i_v(s1_v),.i_r(s1_r),.o_v(s1a_v),.o_r(s1a_r),.en(~s1_phase));
   base_agate   is1_gt(.i_v(s1a_v),.i_r(s1a_r),.o_v(o_v),.o_r(o_r),.en(i_v));
endmodule // base_freq_dn
   

  
