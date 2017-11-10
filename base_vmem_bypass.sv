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
 
// reset triumphs over set
// 1 cycle delay from set/reset to output 
module base_vmem_bypass#
  (parameter a_width = 2, parameter rports=1, parameter rst_ports=1
   )
   (input clk,
    input 			  reset,
    input [0:a_width-1] 	  i_set_a,
    input 			  i_set_v,
    input [0:a_width*rst_ports-1] i_rst_a,
    input [0:rst_ports-1] 	  i_rst_v,

    input [0:rports*a_width-1] 	  i_rd_a,
    input [0:rports-1] 		  i_rd_en,
    output [0:rports-1] 	  o_rd_d
    );
   localparam depth = 2 ** a_width;
   

   wire [0:depth-1] 	    vbits;
   wire [0:depth-1] 	    set_dec;

   base_decode#(.enc_width(a_width)) iset_dec(.en(i_set_v),.din(i_set_a),.dout(set_dec));

   wire [0:depth*rst_ports-1] rst_dec;
   genvar j;
   generate
      for(j=0; j<rst_ports; j=j+1)
	begin : gen1
	   base_decode#(.enc_width(a_width)) irst_dec(.en(i_rst_v[j]),.din(i_rst_a[j*a_width:(j+1)*a_width-1]),.dout(rst_dec[depth*j:depth*(j+1)-1]));
	end
   endgenerate

   wire [0:depth-1] rst_dec_or;
   base_or#(.width(depth),.ways(rst_ports)) irst_or(.i_d(rst_dec),.o_d(rst_dec_or));
   wire [0:depth-1] vbits_in = (vbits | set_dec) & ~rst_dec_or;
   base_vlat#(.width(depth)) ivbits(.clk(clk),.reset(reset),.din(vbits_in),.q(vbits));
   wire [0:rports-1] s1_rd_d;
   genvar 		    i;
   generate
      for(i=0; i< rports; i=i+1)
	begin : gen2
	   wire 		    rd_v_in;
	   base_emux#(.ways(depth),.width(1))  imux0(.sel(i_rd_a[i*a_width:((i+1)*a_width)-1]),.din(vbits),.dout(rd_v_in));
	   base_vlat_en#(.width(1)) ird0v(.clk(clk),.reset(reset),.din(rd_v_in),.q(s1_rd_d[i]),.enable(i_rd_en[i]));
	end
   endgenerate

   /* bypass logic */
   genvar 			    rd_port;
   genvar 			    rst_port;
   generate
      wire [0:rports-1] 	    rd_hit_rst;
      wire [0:rports-1] 	    rd_hit_set;
      
      for (rd_port=0; rd_port < rports; rd_port = rd_port + 1)
	begin :gen3
	   assign rd_hit_set[rd_port] = (i_rd_a[(a_width*rd_port):(a_width * (rd_port+1))-1] == i_set_a) & i_set_v;
	   wire [0:rst_ports-1] rd_hit_rst_lcl;
	   for(rst_port=0; rst_port < rst_ports; rst_port = rst_port + 1)
	     begin : gen4
		assign rd_hit_rst_lcl[rst_port] = (i_rd_a[(a_width * rd_port):(a_width * (rd_port+1))-1] == i_rst_a[(a_width * rst_port) :(a_width * (rst_port+1))-1]) & i_rst_v[rst_port];
	     end
	   assign rd_hit_rst[rd_port] = | rd_hit_rst_lcl;
	end
   endgenerate
   
   wire [0:rports-1] s1_rd_hit_set;
   wire [0:rports-1] s1_rd_hit_rst;
   base_vlat#(.width(2*rports)) ibyp_lat(.clk(clk),.reset(reset),.din({rd_hit_set,rd_hit_rst}),.q({s1_rd_hit_set,s1_rd_hit_rst}));

   assign o_rd_d = ~s1_rd_hit_rst & (s1_rd_hit_set | s1_rd_d);
   
endmodule
