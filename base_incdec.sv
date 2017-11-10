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
 
module base_incdec#
  (parameter width=0,
   parameter rstv=0
   )
   (
    input 	       clk,
    input 	       reset,
    input 	       i_set_v,
    input [0:width-1]  i_set_d,
    input 	       i_inc,
    input 	       i_dec,
    output [0:width-1] o_cnt,
    output 	       o_zero
    );

   wire [0:width-1] cnt_one = {{width-1{1'b0}},1'b1};
   wire [0:width-1] cnt_d;
   wire [0:width-1] cnt_in = i_set_v ? i_set_d : ({width{i_inc}} & (cnt_d + cnt_one)) | ({width{i_dec}} & (cnt_d - cnt_one));
   wire 	    en = i_set_v | (i_inc ^ i_dec);
   base_vlat_en#(.width(width),.rstv(rstv)) icnt_l(.clk(clk),.reset(reset),.enable(en),.din(cnt_in),.q(cnt_d));
   assign o_zero = (cnt_d == {width{1'b0}});
   assign o_cnt = cnt_d;
endmodule // base_incdec


		    
  
