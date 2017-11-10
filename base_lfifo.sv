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
 
/* large fifo - allows for adding pipelining latches on sram address and data-paths */
module base_lfifo#
  (
   parameter ramstyle="no_rw_check",
   parameter width=1,
   parameter LOG_DEPTH=1,
   parameter DEPTH = 2 ** LOG_DEPTH,
   parameter adelay = 1,
   parameter ddelay = 1
   )
   (
    input clk,
    input reset,
    input i_v,
    input [width-1:0] i_d,
    output 	     i_r,
		     
    output 	     o_v,
    output [width-1:0] o_d,
    input 	      o_r /* only meaningful when doutv=1.  means that dout will be accepted this cycle.  New data may be presented next cycle */
    );
   
   
   wire 	       empty,empty_in;
   wire 	       full,full_in;

   (* ramstyle = ramstyle *) reg [width-1:0]     ram[DEPTH-1:0];
   reg [width-1:0]     dout_int;

   wire [31:0] 	       onex = 32'h1;
   wire [LOG_DEPTH-1:0] one = onex[LOG_DEPTH-1:0];

   wire [31:0] 		depthm1 = DEPTH-1;
   wire [LOG_DEPTH-1:0] maxptr = depthm1[LOG_DEPTH-1:0];
   
   wire 		wr_en;
   assign wr_en = i_v & ~full;


   wire 		s0_v = ~empty;

   wire                 s1_v;
   wire 		rd_en = s1_v;
   
   wire [0:LOG_DEPTH-1]  din_ptr, din_ptr_in, din_ptr_nxt;
   wire [0:LOG_DEPTH-1]  dout_ptr, dout_ptr_in, dout_ptr_nxt;
   
   
   assign din_ptr_nxt = (din_ptr == maxptr) ?   {LOG_DEPTH{1'b0}} : din_ptr+one;
   assign dout_ptr_nxt = (dout_ptr == maxptr) ? {LOG_DEPTH{1'b0}} : dout_ptr+one;
   
   assign din_ptr_in  = wr_en ? din_ptr_nxt : din_ptr;
   assign dout_ptr_in = rd_en ? dout_ptr_nxt: dout_ptr;

   wire 		 ptrs_eq;
   assign ptrs_eq = (din_ptr_in == dout_ptr_in);
   
   assign empty_in = empty ? ~wr_en : (rd_en & ptrs_eq);
   assign full_in  = full  ? ~rd_en : (wr_en & ptrs_eq);
   
   assign i_r = ~full;

   // pipeline reads and writes
   wire [0:LOG_DEPTH-1]  ra, wa;
   wire 		 re, we;
   base_delay#(.n(adelay),.width(LOG_DEPTH+1)) irdelay(.clk(clk),.reset(reset),.i_d({dout_ptr,rd_en}),.o_d({ra,re}));
   base_delay#(.n(adelay),.width(LOG_DEPTH+1)) iwdelay(.clk(clk),.reset(reset),.i_d({din_ptr,wr_en}),.o_d({wa,we}));


     
   always@(posedge clk) begin
      if (we) ram[wa] <= i_d;
   end
   
   always@(posedge clk) begin
      if (re) dout_int <= ram[ra];
   end

   wire [0:width-1] s2_d = dout_int;

   wire 	    s2_v;
   base_vlat is2_v(.clk(clk),.reset(reset),.din(re),.q(s2_v));

   localparam credits = adelay+ddelay+3;
   
   base_vlat#(.width(1)) ifull(.clk(clk), .reset(reset), .din(full_in), .q(full));
   base_vlat#(.width(1),.rstv(1'b1)) iempty(.clk(clk), .reset(reset), .din(empty_in), .q(empty));
   base_vlat#(.width(LOG_DEPTH)) idinptr(.clk(clk), .reset(reset), .din(din_ptr_in), .q(din_ptr));
   base_vlat#(.width(LOG_DEPTH)) idoutptr(.clk(clk), .reset(reset), .din(dout_ptr_in), .q(dout_ptr));

   wire 	    s1_c;
   base_acredit_src#(.credits(credits)) icrd_src(.clk(clk),.reset(reset),.i_r(),.i_v(s0_v),.o_r(1'b1),.o_v(s1_v),.o_c(s1_c));

   
   wire [0:width-1] s3_d;
   wire 	    s3_v;
   base_delay#(.n(ddelay),.width(width+1)) iddelay(.clk(clk),.reset(reset),.i_d({s2_d,s2_v}),.o_d({s3_d,s3_v}));
   
   base_acredit_snk#(.width(width),.credits(credits)) icrd_snk(.clk(clk),.reset(reset),.i_c(s1_c),.i_v(s3_v),.i_d(s3_d),.o_v(o_v),.o_r(o_r),.o_d(o_d));


endmodule // base_fifo


   
   
      
     

 
   


   
   


		  
  
