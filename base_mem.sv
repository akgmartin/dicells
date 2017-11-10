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
 
`define BEHAVIORAL
module base_mem#
  (
   parameter width = 1,
   parameter addr_width = 1,
   parameter depth = 2 ** addr_width,
   parameter wdelay = 0,
   parameter ramstyle="",
   parameter dist_ram = 0,
   parameter block_ram = 0,
   parameter bypass=0
   )
   (
   input clk,
   input we,
   input [addr_width-1:0] wa,
   input [width-1:0] 	  wd,
   input re,
   input [addr_width-1:0] ra,
   output [width-1:0] 	  rd
    );
   

   wire 		  we_d;
   wire [addr_width-1:0]  wa_d;
   wire [width-1:0] 	  wd_d;

   base_delay#(.width(1+addr_width+width),.n(wdelay)) idel
     (
      .clk(clk),.reset(1'b0),
      .i_d({we,wa,wd}),
      .o_d({we_d,wa_d,wd_d})
      );


   reg [width-1:0] 	  ram[depth-1:0];
   reg [width-1:0] 	  rd_reg;
   generate
      if (bypass) 
	always@(posedge clk) 
	  begin
	     if (we_d) 
	       begin
		  ram[wa_d] <= wd_d;
	       end
	     if (re)
	       rd_reg <= (we_d & (wa==ra)) ? wd_d : ram[ra];
	  end
      else
	always@(posedge clk) 
	  begin
	     if (we_d) 
	       begin
		  ram[wa_d] <= wd_d;
	       end
	     if (re)
	       rd_reg <= ram[ra];
	  end
      assign rd = rd_reg;
   endgenerate   
endmodule // base_mem

   
   
		  
