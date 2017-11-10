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
 
module base_aburp#
  (   parameter width=1,
      parameter del_width=0
   )
  (
   input 	      clk, 
   input 	      reset,
   input 	      i_v,
   input [0:(width+del_width)-1]  i_d,
   output 	      i_r,
   output 	      o_v,
   output [0:(width+del_width)-1] o_d,
   input 	      o_r
   );

   wire 	      burp_v;
   base_aburp_ctrl ictrl(.clk(clk),.reset(reset),.din_v(i_v),.din_r(i_r),.dout_v(o_v),.dout_r(o_r),.burp_v(burp_v));
   generate
      if (width > 0)
	base_aburp_data#(.width(width)) idta(.clk(clk),.din(i_d[0:width-1]),.dout(o_d[0:width-1]),.burp_v(burp_v));
      if (del_width > 0) 
	begin
	   wire burp_vd;
	   base_vlat#(.width(1)) ivdlat(.clk(clk),.reset(reset),.din(burp_v),.q(burp_vd));
	   base_aburp_data#(.width(del_width)) idta(.clk(clk),.din(i_d[width:width+del_width-1]),.dout(o_d[width:width+del_width-1]),.burp_v(burp_vd));
	end
   endgenerate
endmodule // base_burp

   
	     
	 
   
   

