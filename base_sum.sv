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
 
module base_sum#(parameter n=1, parameter iw=1, parameter ow=1)
   (input [0:n*iw-1] din,
    output [0:ow-1] dout);

   integer 	    i;
   wire [0:iw-1]     dina [0:n-1];
   genvar 	    j;
   generate
      for(j=0; j<n; j=j+1)
	begin : b1
	   assign dina[j] = din[j*iw:(j+1)*iw-1];
	end
   endgenerate
   
	
	
   reg [0:ow-1]     sum;
   always @*
     begin
	sum = 0;
	for(i=0; i<n; i=i+1)
	  begin : b2
	     sum = sum + dina[i];
	  end
     end
   assign dout = sum;
endmodule // base_sum

    
