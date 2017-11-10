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
 
module base_arr_arb#
  (parameter ways=1)
  (input clk,
   input 	     reset,
   output [0:ways-1] i_r,
   input [0:ways-1]  i_v,
   input [0:ways-1]  i_h,

   input 	     o_r,
   output 	     o_v,
   output [0:ways-1] o_s,
   output 	     o_h
   );

   
   wire 	     act = o_r & o_v;  // update state if we have an accepted valid input request 

   // state: tencoded:  1111, 0111, 0011, 0001, 0000
   // one less bit than ways needed since lsb always on.
   wire [0:ways-1]   st;

   
   /* use tcoded state to qualify the input valids, and then repeat the input valids unqualified. No need to repreat the last input*/
   wire [0:ways*2-2] arb_in, arb_out;

   wire [0:ways*2-1] arb_kill;

   assign arb_in[0:ways-1] = i_v & st;
   
   base_prienc_hp#(.ways(ways*2-1)) iarb(.din(arb_in),.dout(arb_out),.kill(arb_kill[0:ways*2-2]));
   assign arb_kill[ways*2-1] = 1'b1;
   
   
   wire [0:ways-1]   i_kill;

   wire [0:ways-1]   arb_out_shft;
   assign arb_out_shft[ways-1] = 1'b0;
   assign o_s    = arb_out [0:ways-1] | arb_out_shft;
   
   wire [0:ways-1] i_nxt_st = arb_kill[ways-1] ? arb_kill[0:ways-1] : {arb_kill[ways:ways*2-1]};

   assign i_kill = (st & arb_kill[0:ways-1]) | (~st & arb_kill[ways:(ways*2)-1]);
   
   // kill: 01111, 00111, 00011, 00001, 00000
   // by happy coincidence, this is just what we want for next state
   assign st[ways-1] = 1'b1;
   generate
      if (ways > 1)
	begin : gen1
	   assign arb_in[ways:(ways*2)-2] = i_v[0:ways-2];
	   assign arb_out_shft[0:ways-2] = arb_out[ways:ways*2-2];
	   wire [0:ways-2]   st_in;
	   base_vlat_en#(.width(ways-1)) irr_st(.clk(clk),.reset(reset),.enable(act),.din(st_in),.q(st[0:ways-2]));
	   assign st_in = (i_h[0:ways-2] & i_v[0:ways-2]) | i_nxt_st[0:ways-2];
	end
   endgenerate

   // accept input if output is accepted and its not killed
   assign i_r = {ways{o_r}} & ~i_kill;

   // we allways accept something   
   assign o_v = | i_v;
   
   assign o_h = arb_kill[ways-1];
endmodule // base_arr_arb
