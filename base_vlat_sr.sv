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
 
module base_vlat_sr#(parameter width=1,parameter rstv={width{1'b0}})
  (
   input 	      clk,
   input [0:width-1]  set,
   input [0:width-1]  rst,
   input 	      reset,
   output [0:width-1] q
   );
   
   reg [0:width-1]    q_int;
   genvar 	      i;
   generate
      for(i=0; i< width; i=i+1)
	begin : u0
	   always@(posedge clk or posedge reset) 
	     if (reset) q_int[i] <= rstv;
	     else if (set[i] | rst[i]) q_int[i] <= set[i];
	end
   endgenerate
   assign q = q_int;
endmodule // base_vlat_sr


   
  
