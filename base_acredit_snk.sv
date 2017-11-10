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
 
module base_acredit_snk#
  (
   parameter credits =  0,
   parameter log_credits = $clog2(credits),
   parameter width = 0,
   parameter dist_ram=0,
   parameter block_ram=0
   )
   (
    input 	       clk,
    input 	       reset,
    output 	       i_c,
    input 	       i_v,
    input [0:width-1]  i_d,
    
    input 	       o_r,
    output 	       o_v,
    output [0:width-1] o_d
    );

   base_fifo#(.width(width),.LOG_DEPTH(log_credits),.DEPTH(credits),.output_reg(1)) i_fifo
     (
      .clk(clk),.reset(reset),
      .i_r(),.i_v(i_v),.i_d(i_d),
      .o_v(o_v),.o_r(o_r),.o_d(o_d)
      );
   base_vlat#(.width(1)) il1(.clk(clk),.reset(reset),.din(o_v&o_r),.q(i_c));
endmodule // base_acredit_snk


    
   
					
   


   
  
