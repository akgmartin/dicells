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
 
// compress 
module base_compress#
  (parameter ways=2,
   parameter width=$clog2(ways),
   parameter nv_width = $clog2(ways+1)
  )
   (input [0:ways-1] 	    i_v,  // these have valid data
    output [0:width*ways-1] o_a,  // here is where to pull from
    output [0:nv_width-1]   o_nv  // here is how many
    );

   genvar 	      i;
   wire [0:ways*ways-1] d_kill;
   generate
      for(i=0; i<ways; i=i+1)
	begin : gen1
	   wire [0:ways-1] kill;
	   if (i == 0) 
	     assign kill = {ways{1'b0}};
	   else
	     assign kill = d_kill[(i-1)*ways:i*ways-1];
	   wire [0:ways-1]    din = i_v & ~kill;
	   wire [0:ways-1]    pe;
	   base_prienc_hp_new#(.ways(ways)) ipe(.din(din),.dout(pe),.kill());
	   base_encode#(.enc_width(width),.dec_width(ways)) ienc(.i_d(pe),.o_d(o_a[i*width:(i+1)*width-1]),.o_v());
	   assign d_kill[i*ways:(i+1)*ways-1] = kill | pe;
	end // block: gen1;
   endgenerate
   base_cenc#(.enc_width(nv_width),.dec_width(ways)) icenc(.din(i_v),.dout(o_nv));
   
endmodule // dfl_encode_com

	        
