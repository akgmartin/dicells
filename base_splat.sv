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
 
module base_splat#(parameter ways=2, parameter n_width=$clog2(ways+1), parameter w_width=$clog2(ways))
   (input [0:ways-1] i_r,
    output [0:ways*w_width-1] o_a,
    output [0:n_width-1] o_nr
    );				// 
  genvar 		 i;
   assign o_a[0:w_width-1] = {w_width{1'b0}};
   generate
      for(i=1; i<ways; i=i+1)
	begin :gen1
	   assign o_a[i*w_width:(i+1)*w_width-1] = o_a[(i-1)*w_width:i*w_width-1] + i_r[i-1];
	   
	end
   endgenerate
   localparam nways_width = $clog2(ways+1);

   wire [0:n_width-1] nrdy;
   base_cenc#(.enc_width(n_width),.dec_width(ways)) icenc(.din(i_r),.dout(o_nr));
endmodule // dfl_demux_splat
    

