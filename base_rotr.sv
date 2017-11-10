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
 
// static rotator
module base_rotr#(parameter width=1, parameter rot=0)
   (input [0:width-1] din,
    output [0:width-1] dout
    );

   localparam r = rot % width;
   
   generate
      if (r==0 || width==1) assign dout = din;
      else begin
	 assign dout[r:width-1] = din[0:width-r-1];
	 assign dout[0:r-1] = din[width-r:width-1];
      end
   endgenerate
endmodule // base_rotr

      
	  
	   
						   
   
