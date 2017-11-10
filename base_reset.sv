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
 
// t1: duration of reset pulse
// t2: delay of reset pulse (helps with distribution timing *)
//
//
//  ___________|----------|_______
//    t1          t2   
module base_reset#(parameter t1=1, parameter t2 = 1)
   (input clk,
    output reset);

   localparam w2 = $clog2(t2+1);

   reg [w2-1:0] r2;

   reg [t1:0] 	r1;

   initial
     begin
	r1 <= 0;
	r2 <= 0;
     end

   wire e2 = (r2 == t2);
   always@(posedge clk) 
     begin
	if (~e2)
	  r2 <= r2 + 1'b1;
	r1[t1] <= (~e2);
	r1[t1-1:0] <= r1[t1:1];
     end
   assign reset = r1[0];
endmodule // base_reset
