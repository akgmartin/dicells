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
 
module base_res_mgr#
  (
   parameter width = 4,
   parameter num_res = 2 ** width
   )
   (
    input 	       clk,
    input 	       reset,
    input 	       i_v,
    output 	       i_r,
    input [0:width-1]  i_d,
    output 	       o_v,
    output [0:width-1] o_d,
    input 	       o_r
    );

   // initialize wthe queue
   wire 	       qi_v, qi_r;
   wire [0:width-1]    qi_d;
   base_initsm#(.COUNT(num_res), .LOG_COUNT(width)) ism(.clk(clk),.reset(reset),.dout_r(qi_r),.dout_v(qi_v), .dout_d(qi_d));

   wire 		 s1_v, s1_r;
   wire [0:width-1] 	 s1_d;
   base_primux#(.ways(2),.width(width)) imux(.i_v({i_v,qi_v}),.i_r({i_r,qi_r}),.i_d({i_d,qi_d}), .o_v(s1_v),.o_r(s1_r),.o_d(s1_d),.o_sel());
   base_fifo#(.DEPTH(num_res), .LOG_DEPTH(width), .width(width)) ififo(.clk(clk),.reset(reset),.i_r(s1_r),.i_v(s1_v),.i_d(s1_d),.o_v(o_v),.o_d(o_d),.o_r(o_r));
endmodule // gx_res_mgr
   
