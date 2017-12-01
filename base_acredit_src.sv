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

module base_acredit_src#
(
  parameter credits = 0,
  parameter log_credits = $clog2(credits+1)
)
(
  input  clk,
  input  reset,

  output i_r,
  input  i_v,

  input  o_c,
  input  o_r,
  output o_v
);

  wire credit_z;
  wire s1_c;

  base_vlat#(.width(1)) iclat (.clk(clk),.reset(reset),.din(o_c),.q(s1_c));

  wire [log_credits-1:0] i_set_d = 0;
  base_incdec#(.width(log_credits),.rstv(credits)) iincdec (
    .clk(clk),.reset(reset),
    .i_set_v(1'b0),.i_set_d(i_set_d),.i_inc(s1_c),.i_dec(i_r & i_v),
    .o_zero(credit_z),.o_cnt()
  );

  wire   credit_r = ~credit_z;
  assign i_r = o_r & credit_r;
  assign o_v = i_v & credit_r;

endmodule // base_acredit_src
