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
 

module base_transpose#(parameter w=1, parameter rs=1, parameter cs=1)
   (input [0:w*cs*rs-1] din,
    output [0:w*rs*cs-1] dout
    );

   genvar  r;
   genvar  c;
   generate
      for(r=0; r<rs; r=r+1)
	begin :b1
	   for(c=0; c<cs; c=c+1)
	     begin :b2
		assign dout[(rs*c+r)*w:(rs*c+r+1)*w-1] = din[(cs*r+c)*w:(cs*r+c+1)*w-1];
	     end
	end
      endgenerate
endmodule // base_transpose
