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
 
// input 0 has highest priority
module base_priarb #
  (parameter ways = 2
   )
  (
   input [0:ways-1]  i_v,
   output [0:ways-1] i_r,
   output [0:ways-1] o_v,
   input 	     o_r
   );
   
   wire [0:ways-1]   kill;
   
   base_prienc_hp#(.ways(ways)) ipe(.din(i_v),.dout(o_v),.kill(kill));
   assign i_r = {ways{o_r}} & ~kill;
endmodule // base_pri_arb

		     
