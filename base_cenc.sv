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
 
module base_cenc#(parameter enc_width=1, parameter dec_width=1)
   (input [0:dec_width-1] din,
    output [0:enc_width-1] dout
    );
   generate
      if (dec_width<=1)
	assign dout = {{enc_width-1{1'b0}},din[0]};
      else
	begin : gen1
	   wire [0:enc_width-1] c0,c1;
	   localparam w = dec_width/2;
	   base_cenc#(.enc_width(enc_width),.dec_width(w)) idec0(.din(din[0:w-1]),.dout(c0));
	   base_cenc#(.enc_width(enc_width),.dec_width(dec_width-w)) idec1(.din(din[w:dec_width-1]),.dout(c1));
	   assign dout = c0+c1;
	end
   endgenerate
endmodule // base_cenc
