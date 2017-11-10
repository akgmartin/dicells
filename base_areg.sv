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
 
module base_areg#(parameter width=1,parameter [0:2] lbl=0, parameter reset_ready=0)
   (input clk,
    input 	       reset,
    output 	       i_r,
    input 	       i_v,
    input [0:width-1]  i_d,

    input 	       o_r,
    output 	       o_v,
    output [0:width-1] o_d);

   // AXI requires ready to go low during reset
   wire                s0_r;
   generate
      if( reset_ready==1'b1 )
        assign i_r = s0_r & ~reset;
      else
        assign i_r = s0_r;
   endgenerate
   
   wire 	       s1_v, s1_r;
   wire [0:width-1]    s1_d;
   
   generate
      if(lbl[0] == 1'b0)
	base_apass#(.width(width)) il0(.clk(clk),.reset(reset),.i_v(i_v),.i_r(s0_r),.i_d(i_d),.o_v(s1_v),.o_r(s1_r),.o_d(s1_d));
      else
	base_alatch#(.width(width)) il0(.clk(clk),.reset(reset),.i_v(i_v),.i_r(s0_r),.i_d(i_d),.o_v(s1_v),.o_r(s1_r),.o_d(s1_d));
   endgenerate

   wire 	       s2_v, s2_r;
   wire [0:width-1]    s2_d;
   generate
      if(lbl[1] == 1'b0)
	base_apass#(.width(width)) il1(.clk(clk),.reset(reset),.i_v(s1_v),.i_r(s1_r),.i_d(s1_d),.o_v(s2_v),.o_r(s2_r),.o_d(s2_d));
      else
	base_aburp#(.width(width)) il1(.clk(clk),.reset(reset),.i_v(s1_v),.i_r(s1_r),.i_d(s1_d),.o_v(s2_v),.o_r(s2_r),.o_d(s2_d));
   endgenerate

   generate
      if(lbl[2] == 1'b0)
	base_apass#(.width(width)) il2(.clk(clk),.reset(reset),.i_v(s2_v),.i_r(s2_r),.i_d(s2_d),.o_v(o_v),.o_r(o_r),.o_d(o_d));
      else
	base_alatch#(.width(width)) il2(.clk(clk),.reset(reset),.i_v(s2_v),.i_r(s2_r),.i_d(s2_d),.o_v(o_v),.o_r(o_r),.o_d(o_d));
   endgenerate
   
endmodule
    
