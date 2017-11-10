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
 
module base_aburp_latch#
  (
   parameter width=1,
   parameter del_width=0
   )
  (
   input 	      clk, reset,
   input 	      i_v,
   input [0:(width+del_width)-1]  i_d,
   output 	      i_r,
   output 	      o_v,
   output [0:(width+del_width)-1] o_d,
   input 	      o_r
   );
   

   wire 	      int_v, int_r;
   wire [0:(width+del_width)-1]   int_d;
   
   
   base_aburp#(.width(width),.del_width(del_width))  ibrp(.clk(clk), .reset(reset), .i_v(i_v), .i_d(i_d), .i_r(i_r), .o_v(int_v), .o_d(int_d), .o_r(int_r));
   base_alatch#(.width(width),.del_width(del_width)) istl(.clk(clk), .reset(reset), .i_v(int_v), .i_d(int_d), .i_r(int_r), .o_v(o_v), .o_d(o_d), .o_r(o_r));

endmodule // base_burp

   
	     
	 
   
   

