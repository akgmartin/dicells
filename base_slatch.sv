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
 
module base_slatch#
  (
   parameter width=1
   )
  (
   input 			clk, 
   input 			reset,
   output 			i_r,
   input 			i_v,
   input [0:width-1] 	i_d,
   
   input 			o_r,
   output 			o_v,
   output [0:width-1] o_d
   );
   base_vlat_en#(.width(1))        ivlat(.clk(clk), .reset(reset), .din(i_v), .q(o_v),.enable(o_r));
   base_vlat_en#(.width(width))    idlat(.clk(clk), .reset(1'b0),  .din(i_d), .q(o_d),.enable(o_r));
   assign i_r = o_r;
endmodule // base_burp

   
	     
	 
   
   

