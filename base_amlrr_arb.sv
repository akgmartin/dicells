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
 
// mutli-level round-robin arbiter.
// constructs a round-robin arbiter, which might be pipelined over several cycles to achieve timing for the
// requested number of ways.     This isn't quite right, but works for the values for which we use it.  One day
// I need to come back to this
 module base_amlrr_arb#
  (parameter width = 1,
   parameter stages = 1,
   parameter stage_ways = 1,
   parameter ways = 1
   )
   (input clk,
    input 		     reset,
    output [0:ways-1] 	     i_r,
    input [0:ways-1] 	     i_v,
    input [0:ways-1] 	     i_h,
    input [0:(ways*width)-1] i_d,

    input 		     o_r,
    output 		     o_v,
    output 		     o_h,
    output [0:width-1] 	     o_d
    );

   wire [0:stage_ways-1]     s1_v, s1_r, s1_h;
   wire [0:(stage_ways * width)-1] s1_d;
   wire 			   s2_r, s2_v, s2_h;
   wire [0:stage_ways-1] 	   s2_s;
   wire [0:width-1] 		   s2_d;

   localparam sub_ways = (ways+stage_ways-1)/stage_ways;
   generate
      if (stages <= 1)
	begin
	   assign i_r = s1_r[0:ways-1];
	   assign s1_v[0:ways-1] = i_v;
	   assign s1_d[0:(width*ways)-1] = i_d;
	   assign s1_h[0:ways-1] = i_h;
           if (ways < stage_ways)
	     begin
		assign s1_v[ways:stage_ways-1] = {stage_ways-ways{1'b0}};
		assign s1_d[ways*width:(stage_ways*width)-1] = {(stage_ways-ways)*width{1'b0}};
		assign s1_h[ways:stage_ways-1] = {stage_ways-ways{1'b0}};
	     end
	end
      else
	begin
	   genvar i;
	   for(i=0; i<stage_ways; i=i+1)
	     begin: g_way
		genvar st;
		for(st=i*sub_ways;st<=(i*sub_ways);st=st+1)
		  begin : g_st
		     genvar max_ed;
		     for(max_ed=(i+1)*sub_ways;max_ed<=(i+1)*sub_ways; max_ed=max_ed+1)
		       begin : g_max_ed
			  genvar ed;
			  for(ed=(max_ed > ways ? ways : max_ed); ed <= (max_ed > ways ? ways : max_ed); ed=ed+1)
			    begin : g_ed
			       if (i * sub_ways < ways)
				 base_amlrr_arb#(.width(width),.stage_ways(stage_ways),.stages(stages-1),.ways(ed-st)) irec
				   (.clk(clk),. reset(reset),
				    .i_v(i_v[st:ed-1]),
				    .i_r(i_r[st:ed-1]),
				    .i_h(i_h[st:ed-1]),
				    .i_d(i_d[(st*width):(ed*width)-1]),
				    .o_r(s1_r[i]),.o_v(s1_v[i]),.o_h(s1_h[i]),.o_d(s1_d[(i*width):((i+1)*width)-1]));
			       else begin
				  assign s1_v[i] = 1'b0;
				  assign s1_h[i] = 1'b0;
				  assign s1_d[i*width:((i+1)*width)-1] = {width{1'b0}};
			       end // else: !ifst
			    end // block: ed
		       end // block: max_ed
		  end // block: st
	     end // block: way
	end // else: !if(stages <= 1)
   endgenerate
   base_arr_arb#(.ways(stage_ways)) iarb
     (.clk(clk),.reset(reset),
      .i_r(s1_r),.i_v(s1_v),.i_h(s1_h),
      .o_r(s2_r),.o_v(s2_v),.o_s(s2_s),.o_h(s2_h));

   base_mux#(.width(width),.ways(stage_ways)) imux
     (.din(s1_d),.sel(s2_s),.dout(s2_d));
   
   base_aburp_latch#(.width(width+1)) iltch
	(.clk(clk), .reset(reset),
	 .i_r(s2_r),.i_v(s2_v),.i_d({s2_h,s2_d}),
	 .o_r(o_r),.o_v(o_v),.o_d({o_h,o_d}));
   
endmodule // base_amlrr_arb
