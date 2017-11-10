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
 
module base_emux_le#
  (
   parameter width = 1,
   parameter ways = 2,
   parameter sel_width=$clog2(ways)
   
   )
  (
   input [(width*ways)-1:0] din,
   input [sel_width-1:0]    sel,
   output [width-1:0]       dout
   );

   wire [width-1:0] 	    din_array [ways-1:0];
   
   assign dout = din_array[sel];

   genvar 		    i;
   generate
      for(i=0; i< ways; i=i+1)
	begin :gen1
	   assign din_array[i] = din[(i+1)*width-1:i*width];
	end
   endgenerate
   
endmodule // base_emux       
