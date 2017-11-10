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
 
module base_sram_cntrs#(parameter width=32, parameter n=2, parameter addr_width=$clog2(n))
   (input clk,
    input 		   reset,
    input [0:n-1] 	   i_inc,
    input [0:addr_width-1] i_rd_a,
    input 		   i_rd_v,
    output 		   i_rd_r,

    input 		   o_rd_r,
    output 		   o_rd_v,
    output [0:width-1] 	   o_rd_d
    );
   
   localparam sw=addr_width+2;
   
   
   
   wire [0:addr_width]   s0_addr_ext;
   wire 		 s0_rdata_v;
   wire 		 s0_rdata_v_in = s0_rdata_v | (& s0_addr_ext);
   base_vlat#(.width(addr_width+1)) is0_alat(.clk(clk),.reset(reset),.din(s0_addr_ext+1'b1),.q(s0_addr_ext));
   base_vlat#(.width(1))            is0_vlat(.clk(clk),.reset(reset),.din(s0_rdata_v_in),   .q(s0_rdata_v));
   
   wire [0:addr_width-1]   s0_addr = s0_addr_ext[0:addr_width-1];
   wire 		   s0_sel = s0_addr_ext[addr_width];
   
   wire 		   s1_rdata_v;
   wire [0:sw-1] 	   s1_reg;
   wire [0:addr_width-1]   s1_addr;
   wire 		   s1_sel;
   wire [0:sw*n-1] 	   s0_regs;
   base_emux_mc#(.width(sw),.ways(n),.sel_width(addr_width),.aux_width(addr_width+2),.lsel_width(4)) is1_mux
     (.clk(clk),.reset(reset),.sel(s0_addr),.ain({s0_addr,s0_sel,s0_rdata_v}),.din(s0_regs),.aout({s1_addr,s1_sel,s1_rdata_v}),.dout({s1_reg}));
   
   wire [0:n-1] 	   s0_hit;
   base_decode#(.enc_width(addr_width),.dec_width(n)) is0_dec(.en(s0_sel),.din(s0_addr),.dout(s0_hit));
   
   genvar 		   i;
   generate
      for(i=0; i<n; i=i+1)
	begin : gen1
	   wire rd_vld;
	   
	   wire [0:sw-1] cnt;
	   wire [0:sw-1] cnt_in;
	   wire [0:sw-1] cnt_nxt = s0_hit[i] ? {sw{1'b0}} : cnt;
	   assign cnt_in = cnt_nxt + i_inc[i];
	   base_vlat#(.width(sw)) icnt_lat(.clk(clk),.reset(reset),.din(cnt_in),.q(cnt));
	   assign s0_regs[i*sw:(i+1)*sw-1] = cnt;
	end
   endgenerate

   // read access path
   wire 		 s1_rd_v, s1_rd_r;
   wire [0:addr_width-1] s1_rd_a = i_rd_a;
   base_agate is1_gt(.i_v(i_rd_v),.i_r(i_rd_r),.o_v(s1_rd_v),.o_r(s1_rd_r),.en(~s1_sel));


   // rmw access path
   wire 		 s2_rdata_v; // the data read from sram is valid (not the first time reading from it)
   wire 		 s2_we;      // write back to the sram
   wire [0:addr_width-1] s2_wa;      // address to write back to
   wire [0:sw-1] 	 s2_reg;     // data to be added to the data read from sram for write back
   wire [0:width-1] 	 s2_rd;
   
   base_vlat#(.width(sw+1+addr_width+1)) is2_lat(.clk(clk),.reset(reset),.din({s1_reg,s1_rdata_v,s1_addr,s1_sel}),.q({s2_reg,s2_rdata_v,s2_wa,s2_we}));

   wire [0:addr_width-1] s1_ra = s1_sel ? s1_addr : s1_rd_a;
   wire [0:width-1] 	 s2_wd = (s2_rdata_v ? s2_rd : {width{1'b0}}) + s2_reg;

   base_mem#(.width(width),.addr_width(addr_width)) imem
     (.clk(clk),
      .re(1'b1),.ra(s1_ra),.rd(s2_rd),
      .we(s2_we),.wa(s2_wa),.wd(s2_wd)
      );

   wire 		 s2_rd_v, s2_rd_r;
   base_alatch#(.width(1))     is2_rd_lat(.clk(clk),.reset(reset),.i_v(s1_rd_v),.i_r(s1_rd_r),.i_d(1'b0),.o_v(s2_rd_v),.o_r(s2_rd_r),.o_d());
   base_alatch#(.width(width)) is3_rd_lat(.clk(clk),.reset(reset),.i_v(s2_rd_v),.i_r(s2_rd_r),.i_d(s2_rd),.o_v(o_rd_v),.o_r(o_rd_r),.o_d(o_rd_d));

endmodule // base_sram_cntrs

