// Copyright (C) 1953-2020 NUDT
// Verilog module name - hcp_macro_define
// Version: hcp_macro_define_V1.0
// Created:
//         by - fenglin
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         define macro.
//             - hcp supports two versions:fram that is fragmented and frame that isn't fragmented
////////////////////////////////////////////////////////////////////////////
//`define frame_frag_version				//fram that is fragmented
`define frame_notfrag_version		    //frame that isn't fragmented



`ifdef frame_frag_version
    `define bufid_num 512
`endif
`ifdef frame_notfrag_version
    `define bufid_num 32
`endif