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
// 2 cycle delay from set/reset to output 
module base_vmem#
  (parameter a_width = 2, parameter depth=1<<a_width, parameter rports=1, parameter rst_ports=1, parameter set_ports=1, parameter set_pri=0
   )
   (input clk,
    input 			  reset,
    input [0:a_width*set_ports-1] i_set_a,
    input [0:set_ports-1] 	  i_set_v,
    input [0:a_width*rst_ports-1] i_rst_a,
    input [0:rst_ports-1] 	  i_rst_v,

    input [0:rports*a_width-1] 	  i_rd_a,
    input [0:rports-1] 		  i_rd_en,
    output [0:rports-1] 	  o_rd_d
    );

   wire [0:depth-1] 	    vbits;


   wire [0:depth*rst_ports-1] rst_dec;
   genvar j;
   generate
      for(j=0; j<rst_ports; j=j+1)
	begin : gen1
	   base_decode#(.enc_width(a_width),.dec_width(depth)) irst_dec(.en(i_rst_v[j]),.din(i_rst_a[j*a_width:(j+1)*a_width-1]),.dout(rst_dec[depth*j:depth*(j+1)-1]));
	end
   endgenerate

   wire [0:depth*set_ports-1] 	    set_dec;
   generate
      for(j=0; j<set_ports; j=j+1)
	begin : gen2
	   base_decode#(.enc_width(a_width),.dec_width(depth)) irst_dec(.en(i_set_v[j]),.din(i_set_a[j*a_width:(j+1)*a_width-1]),.dout(set_dec[depth*j:depth*(j+1)-1]));
	end
   endgenerate

   
   
   wire [0:depth-1] rst_dec_or;
   base_or#(.width(depth),.ways(rst_ports)) irst_or(.i_d(rst_dec),.o_d(rst_dec_or));
   wire [0:depth-1] set_dec_or;
   base_or#(.width(depth),.ways(set_ports)) iset_or(.i_d(set_dec),.o_d(set_dec_or));
   wire [0:depth-1] vbits_in;
   generate
      if (set_pri == 0) 
	assign vbits_in = (vbits | set_dec_or) & ~rst_dec_or;
      else
	assign vbits_in =  (vbits & ~rst_dec_or) | set_dec_or;
   endgenerate
   
   
   base_vlat#(.width(depth)) ivbits(.clk(clk),.reset(reset),.din(vbits_in),.q(vbits));
   genvar 		    i;
   generate
      for(i=0; i< rports; i=i+1)
	begin : gen3
	   wire 		    rd_v_in;
	   base_emux#(.ways(depth),.sel_width(a_width),.width(1))  imux0(.sel(i_rd_a[i*a_width:((i+1)*a_width)-1] ),.din(vbits),.dout(rd_v_in));
	   base_vlat_en#(.width(1)) ird0v(.clk(clk),.reset(reset),.din(rd_v_in),.q(o_rd_d[i]),.enable(i_rd_en[i]));
	end
   endgenerate
   
endmodule
