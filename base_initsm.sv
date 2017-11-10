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
 
module base_initsm#
  (
   parameter LOG_COUNT = 1,
   parameter COUNT = 2 ** LOG_COUNT
   )
   (
    input 		   clk,
    input 		   reset,
    output 		   dout_v,
    output [0:LOG_COUNT-1] dout_d,
    input 		   dout_r
    );
   
   wire [0:LOG_COUNT-1] count_in,count;
   wire 		act_in,act;

   assign act_in = !(count == 0);
   assign count_in = act_in ? count-{{LOG_COUNT-1{1'b0}},1'b1} : {LOG_COUNT{1'b0}};

   wire 		s1_v, s1_r;

   base_alatch#(.width(LOG_COUNT)) is2_lat(.clk(clk),.reset(reset),.i_v(s1_v),.i_r(s1_r),.o_v(dout_v),.o_r(dout_r),.i_d(count),.o_d(dout_d));
   
   wire 		en = ~s1_v | s1_r;
   
   base_vlat_en#(.width(LOG_COUNT),.rstv(COUNT-1)) countl(.clk(clk), .reset(reset), .enable(en),.din(count_in), .q(count));
   base_vlat_en#(.width(1),.rstv(1'b1))              actl(.clk(clk), .reset(reset), .enable(en),.din(act_in), .q(s1_v));

   
endmodule
 
   
   
