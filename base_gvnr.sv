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
 
/* allow at most one transaction every n cycles
 */
 module base_gvnr#
  (
   parameter n=2)
   (input clk,
    input reset,
    output i_r,
    input i_v,
    input o_r,
    output o_v
    );

   generate
      if (n>0) 
	begin :gen1
	   localparam w = $clog2(n-1);
	   
	   wire [0:w-1] cnt, cnt_in;
	   localparam [0:w-1] cnt_max = n-1;
           localparam [0:w-1] cnt_zero=0;
	   localparam [0:w-1] cnt_one=1;
	   assign cnt_in = (cnt == cnt_max) ? cnt_zero : cnt_one;
	   wire 	cnt_zro = ~(|cnt);
	   wire 	cnt_en = ~cnt_zro | (o_r & i_v);
	   base_vlat_en#(.width(w)) icnt_lat(.clk(clk),.reset(reset),.din(cnt_in),.q(cnt),.enable(cnt_en));
	   base_agate igt(.i_v(i_v),.i_r(i_r),.o_v(o_v),.o_r(o_r),.en(cnt_zro));
	end // block: gen1
      else
	begin :gen2
	   assign i_r = o_r;
	   assign o_v = i_v;
	end
      endgenerate
endmodule
   
   

  
