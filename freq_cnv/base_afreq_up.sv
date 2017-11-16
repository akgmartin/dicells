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
module base_afreq_up#(parameter width)
  (input  clk_lo,
   output 	     i_r,
   input 	     i_v,
   input [width-1:0] i_d0,
   input [width-1:0] i_d1,
   input 	     o_r,
   output 	     o_v,
   output [width-1:0] o_d
   );
   

   base_arfilter ifltr(.i_v(i_v),.i_r(i_r),.o_v(o_v),.o_r(o_r),.en(~clk_lo));
   assign o_d = clk_lo ? i_d0 : i_d1;

endmodule // base_freq_up
    
   

		    
