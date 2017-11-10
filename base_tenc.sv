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
 
/* encode a "thermometer decoded" input
   00000 = 0
   10000 = 1
   11000 = 2
   11100 = 3 etc.
  Input must be in ths format
 */

module base_tenc#(parameter dec_width=1,parameter enc_width = 1)
   (input [0:dec_width-1]  i_d,
    output [0:enc_width-1] o_d
    );
   
   wire [0:enc_width*(dec_width+1)-1] mux_din;

   wire [0:dec_width] 		      mux_sel = {1'b1,i_d}  ^ {i_d,1'b0};
   
   genvar 			      i;
   generate
      for(i=0; i<dec_width+1; i=i+1)
	begin : gen1
	   localparam [0:enc_width-1] ii = i;
	   assign mux_din[i*enc_width:(i+1)*enc_width-1] = ii;
	end
   endgenerate
   base_mux#(.ways(dec_width+1),.width(enc_width)) imux(.sel(mux_sel),.din(mux_din),.dout(o_d));
endmodule // base_tenc

