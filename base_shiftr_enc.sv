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
 
module base_shiftr_enc#
  (parameter width=1,
   parameter ways=1,
   parameter oways=ways,
   parameter sel_width=$clog2(ways)
   )
   (input [ways*width-1:0] din,
    output [oways*width-1:0] dout,
    input [0:sel_width-1]    sel
    );

   genvar 		     i;
   genvar 		     j;
   wire [width-1:0] 	     din_array[ways-1:0];
   wire 		     ovf = sel >= ways;
   generate
      for(i=0; i<ways; i=i+1)
	begin : b1
	assign din_array[i] = din[(i+1)*width-1:i*width];
	   end

      for(i=0; i<oways; i=i+1)  // for each output lane
	begin : gen1
	   wire [width-1:0] mux_in[ways-1:0];
	   
	   for(j=0; j<ways-i; j=j+1)
	     begin: gen2
		assign mux_in[j] = din_array[j+i];
	     end
	   for(j=ways-i; j<ways; j=j+1)
	     begin: gen3
		assign mux_in[j] = {width{1'b0}};
	     end
	   assign dout[(i+1)*width-1:i*width] = ovf ? {width{1'b0}} : mux_in[sel];
	end
   endgenerate
endmodule // base_shiftr_enc
