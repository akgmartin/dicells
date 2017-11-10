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
 
//  if qual=1, then input goes to output.
//  if qual=0, then output is manufactured and input held
//  dual of filter
module base_aforce#(parameter width=1)
  (input  [0:width-1] en,
   input  [0:width-1] i_v,
   output [0:width-1] i_r,

   output [0:width-1] o_v,
   input  [0:width-1] o_r);

   assign i_r = o_r & en;
   assign o_v = i_v | ~en;
endmodule // base_afilter

