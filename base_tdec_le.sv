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
 
/* dencode a number into "thermometer decoded" output (little endian version)
   n dec  tdec 
   0 001  000
   1 010  001 
   2 100  011 
   3 000  111
   4 000  111 
 
   Input must be in ths format
 */
module base_tdec_le#(parameter dec_width=1,parameter enc_width = 1)
   (input [enc_width-1:0] i_d,
    output [dec_width-1:0] o_d
    );


   wire [dec_width-1:0]    s0_dec;
   base_decode_le#(.enc_width(enc_width),.dec_width(dec_width)) idec(.din(i_d),.dout(s0_dec),.en(1'b1));
   genvar 			      i;
   generate
      for(i=0; i<dec_width; i=i+1)
	begin : gen1
	   assign o_d[i] = ~ (| s0_dec[i:0]);
	end
   endgenerate
endmodule // base_tenc

