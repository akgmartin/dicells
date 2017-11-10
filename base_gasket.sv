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
 
module base_gasket#
  (parameter width=1,
   parameter ewidth=1,
   parameter ni=2, // cannot excede 2n-1
   parameter no=2, // must be power of 2
   parameter ni_width = $clog2(ni+1),
   parameter no_width = $clog2(no+1)
   )
   (input clk,
    input 		  reset,
    output 		  i_r,
    input 		  i_v,
    input [0:ni_width-1]  i_nv,
    input [0:ni*width-1]  i_d,
    input 		  i_e,
    input [0:ewidth-1] 	  i_ed,
    input 		  o_r,
    output 		  o_v,
    output 		  o_e,
    output [0:ewidth-1]   o_ed,
    output [0:width*no-1] o_d,
    output [0:no_width-1] o_nv,
    input [0:no_width-1]  o_nr // WARNING this must be valid, even when o_r is 0 
    );

   assign o_ed = i_ed;
   generate
      if (ni == 1 && no==1)
	begin
	   assign i_r = o_r;
	   assign o_nv = i_nv;
	   assign o_e = i_e;
	   assign o_v = (i_e | (i_nv >= o_nr)) & i_v;
	   assign o_d = i_d;
	end
      else
	begin : gen1
	   
	   //how much storage do we need
	   localparam ns = (no > ni ? no : ni) - 1;
	   localparam ptr_width = $clog2(ns+1);
	   
	   localparam nx = ns+ns+1;
	   localparam nx_width = $clog2(nx+1);

	   localparam [no_width-1:0] nno = no;
	   
	   
	   wire [0:ni_width-1] 	  s0_nvb  = (i_v & ~i_e) ? i_nv : 0;
	   wire [0:ni_width-1] 	  s0_nva =  ~i_e ? i_nv : 0;

	   
	   wire [0:ptr_width-1]   s0_ptr;
	   // decision making
	   // accept input
	   wire [nx_width-1:0] 	  s0_nv_ptra = s0_nva + s0_ptr;
	   wire [nx_width-1:0] 	  s0_nv_ptrb = s0_nvb + s0_ptr;
	   wire [0:nx_width-1] 	  s0_ns_nr = ns + o_nr;
	   wire 		  s0_r_0 =  i_e ? 1'b0 :        (s0_nv_ptra <= ns);     // accept if output not accepted
	   wire 		  s0_r_1 =  i_e ? (s0_ptr==0) : (s0_nv_ptra <= s0_ns_nr); // accept if output is accepted 
	   assign i_r = o_r ? s0_r_1 : s0_r_0;
	   assign o_nv = (s0_nv_ptrb > nno) ? nno : s0_nv_ptrb[no_width-1:0];
	   assign o_e = i_e & (s0_ptr == 0);
	   assign o_v = (i_v & i_e) ? 1'b1 : (s0_nv_ptrb >= o_nr);
	   
	   wire 		  i_act = i_v & i_r;
	   wire 		  o_act = o_v & o_r;

	   wire [0:ni_width-1] 	  s0_ni = (i_act & ~i_e) ? i_nv : 0;
	   wire [0:no_width-1] 	  s0_no = (o_act & ~o_e) ? ((i_v & i_e & (s0_ptr < o_nr)) ? s0_ptr : o_nr) : {no_width{1'b0}}; 

	   wire [0:ptr_width-1]   s0_ptr_in = s0_ptr + s0_ni - s0_no;
	   base_vlat#(.width(ptr_width)) is0_ptr_lat(.clk(clk),.reset(reset),.din(s0_ptr_in),.q(s0_ptr));
	   
	   
	   // shift the input right to follow the latched data
	   localparam npad = nx-ni;
	   wire [0:nx*width-1] 	  s0_id_shft;
	   wire [0:npad*width-1]  s0_pad={npad*width{1'b0}};
	   base_shiftr_enc#(.ways(nx),.sel_width(ptr_width),.width(width)) is0_drot(.din({i_d,s0_pad}),.dout(s0_id_shft),.sel(s0_ptr));
	   
	   wire [0:ns-1] 	  s0_lv; // which latches have valid data
	   wire [0:ns*width-1] 	  s0_ld;
	   base_tdec#(.enc_width(ptr_width),.dec_width(ns)) is0_lv(.i_d(s0_ptr),.o_d(s0_lv));
	   
	   // merge input data (shifted) with latched data
	   wire [0:nx*width-1] 	  s0_d;
	   genvar 		  i;
	   
	   for(i=0; i<ns; i=i+1)
	     begin : b1
		assign s0_d[i*width:(i+1)*width-1] = s0_lv[i] ? s0_ld[i*width:(i+1)*width-1] : s0_id_shft[i*width:(i+1)*width-1];
	     end
	   
	   assign s0_d[ns*width:nx*width-1] = s0_id_shft[ns*width:nx*width-1];
	   
	   // shift merged data left and store
	   wire [0:ns*width-1] 	  s0_ld_din;
	   base_shiftl_enc#(.width(width),.ways(nx),.sel_width(no_width) ,.oways(ns)) is0_lin_shft(.din(s0_d),.dout(s0_ld_din),.sel(s0_no));
	   base_vlat#(.width(width*ns)) ilat(.clk(clk),.reset(reset),.din(s0_ld_din),.q(s0_ld));
	   
	   assign o_d = s0_d[0:no*width-1];
	   
	   // debug

	   for(i=0; i<ni; i=i+1)
	     begin : gen_i
		wire [0:7] a = i_nv > i ? (i_d[i*width:(i+1)*width-1]) : 8'dx;
	     end
	   for(i=0; i<ns; i=i+1)
	     begin : gen_s
		wire [0:7] a = s0_ptr > i ? (s0_ld[i*width:(i+1)*width-1]) : 8'dx;
	     end
	   for(i=0; i<no; i=i+1)
	     begin : gen_o
		wire [0:7] o = o_d[i*width:(i+1)*width-1];
	     end
	end
   endgenerate	   
endmodule // dfl_demux_fifo


    
