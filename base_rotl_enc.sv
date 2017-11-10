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
 
module base_rotl_enc#
  (parameter width=1,
   parameter ways=1,
   parameter oways=ways,
   parameter sel_width=$clog2(ways)
   )
   (input [0:ways*width-1] din,
    output [0:oways*width-1] dout,
    input [0:sel_width-1]    sel
    );

   genvar 		     i;
   genvar 		     j;
   wire [0:width-1] 	     din_array[0:ways-1];
   generate
      for(i=0; i<ways; i=i+1)
	begin : b1
	   assign din_array[i] = din[i*width:(i+1)*width-1];
	end

      for(i=0; i<oways; i=i+1)  // for each output lane
	begin : b2
	   wire [0:width-1] mux_in[0:ways-1];
	   
	   for(j=0; j<ways-i; j=j+1)
	     begin : b3
		assign mux_in[j] = din_array[j+i];
	     end
	   
	   for(j=ways-i; j<ways; j=j+1)
	     begin : b4
		assign mux_in[j] = din_array[j+i-ways];
	     end
	   assign dout[i*width:(i+1)*width-1] = mux_in[sel];
	end
   endgenerate
endmodule // base_rotr_enc
