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
 
module base_alatch#
  (
   parameter width=1, 
   parameter del_width=0,
   parameter dq=0
   )
  (
   input 	      clk, 
   input 	      reset,
   input 	      i_v,
   input [0:width+del_width-1]  i_d,
   output 	      i_r,
   output 	      o_v,
   output [0:width+del_width-1] o_d,
   input 	      o_r
   );
   
   wire 	      o_v_in = i_v | (o_v & ~o_r);
   wire               enable = o_r | ~o_v;
   assign i_r = o_r | ~o_v;
   
   base_vlat#(.width(1))        ivlat(.clk(clk), .reset(reset), .din(o_v_in), .q(o_v));
   wire [0:width-1]   din;
   generate
      if (dq)
	assign din = i_v ? i_d[0:width-1] : {width{1'b0}};
      else
	assign din = i_d[0:width-1];
   endgenerate
   
   generate
      if (width > 0)
	base_vlat_en#(.width(width)) idlat(.clk(clk), .reset(1'b0), .enable(enable), .din(din), .q(o_d[0:width-1]));
      if (del_width > 0)
	begin
	   wire enable_d;
	   base_vlat#(.width(1))        ielat(.clk(clk), .reset(1'b0), .din(enable), .q(enable_d));
	   base_vlat_en#(.width(del_width)) idlat(.clk(clk), .reset(1'b0), .enable(enable_d), .din(i_d[width:width+del_width-1]), .q(o_d[width:width+del_width-1]));
	end
   endgenerate
endmodule // base_burp

   
	     
	 
   
   

