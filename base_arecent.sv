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
 
/* presents the most recent valid value seen on the inputs at the output*/

module base_arecent#(parameter width=1)
   (input clk,
    input 	       reset,

    input 	       i_v,
    input [0:width-1]  i_d,
   
    input 	       o_r,
    output 	       o_v,
    output [0:width-1] o_d
    );

   base_alatch #(.width(1)) ivlat(.clk(clk),.reset(reset),.i_v(i_v),.i_r(),.i_d(1'b0),.o_v(o_v),.o_r(o_r),.o_d());
   base_vlat_en#(.width(width)) idlat(.clk(clk),.reset(reset),.din(i_d),.q(o_d),.enable(i_v));
   
endmodule // base_recent

    
    
