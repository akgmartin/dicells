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
 
module base_parity_gen#(parameter dwidth=1, parameter pwidth=1)
   (input [0:dwidth-1] i_d,
    output [0:pwidth-1] o_d
    );
   
   localparam wwidth = (dwidth+pwidth-1)/pwidth;
   genvar 	       i;
   generate
      for(i=0; i<pwidth; i=i+1)
	begin : b1
	   if (i == pwidth-1)
	     assign o_d[i] = ~(^(i_d[i*wwidth:dwidth-1]));
	   else 
	     assign o_d[i] = ~(^(i_d[i*wwidth:(i+1)*wwidth-1]));
	end
   endgenerate
endmodule // capi_parity_gen

   
  
    
					    
