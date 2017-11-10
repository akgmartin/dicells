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
 
module base_red_xor#(parameter ways=2, parameter width=1)
   (input [ways*width-1:0] din,
    output [width-1:0] dout
    );

   generate
      if (ways == 1)
	assign dout = din;
      else
	begin
	   wire [width-1:0] tmp;
	   base_red_xor#(.ways(ways-1),.width(width)) ixor(.din(din[ways*width-1:width]),.dout(tmp));
	   assign dout = tmp ^ din[width-1:0];
	end
      endgenerate
endmodule // base_red_xor


	   

  
