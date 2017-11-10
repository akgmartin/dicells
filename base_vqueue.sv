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
 
// A fifo queue, but with room for only one entry of each kind.
// duplicate entries are silently dropped

module base_vqueue#(parameter width=1 )
   (input clk,
    input 		reset,

    output 		i_r,
    input 		i_v,
    input [0:width-1] 	i_d,

    input 		o_r,
    output 		o_v,
    output [0:width-1] 	o_d
    
    );


   wire 	       s1a_v, s1a_r;
   wire [0:width-1]    s1_d;
   wire 	       s1_vmem_re;
   base_alatch_oe#(.width(width)) is1_lat(.clk(clk),.reset(reset),.i_v(i_v),.i_r(i_r),.i_d(i_d),.o_v(s1a_v),.o_r(s1a_r),.o_d(s1_d),.o_en(s1_vmem_re));

   // drop if already in fifo
   wire 	       s1_vmem_rd;
   wire  	       s1b_v, s1b_r;
   base_afilter is1_fltr(.i_v(s1a_v),.i_r(s1a_r),.o_v(s1b_v),.o_r(s1b_r),.en(~s1_vmem_rd));

   // split to fifo and vmem write
   wire [0:1] 	       s1c_v, s1c_r;
   base_acombine#(.ni(1),.no(2)) is1_cmb(.i_v(s1b_v),.i_r(s1b_r),.o_v(s1c_v),.o_r(s1c_r));

   // reset vmem 
   wire 	       s1_rst_v, s1_rst_r;
   wire [0:width-1]    s1_rst_d;
   base_initsm#(.LOG_COUNT(width)) iinit_sm(.clk(clk),.reset(reset),.dout_v(s1_rst_v),.dout_r(s1_rst_r),.dout_d(s1_rst_d));

   wire [0:width-1]    vm_wa;
   wire 	       vm_we,vm_wd;
   wire [0:1] 	       s2b_v, s2b_r;
   wire [0:width-1]    s2_d;
   base_primux#(.ways(3),.width(width+1)) ivmw_mux
     (.i_v({s1_rst_v,      s1c_v[0],  s2b_v[0]}),
      .i_r({s1_rst_r,      s1c_r[0],  s2b_r[0]}),
      .i_d({s1_rst_d,1'b0, s1_d,1'b1, s2_d,1'b0}),
      .o_v(vm_we),.o_r(1'b1),.o_d({vm_wa,vm_wd}),.o_sel());
   base_mem#(.addr_width(width),.width(1),.bypass(1)) ivmem(.clk(clk),.re(s1_vmem_re),.ra(i_d),.rd(s1_vmem_rd),.we(vm_we),.wa(vm_wa),.wd(vm_wd));


   wire 	       s2a_v, s2a_r;
   base_fifo#(.LOG_DEPTH(width),.width(width)) ififo
     (.clk(clk),.reset(reset),
      .i_v(s1c_v[1]),.i_r(s1c_r[1]),.i_d(s1_d),
      .o_v(s2a_v),.o_r(s2a_r),.o_d(s2_d)
      );

   base_acombine#(.ni(1),.no(2)) s2b_cmb(.i_v(s2a_v),.i_r(s2a_r),.o_v(s2b_v),.o_r(s2b_r));

   assign o_v = s2b_v[1];
   assign s2b_r[1] = o_r;
   assign o_d = s2_d;

endmodule // base_vqueue

   
   
