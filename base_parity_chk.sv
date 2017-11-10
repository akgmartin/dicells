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
 
module base_parity_chk#(parameter dwidth=1, parameter pwidth=1)
   (input 	       i_v,
    input [0:dwidth-1] i_d,
    input [0:pwidth-1] i_p,
    output 	       o_err
    );


   wire [0:pwidth-1]   ep;
   base_parity_gen#(.dwidth(dwidth),.pwidth(pwidth)) igen(.i_d(i_d),.o_d(ep));
   assign 	       o_err = (| (ep ^ i_p)) & i_v;

endmodule // base_parity_chk



   
  
    
					    
