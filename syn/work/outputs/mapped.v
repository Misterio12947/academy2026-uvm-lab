/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : V-2023.12-SP5-5
// Date      : Thu Jul 30 05:07:28 2026
/////////////////////////////////////////////////////////////


module mux4_WIDTH8_1 ( din1, din2, din3, din4, select, dout );
  input [7:0] din1;
  input [7:0] din2;
  input [7:0] din3;
  input [7:0] din4;
  input [1:0] select;
  output [7:0] dout;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22;

  sky130_fd_sc_hd__inv_1 U1 ( .A(select[0]), .Y(n1) );
  sky130_fd_sc_hd__nor2_1 U2 ( .A(select[1]), .B(n1), .Y(n18) );
  sky130_fd_sc_hd__inv_1 U3 ( .A(select[1]), .Y(n2) );
  sky130_fd_sc_hd__nor2_1 U4 ( .A(n2), .B(n1), .Y(n17) );
  sky130_fd_sc_hd__a22oi_1 U5 ( .A1(n18), .A2(din2[0]), .B1(n17), .B2(din4[0]), 
        .Y(n4) );
  sky130_fd_sc_hd__nor2_1 U6 ( .A(select[1]), .B(select[0]), .Y(n20) );
  sky130_fd_sc_hd__nor2_1 U7 ( .A(select[0]), .B(n2), .Y(n19) );
  sky130_fd_sc_hd__a22oi_1 U8 ( .A1(n20), .A2(din1[0]), .B1(n19), .B2(din3[0]), 
        .Y(n3) );
  sky130_fd_sc_hd__nand2_1 U9 ( .A(n4), .B(n3), .Y(dout[0]) );
  sky130_fd_sc_hd__a22oi_1 U10 ( .A1(n18), .A2(din2[1]), .B1(n17), .B2(din4[1]), .Y(n6) );
  sky130_fd_sc_hd__a22oi_1 U11 ( .A1(n20), .A2(din1[1]), .B1(n19), .B2(din3[1]), .Y(n5) );
  sky130_fd_sc_hd__nand2_1 U12 ( .A(n6), .B(n5), .Y(dout[1]) );
  sky130_fd_sc_hd__a22oi_1 U13 ( .A1(n18), .A2(din2[2]), .B1(n17), .B2(din4[2]), .Y(n8) );
  sky130_fd_sc_hd__a22oi_1 U14 ( .A1(n20), .A2(din1[2]), .B1(n19), .B2(din3[2]), .Y(n7) );
  sky130_fd_sc_hd__nand2_1 U15 ( .A(n8), .B(n7), .Y(dout[2]) );
  sky130_fd_sc_hd__a22oi_1 U16 ( .A1(n18), .A2(din2[3]), .B1(n17), .B2(din4[3]), .Y(n10) );
  sky130_fd_sc_hd__a22oi_1 U17 ( .A1(n20), .A2(din1[3]), .B1(n19), .B2(din3[3]), .Y(n9) );
  sky130_fd_sc_hd__nand2_1 U18 ( .A(n10), .B(n9), .Y(dout[3]) );
  sky130_fd_sc_hd__a22oi_1 U19 ( .A1(n18), .A2(din2[4]), .B1(n17), .B2(din4[4]), .Y(n12) );
  sky130_fd_sc_hd__a22oi_1 U20 ( .A1(n20), .A2(din1[4]), .B1(n19), .B2(din3[4]), .Y(n11) );
  sky130_fd_sc_hd__nand2_1 U21 ( .A(n12), .B(n11), .Y(dout[4]) );
  sky130_fd_sc_hd__a22oi_1 U22 ( .A1(n18), .A2(din2[5]), .B1(n17), .B2(din4[5]), .Y(n14) );
  sky130_fd_sc_hd__a22oi_1 U23 ( .A1(n20), .A2(din1[5]), .B1(n19), .B2(din3[5]), .Y(n13) );
  sky130_fd_sc_hd__nand2_1 U24 ( .A(n14), .B(n13), .Y(dout[5]) );
  sky130_fd_sc_hd__a22oi_1 U25 ( .A1(n18), .A2(din2[6]), .B1(n17), .B2(din4[6]), .Y(n16) );
  sky130_fd_sc_hd__a22oi_1 U26 ( .A1(n20), .A2(din1[6]), .B1(n19), .B2(din3[6]), .Y(n15) );
  sky130_fd_sc_hd__nand2_1 U27 ( .A(n16), .B(n15), .Y(dout[6]) );
  sky130_fd_sc_hd__a22oi_1 U28 ( .A1(n18), .A2(din2[7]), .B1(n17), .B2(din4[7]), .Y(n22) );
  sky130_fd_sc_hd__a22oi_1 U29 ( .A1(n20), .A2(din1[7]), .B1(n19), .B2(din3[7]), .Y(n21) );
  sky130_fd_sc_hd__nand2_1 U30 ( .A(n22), .B(n21), .Y(dout[7]) );
endmodule


module register_bank_WIDTH8_1 ( clk, rst, wr_en, in, out );
  input [7:0] in;
  output [7:0] out;
  input clk, rst, wr_en;
  wire   n28, n3, n5, n7, n9, n11, n13, n15, n17, n1, n2, n4, n6, n8, n10, n12,
         n14, n16, n18, n19, n20, n21, n22, n23, n24, n25, n27;

  sky130_fd_sc_hd__dfrtp_1 \out_reg[7]  ( .D(n17), .CLK(clk), .RESET_B(n27), 
        .Q(out[7]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[2]  ( .D(n7), .CLK(clk), .RESET_B(n27), 
        .Q(out[2]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[5]  ( .D(n13), .CLK(clk), .RESET_B(n27), 
        .Q(out[5]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[3]  ( .D(n9), .CLK(clk), .RESET_B(n27), 
        .Q(n28) );
  sky130_fd_sc_hd__dfrtp_2 \out_reg[4]  ( .D(n11), .CLK(clk), .RESET_B(n27), 
        .Q(out[4]) );
  sky130_fd_sc_hd__dfrtp_2 \out_reg[6]  ( .D(n15), .CLK(clk), .RESET_B(n27), 
        .Q(out[6]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[1]  ( .D(n5), .CLK(clk), .RESET_B(n27), 
        .Q(out[1]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[0]  ( .D(n3), .CLK(clk), .RESET_B(n27), 
        .Q(out[0]) );
  sky130_fd_sc_hd__inv_1 U2 ( .A(n28), .Y(n1) );
  sky130_fd_sc_hd__o21ai_0 U3 ( .A1(wr_en), .A2(n8), .B1(n6), .Y(n5) );
  sky130_fd_sc_hd__o21ai_0 U4 ( .A1(wr_en), .A2(n19), .B1(n18), .Y(n15) );
  sky130_fd_sc_hd__o21ai_0 U5 ( .A1(wr_en), .A2(n4), .B1(n2), .Y(n11) );
  sky130_fd_sc_hd__o21ai_0 U6 ( .A1(wr_en), .A2(n21), .B1(n20), .Y(n3) );
  sky130_fd_sc_hd__o21ai_0 U7 ( .A1(wr_en), .A2(n12), .B1(n10), .Y(n9) );
  sky130_fd_sc_hd__o21ai_0 U8 ( .A1(wr_en), .A2(n23), .B1(n22), .Y(n13) );
  sky130_fd_sc_hd__o21ai_0 U9 ( .A1(wr_en), .A2(n16), .B1(n14), .Y(n7) );
  sky130_fd_sc_hd__o21ai_0 U10 ( .A1(wr_en), .A2(n25), .B1(n24), .Y(n17) );
  sky130_fd_sc_hd__inv_1 U11 ( .A(rst), .Y(n27) );
  sky130_fd_sc_hd__inv_4 U12 ( .A(n1), .Y(out[3]) );
  sky130_fd_sc_hd__inv_1 U13 ( .A(out[4]), .Y(n4) );
  sky130_fd_sc_hd__nand2_1 U14 ( .A(in[4]), .B(wr_en), .Y(n2) );
  sky130_fd_sc_hd__inv_1 U15 ( .A(out[1]), .Y(n8) );
  sky130_fd_sc_hd__nand2_1 U16 ( .A(in[1]), .B(wr_en), .Y(n6) );
  sky130_fd_sc_hd__inv_1 U17 ( .A(out[3]), .Y(n12) );
  sky130_fd_sc_hd__nand2_1 U18 ( .A(in[3]), .B(wr_en), .Y(n10) );
  sky130_fd_sc_hd__inv_1 U19 ( .A(out[2]), .Y(n16) );
  sky130_fd_sc_hd__nand2_1 U20 ( .A(in[2]), .B(wr_en), .Y(n14) );
  sky130_fd_sc_hd__inv_1 U21 ( .A(out[6]), .Y(n19) );
  sky130_fd_sc_hd__nand2_1 U22 ( .A(in[6]), .B(wr_en), .Y(n18) );
  sky130_fd_sc_hd__inv_1 U23 ( .A(out[0]), .Y(n21) );
  sky130_fd_sc_hd__nand2_1 U24 ( .A(in[0]), .B(wr_en), .Y(n20) );
  sky130_fd_sc_hd__inv_1 U25 ( .A(out[5]), .Y(n23) );
  sky130_fd_sc_hd__nand2_1 U26 ( .A(in[5]), .B(wr_en), .Y(n22) );
  sky130_fd_sc_hd__inv_1 U27 ( .A(out[7]), .Y(n25) );
  sky130_fd_sc_hd__nand2_1 U28 ( .A(in[7]), .B(wr_en), .Y(n24) );
endmodule


module mux4_registered_WIDTH8_1 ( clk, rst, wr_en, sel, in1, in2, in3, in4, 
        out );
  input [1:0] sel;
  input [7:0] in1;
  input [7:0] in2;
  input [7:0] in3;
  input [7:0] in4;
  output [7:0] out;
  input clk, rst, wr_en;
  wire   n3, n1;
  wire   [7:0] mux_out;

  mux4_WIDTH8_1 u_mux4 ( .din1(in1), .din2(in2), .din3(in3), .din4(in4), 
        .select(sel), .dout(mux_out) );
  register_bank_WIDTH8_1 u_reg_bank ( .clk(clk), .rst(rst), .wr_en(wr_en), 
        .in(mux_out), .out({out[7:6], n3, out[4:0]}) );
  sky130_fd_sc_hd__inv_2 U1 ( .A(n3), .Y(n1) );
  sky130_fd_sc_hd__inv_4 U2 ( .A(n1), .Y(out[5]) );
endmodule


module ALU_WIDTH8 ( in1, in2, op, invalid_data, out, zero, error );
  input [7:0] in1;
  input [7:0] in2;
  input [3:0] op;
  output [15:0] out;
  input invalid_data;
  output zero, error;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30,
         n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, n42, n43, n44,
         n45, n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56, n57, n58,
         n59, n60, n61, n62, n63, n64, n65, n66, n67, n68, n69, n70, n71, n72,
         n73, n74, n75, n76, n77, n78, n79, n80, n81, n82, n83, n84, n85, n86,
         n87, n88, n89, n90, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100,
         n101, n102, n103, n104, n105, n106, n107, n108, n109, n110, n111,
         n112, n113, n114, n115, n116, n117, n118, n119, n120, n121, n122,
         n123, n124, n125, n126, n127, n128, n129, n130, n131, n132, n133,
         n134, n135, n136, n137, n138, n139, n140, n141, n142, n143, n144,
         n145, n146, n147, n148, n149, n150, n151, n152, n153, n154, n155,
         n156, n157, n158, n159, n160, n161, n162, n163, n164, n165, n166,
         n167, n168, n169, n170, n171, n172, n173, n174, n175, n176, n177,
         n178, n179, n180, n181, n182, n183, n184, n185, n186, n187, n188,
         n189, n190, n191, n192, n193, n194, n195, n196, n197, n198, n199,
         n200, n201, n202, n203, n204, n205, n206, n207, n208, n209, n210,
         n211, n212, n213, n214, n215, n216, n217, n218, n219, n220, n221,
         n222, n223, n224, n225, n226, n227, n228, n229, n230, n231, n232,
         n233, n234, n235, n236, n237, n238, n239, n240, n241, n242, n243,
         n244, n245, n246, n247, n248, n249, n250, n251, n252, n253, n254,
         n255, n256, n257, n258, n259, n260, n261, n262, n263, n264, n265,
         n266, n267, n268, n269, n270, n271, n272, n273, n274, n275, n276,
         n277, n278, n279, n280, n281, n282, n283, n284, n285, n286, n287,
         n288, n289, n290, n291, n292, n293, n294, n295, n296, n297, n298,
         n299, n300, n301, n302, n303, n304, n305, n306, n307, n308, n309,
         n310, n311, n312, n313, n314, n315, n316, n317, n318, n319, n320,
         n321, n322, n323, n324, n325, n326, n327, n328, n329, n330, n331,
         n332, n333, n334, n335, n336, n337, n338, n339, n340, n341, n342,
         n343, n344, n345, n346, n347, n348, n349, n350, n351, n352, n353,
         n354, n355, n356, n357, n358, n359, n360, n361, n362, n363, n364,
         n365, n366, n367, n368, n369, n370, n371, n372, n373, n374, n375,
         n376, n377, n378, n379, n380, n381, n382, n383, n384, n385, n386,
         n387, n388, n389, n390, n391, n392, n393, n394, n395, n396, n397,
         n398, n399, n400, n401, n402, n403, n404, n405, n406, n407, n408,
         n409, n410, n411, n412, n413, n414, n415, n416, n417, n418, n419,
         n420, n421, n422, n423, n424, n425, n426, n427, n428, n429, n430,
         n431, n432, n433, n434, n435, n436, n437, n438, n439, n440, n441,
         n442, n443, n444, n445, n446, n447, n448, n449, n450, n451, n452,
         n453, n454, n455, n456, n457, n458, n459, n460, n461, n462, n463,
         n464, n465, n466, n467, n468, n469, n470, n471, n472, n473, n474,
         n475, n476, n477, n478, n479, n480, n481, n482, n483, n484, n485,
         n486, n487, n488, n489, n490, n491, n492, n493, n494, n495, n496,
         n497, n498, n499, n500, n501, n502, n503, n504, n505, n506, n507,
         n508, n509, n510, n511, n512, n513, n514, n515, n516, n517, n518,
         n519, n520, n521, n522, n523, n524, n525, n526, n527, n528, n529,
         n530, n531, n532, n533, n534, n535, n536, n537, n538, n539, n540,
         n541, n542, n543, n544, n545, n546, n547, n548, n549, n550, n551,
         n552, n553, n554, n555, n556, n557, n558, n559, n560, n561, n562,
         n563, n564, n565, n566, n567, n568, n569, n570, n571, n572, n573,
         n574, n575, n576, n577, n578, n579, n580, n581, n582, n583, n584,
         n585, n586, n587, n588, n589, n590, n591, n592, n593, n594, n595,
         n596, n597, n598, n599, n600, n601, n602, n603, n604, n605, n606,
         n607, n608, n609, n610, n611, n612, n613, n614, n615, n616, n617,
         n618, n619, n620, n621, n622, n623, n624, n625, n626, n627, n628,
         n629, n630, n631, n632, n633, n634, n635, n636, n637, n638, n639,
         n640, n641, n642, n643, n644, n645, n646, n647, n648, n649, n650,
         n651, n652, n653, n654, n655, n656, n657, n658, n659, n660, n661,
         n662, n663, n664, n665, n666, n667, n668, n669, n670, n671, n672,
         n673, n674, n675, n676, n677, n678, n679, n680, n681, n682, n683,
         n684, n685, n686, n687, n688, n689, n690, n691, n692, n693, n694,
         n695, n696, n697, n698, n699, n700, n701, n702, n703, n704, n705,
         n706, n707, n708, n709, n710, n711, n712, n713, n714, n715, n716,
         n717, n718, n719, n720, n721, n722, n723, n724, n725, n726, n727,
         n728, n729, n730, n731, n732, n733, n734, n735, n736, n737, n738,
         n739, n740, n741, n742, n743, n744, n745, n746, n747, n748, n749,
         n750, n751, n752, n753, n754, n755, n756, n757, n758, n759, n760,
         n761, n762, n763, n764, n765, n766, n767, n768, n769, n770, n771,
         n772, n773, n774, n775, n776, n777, n778, n779, n780, n781, n782,
         n783, n784, n785, n786, n787, n788, n789, n790, n791, n792, n793,
         n794, n795, n796, n797;

  sky130_fd_sc_hd__nand3_1 U3 ( .A(n726), .B(n725), .C(n783), .Y(n771) );
  sky130_fd_sc_hd__fa_2 U4 ( .A(n687), .B(n17), .CIN(n686), .COUT(n688), .SUM(
        n702) );
  sky130_fd_sc_hd__or2_1 U5 ( .A(in1[4]), .B(n352), .X(n329) );
  sky130_fd_sc_hd__nor2_1 U6 ( .A(n502), .B(n503), .Y(n622) );
  sky130_fd_sc_hd__nand2_1 U7 ( .A(n239), .B(n238), .Y(n741) );
  sky130_fd_sc_hd__a21oi_1 U8 ( .A1(n276), .A2(n13), .B1(n275), .Y(n277) );
  sky130_fd_sc_hd__fa_1 U9 ( .A(n388), .B(n387), .CIN(n386), .COUT(n390), 
        .SUM(n402) );
  sky130_fd_sc_hd__nor2_2 U10 ( .A(n253), .B(n301), .Y(n254) );
  sky130_fd_sc_hd__nand2_1 U11 ( .A(n351), .B(n465), .Y(n463) );
  sky130_fd_sc_hd__nand2_1 U12 ( .A(n113), .B(n782), .Y(n132) );
  sky130_fd_sc_hd__buf_4 U13 ( .A(in2[2]), .X(n445) );
  sky130_fd_sc_hd__nand2_1 U14 ( .A(n7), .B(n644), .Y(n58) );
  sky130_fd_sc_hd__nor2_1 U15 ( .A(n98), .B(n103), .Y(n105) );
  sky130_fd_sc_hd__nand2_1 U16 ( .A(n39), .B(in1[6]), .Y(n44) );
  sky130_fd_sc_hd__o22ai_1 U17 ( .A1(n384), .A2(n463), .B1(n465), .B2(n371), 
        .Y(n396) );
  sky130_fd_sc_hd__nor2_1 U18 ( .A(n650), .B(n745), .Y(n652) );
  sky130_fd_sc_hd__inv_1 U19 ( .A(n82), .Y(n173) );
  sky130_fd_sc_hd__o22ai_1 U20 ( .A1(n7), .A2(n68), .B1(n67), .B2(n66), .Y(
        n189) );
  sky130_fd_sc_hd__nand2_1 U21 ( .A(n92), .B(n91), .Y(n106) );
  sky130_fd_sc_hd__fa_1 U22 ( .A(n368), .B(n367), .CIN(n366), .COUT(n380), 
        .SUM(n391) );
  sky130_fd_sc_hd__a21oi_1 U23 ( .A1(n198), .A2(n458), .B1(n194), .Y(n158) );
  sky130_fd_sc_hd__inv_1 U24 ( .A(n88), .Y(n103) );
  sky130_fd_sc_hd__inv_1 U25 ( .A(n199), .Y(n149) );
  sky130_fd_sc_hd__nand3_1 U26 ( .A(n149), .B(n220), .C(n219), .Y(n221) );
  sky130_fd_sc_hd__inv_1 U27 ( .A(n301), .Y(n694) );
  sky130_fd_sc_hd__xor2_1 U28 ( .A(n621), .B(n620), .X(n722) );
  sky130_fd_sc_hd__inv_1 U29 ( .A(n668), .Y(n784) );
  sky130_fd_sc_hd__a21oi_1 U30 ( .A1(n689), .A2(n784), .B1(error), .Y(n791) );
  sky130_fd_sc_hd__nor4b_1 U31 ( .D_N(n585), .A(n685), .B(n790), .C(n714), .Y(
        n629) );
  sky130_fd_sc_hd__and2_1 U32 ( .A(n352), .B(in1[4]), .X(n1) );
  sky130_fd_sc_hd__o21a_1 U33 ( .A1(n597), .A2(n623), .B1(n596), .X(n2) );
  sky130_fd_sc_hd__and2_1 U34 ( .A(n180), .B(n179), .X(n3) );
  sky130_fd_sc_hd__inv_2 U35 ( .A(n295), .Y(n545) );
  sky130_fd_sc_hd__nand2_1 U36 ( .A(n126), .B(n83), .Y(n170) );
  sky130_fd_sc_hd__nor2_1 U37 ( .A(in1[4]), .B(n126), .Y(n82) );
  sky130_fd_sc_hd__nand2_1 U38 ( .A(n149), .B(n447), .Y(n159) );
  sky130_fd_sc_hd__o21ai_2 U39 ( .A1(n290), .A2(n289), .B1(n288), .Y(n725) );
  sky130_fd_sc_hd__o21ai_1 U40 ( .A1(n242), .A2(n241), .B1(n240), .Y(n284) );
  sky130_fd_sc_hd__nor2_1 U41 ( .A(n17), .B(n12), .Y(n287) );
  sky130_fd_sc_hd__inv_1 U42 ( .A(n273), .Y(n219) );
  sky130_fd_sc_hd__nand2_1 U43 ( .A(n722), .B(n4), .Y(n627) );
  sky130_fd_sc_hd__clkbuf_2 U44 ( .A(n120), .X(n707) );
  sky130_fd_sc_hd__xnor2_1 U45 ( .A(n9), .B(n61), .Y(n177) );
  sky130_fd_sc_hd__nand2_1 U46 ( .A(n5), .B(n127), .Y(n79) );
  sky130_fd_sc_hd__or2_1 U47 ( .A(n644), .B(n343), .X(n230) );
  sky130_fd_sc_hd__inv_1 U48 ( .A(n740), .Y(n5) );
  sky130_fd_sc_hd__nand2b_1 U49 ( .A_N(n166), .B(n62), .Y(n63) );
  sky130_fd_sc_hd__or2_1 U50 ( .A(n639), .B(n640), .X(n642) );
  sky130_fd_sc_hd__xnor2_1 U51 ( .A(n56), .B(n66), .Y(n740) );
  sky130_fd_sc_hd__clkbuf_1 U52 ( .A(n148), .X(n194) );
  sky130_fd_sc_hd__or2_0 U53 ( .A(in1[6]), .B(n514), .X(n333) );
  sky130_fd_sc_hd__inv_6 U54 ( .A(n435), .Y(n7) );
  sky130_fd_sc_hd__nand2_1 U55 ( .A(n659), .B(n658), .Y(n665) );
  sky130_fd_sc_hd__nand2_1 U56 ( .A(n226), .B(n225), .Y(n290) );
  sky130_fd_sc_hd__nor2_1 U57 ( .A(n663), .B(n657), .Y(n658) );
  sky130_fd_sc_hd__inv_1 U58 ( .A(n217), .Y(n220) );
  sky130_fd_sc_hd__nand3_1 U59 ( .A(n630), .B(n629), .C(n628), .Y(n631) );
  sky130_fd_sc_hd__nand3_1 U60 ( .A(n203), .B(n202), .C(n201), .Y(n204) );
  sky130_fd_sc_hd__nand2_1 U61 ( .A(n617), .B(n616), .Y(n720) );
  sky130_fd_sc_hd__nand2_1 U62 ( .A(n613), .B(n612), .Y(n617) );
  sky130_fd_sc_hd__inv_1 U63 ( .A(n145), .Y(n146) );
  sky130_fd_sc_hd__nand2_1 U64 ( .A(n598), .B(n2), .Y(n614) );
  sky130_fd_sc_hd__nand3_1 U65 ( .A(n158), .B(n150), .C(n159), .Y(n154) );
  sky130_fd_sc_hd__inv_1 U66 ( .A(n723), .Y(n4) );
  sky130_fd_sc_hd__inv_2 U67 ( .A(n264), .Y(n266) );
  sky130_fd_sc_hd__o21ai_0 U68 ( .A1(n797), .A2(n796), .B1(n795), .Y(out[8])
         );
  sky130_fd_sc_hd__clkbuf_2 U69 ( .A(n181), .X(n255) );
  sky130_fd_sc_hd__o21ai_1 U70 ( .A1(n572), .A2(n575), .B1(n573), .Y(n570) );
  sky130_fd_sc_hd__inv_1 U71 ( .A(n85), .Y(n86) );
  sky130_fd_sc_hd__nand2_1 U72 ( .A(n170), .B(n168), .Y(n85) );
  sky130_fd_sc_hd__o21ai_0 U73 ( .A1(n707), .A2(n778), .B1(n788), .Y(n708) );
  sky130_fd_sc_hd__nor2_1 U74 ( .A(n673), .B(error), .Y(n674) );
  sky130_fd_sc_hd__inv_1 U75 ( .A(n125), .Y(n120) );
  sky130_fd_sc_hd__o21ai_1 U76 ( .A1(n533), .A2(n530), .B1(n531), .Y(n561) );
  sky130_fd_sc_hd__nand2_1 U77 ( .A(n672), .B(n671), .Y(n673) );
  sky130_fd_sc_hd__o21ai_0 U78 ( .A1(n678), .A2(n778), .B1(n788), .Y(n679) );
  sky130_fd_sc_hd__o21ai_0 U79 ( .A1(n778), .A2(n699), .B1(n788), .Y(n700) );
  sky130_fd_sc_hd__nand3_2 U80 ( .A(n79), .B(n78), .C(n77), .Y(n80) );
  sky130_fd_sc_hd__nand2_1 U81 ( .A(n480), .B(n479), .Y(n560) );
  sky130_fd_sc_hd__nor2_1 U82 ( .A(n592), .B(n587), .Y(n594) );
  sky130_fd_sc_hd__nor2_1 U83 ( .A(n496), .B(n497), .Y(n581) );
  sky130_fd_sc_hd__nand2_1 U84 ( .A(n177), .B(n63), .Y(n64) );
  sky130_fd_sc_hd__or2_0 U85 ( .A(n608), .B(n609), .X(n611) );
  sky130_fd_sc_hd__inv_1 U86 ( .A(n76), .Y(n77) );
  sky130_fd_sc_hd__clkbuf_1 U87 ( .A(n177), .X(n747) );
  sky130_fd_sc_hd__nor2_1 U88 ( .A(n466), .B(n467), .Y(n530) );
  sky130_fd_sc_hd__nand3_1 U89 ( .A(n75), .B(n74), .C(n73), .Y(n76) );
  sky130_fd_sc_hd__xnor2_1 U90 ( .A(n399), .B(n398), .Y(n417) );
  sky130_fd_sc_hd__nand2_1 U91 ( .A(n374), .B(n373), .Y(n386) );
  sky130_fd_sc_hd__or2_0 U92 ( .A(n735), .B(n736), .X(n738) );
  sky130_fd_sc_hd__nor2_1 U93 ( .A(n292), .B(n43), .Y(n297) );
  sky130_fd_sc_hd__inv_1 U94 ( .A(n430), .Y(n346) );
  sky130_fd_sc_hd__nand2_1 U95 ( .A(n396), .B(n395), .Y(n373) );
  sky130_fd_sc_hd__xnor2_1 U96 ( .A(n367), .B(n396), .Y(n399) );
  sky130_fd_sc_hd__clkbuf_2 U97 ( .A(n463), .X(n454) );
  sky130_fd_sc_hd__inv_1 U98 ( .A(n342), .Y(n344) );
  sky130_fd_sc_hd__o21ai_0 U99 ( .A1(n734), .A2(n733), .B1(n732), .Y(n735) );
  sky130_fd_sc_hd__nand2_1 U100 ( .A(n36), .B(n16), .Y(n142) );
  sky130_fd_sc_hd__inv_1 U101 ( .A(n336), .Y(n338) );
  sky130_fd_sc_hd__inv_1 U102 ( .A(n462), .Y(n339) );
  sky130_fd_sc_hd__or2_1 U103 ( .A(in1[2]), .B(n326), .X(n11) );
  sky130_fd_sc_hd__inv_1 U104 ( .A(n599), .Y(n604) );
  sky130_fd_sc_hd__inv_1 U105 ( .A(in1[3]), .Y(n235) );
  sky130_fd_sc_hd__nand2_1 U106 ( .A(n17), .B(n660), .Y(n148) );
  sky130_fd_sc_hd__inv_2 U107 ( .A(n370), .Y(n6) );
  sky130_fd_sc_hd__inv_1 U108 ( .A(n55), .Y(n57) );
  sky130_fd_sc_hd__xor2_1 U109 ( .A(n235), .B(n234), .X(n8) );
  sky130_fd_sc_hd__xnor2_1 U110 ( .A(n435), .B(n447), .Y(n9) );
  sky130_fd_sc_hd__and2_1 U111 ( .A(n326), .B(in1[2]), .X(n10) );
  sky130_fd_sc_hd__nand2_1 U112 ( .A(n736), .B(n168), .Y(n169) );
  sky130_fd_sc_hd__and2_1 U113 ( .A(n207), .B(n206), .X(n12) );
  sky130_fd_sc_hd__xor2_1 U114 ( .A(n355), .B(n545), .X(n733) );
  sky130_fd_sc_hd__xor2_1 U115 ( .A(n262), .B(n264), .X(n13) );
  sky130_fd_sc_hd__buf_4 U116 ( .A(in1[7]), .X(n687) );
  sky130_fd_sc_hd__inv_2 U117 ( .A(in1[5]), .Y(n112) );
  sky130_fd_sc_hd__o21a_1 U118 ( .A1(n538), .A2(n535), .B1(n536), .X(n14) );
  sky130_fd_sc_hd__nor2_1 U119 ( .A(in2[2]), .B(in2[0]), .Y(n55) );
  sky130_fd_sc_hd__inv_2 U120 ( .A(n228), .Y(n457) );
  sky130_fd_sc_hd__buf_2 U121 ( .A(in2[5]), .X(n458) );
  sky130_fd_sc_hd__inv_2 U122 ( .A(in2[5]), .Y(n16) );
  sky130_fd_sc_hd__clkbuf_1 U123 ( .A(in2[7]), .X(n637) );
  sky130_fd_sc_hd__o21a_1 U124 ( .A1(n165), .A2(n268), .B1(n236), .X(n15) );
  sky130_fd_sc_hd__clkbuf_1 U125 ( .A(n199), .X(n215) );
  sky130_fd_sc_hd__nand2_1 U126 ( .A(n58), .B(n355), .Y(n59) );
  sky130_fd_sc_hd__nand2_1 U127 ( .A(n22), .B(in1[5]), .Y(n47) );
  sky130_fd_sc_hd__nor2_1 U128 ( .A(n7), .B(n748), .Y(n638) );
  sky130_fd_sc_hd__clkbuf_1 U129 ( .A(n406), .X(n601) );
  sky130_fd_sc_hd__nand2_1 U130 ( .A(n57), .B(n355), .Y(n66) );
  sky130_fd_sc_hd__nand2_2 U131 ( .A(n271), .B(n694), .Y(n260) );
  sky130_fd_sc_hd__fa_1 U132 ( .A(n412), .B(n411), .CIN(n410), .COUT(n400), 
        .SUM(n427) );
  sky130_fd_sc_hd__o21ai_1 U133 ( .A1(n586), .A2(n623), .B1(n618), .Y(n525) );
  sky130_fd_sc_hd__inv_2 U134 ( .A(n447), .Y(n352) );
  sky130_fd_sc_hd__nand2_1 U135 ( .A(n154), .B(n153), .Y(n162) );
  sky130_fd_sc_hd__inv_2 U136 ( .A(in2[0]), .Y(n295) );
  sky130_fd_sc_hd__nand2_1 U137 ( .A(n724), .B(n17), .Y(n726) );
  sky130_fd_sc_hd__nand2_2 U138 ( .A(n81), .B(n80), .Y(n126) );
  sky130_fd_sc_hd__nand2_1 U139 ( .A(n665), .B(n664), .Y(n724) );
  sky130_fd_sc_hd__buf_2 U140 ( .A(in2[6]), .X(n513) );
  sky130_fd_sc_hd__nor2_1 U141 ( .A(n720), .B(n627), .Y(n628) );
  sky130_fd_sc_hd__buf_6 U142 ( .A(in2[3]), .X(n435) );
  sky130_fd_sc_hd__buf_6 U143 ( .A(in2[4]), .X(n447) );
  sky130_fd_sc_hd__nand2_2 U144 ( .A(n352), .B(n16), .Y(n293) );
  sky130_fd_sc_hd__inv_1 U145 ( .A(in2[7]), .Y(n17) );
  sky130_fd_sc_hd__inv_1 U146 ( .A(in2[6]), .Y(n660) );
  sky130_fd_sc_hd__nor2_1 U147 ( .A(n293), .B(n148), .Y(n20) );
  sky130_fd_sc_hd__inv_2 U148 ( .A(in2[1]), .Y(n639) );
  sky130_fd_sc_hd__nor2_1 U149 ( .A(in1[6]), .B(n639), .Y(n45) );
  sky130_fd_sc_hd__nand2_1 U150 ( .A(n45), .B(n545), .Y(n19) );
  sky130_fd_sc_hd__inv_4 U151 ( .A(in2[2]), .Y(n644) );
  sky130_fd_sc_hd__inv_1 U152 ( .A(n58), .Y(n18) );
  sky130_fd_sc_hd__nand3_1 U153 ( .A(n20), .B(n19), .C(n18), .Y(n21) );
  sky130_fd_sc_hd__nand2_1 U154 ( .A(n21), .B(n687), .Y(n127) );
  sky130_fd_sc_hd__inv_4 U155 ( .A(n639), .Y(n355) );
  sky130_fd_sc_hd__inv_1 U156 ( .A(n355), .Y(n22) );
  sky130_fd_sc_hd__inv_1 U157 ( .A(n47), .Y(n121) );
  sky130_fd_sc_hd__nor2_1 U158 ( .A(in1[4]), .B(n295), .Y(n72) );
  sky130_fd_sc_hd__inv_1 U159 ( .A(n72), .Y(n101) );
  sky130_fd_sc_hd__nor2_2 U160 ( .A(n121), .B(n101), .Y(n28) );
  sky130_fd_sc_hd__inv_1 U161 ( .A(n28), .Y(n23) );
  sky130_fd_sc_hd__nand2_1 U162 ( .A(n112), .B(n355), .Y(n39) );
  sky130_fd_sc_hd__nand2_2 U163 ( .A(n23), .B(n39), .Y(n117) );
  sky130_fd_sc_hd__inv_1 U164 ( .A(n117), .Y(n24) );
  sky130_fd_sc_hd__nand2_1 U165 ( .A(n24), .B(n644), .Y(n33) );
  sky130_fd_sc_hd__inv_1 U166 ( .A(in1[7]), .Y(n25) );
  sky130_fd_sc_hd__nand2_1 U167 ( .A(n25), .B(n355), .Y(n40) );
  sky130_fd_sc_hd__nor2_1 U168 ( .A(n435), .B(in2[7]), .Y(n27) );
  sky130_fd_sc_hd__clkbuf_1 U169 ( .A(in2[2]), .X(n65) );
  sky130_fd_sc_hd__nor2_1 U170 ( .A(n65), .B(n447), .Y(n68) );
  sky130_fd_sc_hd__nor2_1 U171 ( .A(n458), .B(n513), .Y(n26) );
  sky130_fd_sc_hd__nand4_1 U172 ( .A(n40), .B(n27), .C(n68), .D(n26), .Y(n116)
         );
  sky130_fd_sc_hd__nand2_1 U173 ( .A(n28), .B(n445), .Y(n31) );
  sky130_fd_sc_hd__inv_1 U174 ( .A(n39), .Y(n29) );
  sky130_fd_sc_hd__nand2_1 U175 ( .A(n29), .B(n445), .Y(n30) );
  sky130_fd_sc_hd__nand4_1 U176 ( .A(n116), .B(n31), .C(in1[6]), .D(n30), .Y(
        n32) );
  sky130_fd_sc_hd__o211ai_2 U177 ( .A1(n435), .A2(n127), .B1(n33), .C1(n32), 
        .Y(n54) );
  sky130_fd_sc_hd__inv_1 U178 ( .A(n148), .Y(n36) );
  sky130_fd_sc_hd__nand2_2 U179 ( .A(n36), .B(n7), .Y(n292) );
  sky130_fd_sc_hd__inv_1 U180 ( .A(n293), .Y(n42) );
  sky130_fd_sc_hd__o21ai_2 U181 ( .A1(n687), .A2(n644), .B1(n42), .Y(n34) );
  sky130_fd_sc_hd__nor2_4 U182 ( .A(n292), .B(n34), .Y(n88) );
  sky130_fd_sc_hd__nand3_1 U183 ( .A(n644), .B(n355), .C(n687), .Y(n35) );
  sky130_fd_sc_hd__inv_1 U184 ( .A(in1[6]), .Y(n62) );
  sky130_fd_sc_hd__nand2_1 U185 ( .A(n62), .B(in2[0]), .Y(n41) );
  sky130_fd_sc_hd__nor2_1 U186 ( .A(n35), .B(n41), .Y(n99) );
  sky130_fd_sc_hd__inv_1 U187 ( .A(n447), .Y(n650) );
  sky130_fd_sc_hd__inv_1 U188 ( .A(n142), .Y(n37) );
  sky130_fd_sc_hd__o211ai_1 U189 ( .A1(n687), .A2(n7), .B1(n650), .C1(n37), 
        .Y(n38) );
  sky130_fd_sc_hd__a21oi_1 U190 ( .A1(n88), .A2(n99), .B1(n38), .Y(n53) );
  sky130_fd_sc_hd__nand4_2 U191 ( .A(n42), .B(n41), .C(n644), .D(n40), .Y(n43)
         );
  sky130_fd_sc_hd__nor2_1 U192 ( .A(n44), .B(n297), .Y(n89) );
  sky130_fd_sc_hd__nand2_1 U193 ( .A(n89), .B(n88), .Y(n50) );
  sky130_fd_sc_hd__inv_1 U194 ( .A(n45), .Y(n46) );
  sky130_fd_sc_hd__nand2_1 U195 ( .A(n46), .B(n295), .Y(n48) );
  sky130_fd_sc_hd__nand2_1 U196 ( .A(n48), .B(n47), .Y(n90) );
  sky130_fd_sc_hd__nand2_1 U197 ( .A(n88), .B(n90), .Y(n49) );
  sky130_fd_sc_hd__nand2_1 U198 ( .A(n50), .B(n49), .Y(n51) );
  sky130_fd_sc_hd__inv_1 U199 ( .A(n51), .Y(n52) );
  sky130_fd_sc_hd__nand3_2 U200 ( .A(n54), .B(n53), .C(n52), .Y(n81) );
  sky130_fd_sc_hd__xnor2_1 U201 ( .A(in2[2]), .B(n435), .Y(n56) );
  sky130_fd_sc_hd__o22ai_1 U202 ( .A1(n7), .A2(n644), .B1(n55), .B2(n59), .Y(
        n60) );
  sky130_fd_sc_hd__inv_1 U203 ( .A(n60), .Y(n61) );
  sky130_fd_sc_hd__nand2_1 U204 ( .A(n295), .B(n355), .Y(n71) );
  sky130_fd_sc_hd__mux2i_1 U205 ( .A0(n295), .A1(n71), .S(n445), .Y(n166) );
  sky130_fd_sc_hd__inv_1 U206 ( .A(n64), .Y(n78) );
  sky130_fd_sc_hd__a21oi_1 U207 ( .A1(n447), .A2(n65), .B1(n435), .Y(n67) );
  sky130_fd_sc_hd__inv_1 U208 ( .A(n189), .Y(n75) );
  sky130_fd_sc_hd__nand2_1 U209 ( .A(in1[4]), .B(n355), .Y(n69) );
  sky130_fd_sc_hd__nand2_1 U210 ( .A(n69), .B(n545), .Y(n70) );
  sky130_fd_sc_hd__nand2_1 U211 ( .A(n71), .B(n70), .Y(n97) );
  sky130_fd_sc_hd__a21oi_1 U212 ( .A1(n97), .A2(n112), .B1(n142), .Y(n74) );
  sky130_fd_sc_hd__nand2_1 U213 ( .A(n733), .B(n72), .Y(n73) );
  sky130_fd_sc_hd__and2_1 U214 ( .A(in1[4]), .B(n545), .X(n83) );
  sky130_fd_sc_hd__inv_1 U215 ( .A(in1[4]), .Y(n84) );
  sky130_fd_sc_hd__nand2_1 U216 ( .A(n84), .B(n295), .Y(n168) );
  sky130_fd_sc_hd__nand2_4 U217 ( .A(n173), .B(n86), .Y(n264) );
  sky130_fd_sc_hd__nand2_1 U218 ( .A(n235), .B(n545), .Y(n267) );
  sky130_fd_sc_hd__nand2_1 U219 ( .A(n267), .B(n639), .Y(n87) );
  sky130_fd_sc_hd__nand2_2 U220 ( .A(n264), .B(n87), .Y(n251) );
  sky130_fd_sc_hd__inv_1 U221 ( .A(n89), .Y(n92) );
  sky130_fd_sc_hd__inv_1 U222 ( .A(n90), .Y(n91) );
  sky130_fd_sc_hd__nor2_2 U223 ( .A(n99), .B(n106), .Y(n93) );
  sky130_fd_sc_hd__nor2_2 U224 ( .A(n103), .B(n93), .Y(n125) );
  sky130_fd_sc_hd__nand2_1 U225 ( .A(n125), .B(n545), .Y(n94) );
  sky130_fd_sc_hd__xnor2_1 U226 ( .A(in1[5]), .B(n94), .Y(n96) );
  sky130_fd_sc_hd__inv_1 U227 ( .A(n126), .Y(n95) );
  sky130_fd_sc_hd__nand2_1 U228 ( .A(n96), .B(n95), .Y(n131) );
  sky130_fd_sc_hd__inv_1 U229 ( .A(n97), .Y(n98) );
  sky130_fd_sc_hd__inv_1 U230 ( .A(n105), .Y(n110) );
  sky130_fd_sc_hd__inv_1 U231 ( .A(n99), .Y(n109) );
  sky130_fd_sc_hd__nand2_1 U232 ( .A(n101), .B(n355), .Y(n100) );
  sky130_fd_sc_hd__inv_1 U233 ( .A(n100), .Y(n104) );
  sky130_fd_sc_hd__o22ai_1 U234 ( .A1(n355), .A2(n101), .B1(n100), .B2(n99), 
        .Y(n102) );
  sky130_fd_sc_hd__a21oi_1 U235 ( .A1(n104), .A2(n103), .B1(n102), .Y(n108) );
  sky130_fd_sc_hd__nand2_1 U236 ( .A(n106), .B(n105), .Y(n107) );
  sky130_fd_sc_hd__o211ai_2 U237 ( .A1(n110), .A2(n109), .B1(n108), .C1(n107), 
        .Y(n111) );
  sky130_fd_sc_hd__xnor2_1 U238 ( .A(n112), .B(n111), .Y(n113) );
  sky130_fd_sc_hd__buf_6 U239 ( .A(n126), .X(n782) );
  sky130_fd_sc_hd__nand3_1 U240 ( .A(n131), .B(n445), .C(n132), .Y(n115) );
  sky130_fd_sc_hd__inv_1 U241 ( .A(n267), .Y(n114) );
  sky130_fd_sc_hd__nand2_1 U242 ( .A(n114), .B(n355), .Y(n250) );
  sky130_fd_sc_hd__nand3_1 U243 ( .A(n251), .B(n115), .C(n250), .Y(n214) );
  sky130_fd_sc_hd__nand2_1 U244 ( .A(n116), .B(in1[6]), .Y(n123) );
  sky130_fd_sc_hd__xnor2_1 U245 ( .A(n644), .B(n117), .Y(n118) );
  sky130_fd_sc_hd__xnor2_1 U246 ( .A(n123), .B(n118), .Y(n119) );
  sky130_fd_sc_hd__nand3_2 U247 ( .A(n782), .B(n707), .C(n119), .Y(n136) );
  sky130_fd_sc_hd__nor2_1 U248 ( .A(n121), .B(n120), .Y(n122) );
  sky130_fd_sc_hd__nor2_1 U249 ( .A(n122), .B(n126), .Y(n135) );
  sky130_fd_sc_hd__inv_1 U250 ( .A(n123), .Y(n134) );
  sky130_fd_sc_hd__nand3_1 U251 ( .A(n135), .B(n134), .C(n7), .Y(n124) );
  sky130_fd_sc_hd__o21ai_0 U252 ( .A1(n435), .A2(n136), .B1(n124), .Y(n130) );
  sky130_fd_sc_hd__nor2_1 U253 ( .A(n126), .B(n125), .Y(n129) );
  sky130_fd_sc_hd__inv_1 U254 ( .A(n127), .Y(n128) );
  sky130_fd_sc_hd__nand2_1 U255 ( .A(n129), .B(n128), .Y(n140) );
  sky130_fd_sc_hd__nor2_1 U256 ( .A(n447), .B(n140), .Y(n138) );
  sky130_fd_sc_hd__nor2_1 U257 ( .A(n130), .B(n138), .Y(n133) );
  sky130_fd_sc_hd__nand2_2 U258 ( .A(n132), .B(n131), .Y(n181) );
  sky130_fd_sc_hd__nand2_1 U259 ( .A(n181), .B(n644), .Y(n213) );
  sky130_fd_sc_hd__nand3_2 U260 ( .A(n214), .B(n133), .C(n213), .Y(n147) );
  sky130_fd_sc_hd__nand2_1 U261 ( .A(n135), .B(n134), .Y(n137) );
  sky130_fd_sc_hd__nand2_2 U262 ( .A(n137), .B(n136), .Y(n199) );
  sky130_fd_sc_hd__inv_1 U263 ( .A(n138), .Y(n139) );
  sky130_fd_sc_hd__nand3_1 U264 ( .A(n149), .B(n435), .C(n139), .Y(n144) );
  sky130_fd_sc_hd__inv_1 U265 ( .A(n140), .Y(n141) );
  sky130_fd_sc_hd__inv_2 U266 ( .A(n141), .Y(n198) );
  sky130_fd_sc_hd__a21oi_1 U267 ( .A1(n198), .A2(n447), .B1(n142), .Y(n143) );
  sky130_fd_sc_hd__nand2_1 U268 ( .A(n144), .B(n143), .Y(n145) );
  sky130_fd_sc_hd__nand2_4 U269 ( .A(n147), .B(n146), .Y(n268) );
  sky130_fd_sc_hd__buf_6 U270 ( .A(n268), .X(n301) );
  sky130_fd_sc_hd__nand2_1 U271 ( .A(n181), .B(n7), .Y(n210) );
  sky130_fd_sc_hd__inv_1 U272 ( .A(n210), .Y(n150) );
  sky130_fd_sc_hd__nand2_1 U273 ( .A(n199), .B(n650), .Y(n151) );
  sky130_fd_sc_hd__o21ai_0 U274 ( .A1(n458), .A2(n198), .B1(n151), .Y(n152) );
  sky130_fd_sc_hd__nand2_1 U275 ( .A(n152), .B(n158), .Y(n153) );
  sky130_fd_sc_hd__inv_1 U276 ( .A(n445), .Y(n326) );
  sky130_fd_sc_hd__nand2_2 U277 ( .A(n266), .B(n326), .Y(n157) );
  sky130_fd_sc_hd__inv_1 U278 ( .A(in1[2]), .Y(n155) );
  sky130_fd_sc_hd__nand2_1 U279 ( .A(n155), .B(n545), .Y(n234) );
  sky130_fd_sc_hd__nor2_1 U280 ( .A(n355), .B(n235), .Y(n156) );
  sky130_fd_sc_hd__o22ai_1 U281 ( .A1(in1[3]), .A2(n639), .B1(n234), .B2(n156), 
        .Y(n263) );
  sky130_fd_sc_hd__a22oi_2 U282 ( .A1(n264), .A2(n445), .B1(n157), .B2(n263), 
        .Y(n208) );
  sky130_fd_sc_hd__inv_1 U283 ( .A(n181), .Y(n163) );
  sky130_fd_sc_hd__nand2_1 U284 ( .A(n163), .B(n435), .Y(n209) );
  sky130_fd_sc_hd__nand4_1 U285 ( .A(n208), .B(n209), .C(n159), .D(n158), .Y(
        n160) );
  sky130_fd_sc_hd__inv_1 U286 ( .A(n160), .Y(n161) );
  sky130_fd_sc_hd__o21ai_2 U287 ( .A1(n162), .A2(n161), .B1(n268), .Y(n205) );
  sky130_fd_sc_hd__nand2_1 U288 ( .A(n163), .B(n5), .Y(n176) );
  sky130_fd_sc_hd__inv_1 U289 ( .A(n733), .Y(n165) );
  sky130_fd_sc_hd__nand2_1 U290 ( .A(n733), .B(n235), .Y(n164) );
  sky130_fd_sc_hd__a22oi_1 U291 ( .A1(in1[3]), .A2(n165), .B1(n164), .B2(n234), 
        .Y(n261) );
  sky130_fd_sc_hd__inv_1 U292 ( .A(n166), .Y(n167) );
  sky130_fd_sc_hd__nand2_1 U293 ( .A(n639), .B(n644), .Y(n294) );
  sky130_fd_sc_hd__nand2_1 U294 ( .A(n167), .B(n294), .Y(n736) );
  sky130_fd_sc_hd__inv_1 U295 ( .A(n170), .Y(n171) );
  sky130_fd_sc_hd__nor2_1 U296 ( .A(n169), .B(n171), .Y(n172) );
  sky130_fd_sc_hd__nand2_1 U297 ( .A(n173), .B(n172), .Y(n175) );
  sky130_fd_sc_hd__inv_1 U298 ( .A(n736), .Y(n174) );
  sky130_fd_sc_hd__a22oi_2 U299 ( .A1(n261), .A2(n175), .B1(n264), .B2(n174), 
        .Y(n246) );
  sky130_fd_sc_hd__nand2_1 U300 ( .A(n176), .B(n246), .Y(n183) );
  sky130_fd_sc_hd__nand2_1 U301 ( .A(n199), .B(n747), .Y(n180) );
  sky130_fd_sc_hd__inv_1 U302 ( .A(n198), .Y(n206) );
  sky130_fd_sc_hd__xor2_1 U303 ( .A(n447), .B(n458), .X(n178) );
  sky130_fd_sc_hd__xnor2_1 U304 ( .A(n178), .B(n189), .Y(n749) );
  sky130_fd_sc_hd__nand2_1 U305 ( .A(n206), .B(n749), .Y(n179) );
  sky130_fd_sc_hd__nand2_1 U306 ( .A(n255), .B(n740), .Y(n182) );
  sky130_fd_sc_hd__nand3_1 U307 ( .A(n183), .B(n3), .C(n182), .Y(n203) );
  sky130_fd_sc_hd__inv_1 U308 ( .A(n749), .Y(n197) );
  sky130_fd_sc_hd__xor2_1 U309 ( .A(n513), .B(n637), .X(n188) );
  sky130_fd_sc_hd__nand2_1 U310 ( .A(n513), .B(n447), .Y(n184) );
  sky130_fd_sc_hd__nand2_1 U311 ( .A(n16), .B(n184), .Y(n185) );
  sky130_fd_sc_hd__nand2_1 U312 ( .A(n189), .B(n185), .Y(n187) );
  sky130_fd_sc_hd__o21ai_1 U313 ( .A1(n447), .A2(n513), .B1(n458), .Y(n186) );
  sky130_fd_sc_hd__nand2_1 U314 ( .A(n187), .B(n186), .Y(n195) );
  sky130_fd_sc_hd__xnor2_1 U315 ( .A(n188), .B(n195), .Y(n759) );
  sky130_fd_sc_hd__xor2_1 U316 ( .A(n458), .B(n513), .X(n193) );
  sky130_fd_sc_hd__nand2_1 U317 ( .A(n189), .B(n293), .Y(n191) );
  sky130_fd_sc_hd__nand2_1 U318 ( .A(n458), .B(n447), .Y(n190) );
  sky130_fd_sc_hd__nand2_1 U319 ( .A(n191), .B(n190), .Y(n192) );
  sky130_fd_sc_hd__xnor2_1 U320 ( .A(n193), .B(n192), .Y(n757) );
  sky130_fd_sc_hd__nand2_1 U321 ( .A(n195), .B(n194), .Y(n767) );
  sky130_fd_sc_hd__nand3_1 U322 ( .A(n759), .B(n757), .C(n767), .Y(n196) );
  sky130_fd_sc_hd__a21oi_1 U323 ( .A1(n198), .A2(n197), .B1(n196), .Y(n202) );
  sky130_fd_sc_hd__inv_1 U324 ( .A(n747), .Y(n200) );
  sky130_fd_sc_hd__nand3_1 U325 ( .A(n3), .B(n149), .C(n200), .Y(n201) );
  sky130_fd_sc_hd__nand2_2 U326 ( .A(n205), .B(n204), .Y(n218) );
  sky130_fd_sc_hd__buf_6 U327 ( .A(n218), .X(n271) );
  sky130_fd_sc_hd__nor2_1 U328 ( .A(n694), .B(n271), .Y(n207) );
  sky130_fd_sc_hd__inv_1 U329 ( .A(n287), .Y(n226) );
  sky130_fd_sc_hd__buf_2 U330 ( .A(n208), .X(n244) );
  sky130_fd_sc_hd__nand2_1 U331 ( .A(n244), .B(n209), .Y(n211) );
  sky130_fd_sc_hd__nand2_1 U332 ( .A(n211), .B(n210), .Y(n212) );
  sky130_fd_sc_hd__xnor2_1 U333 ( .A(n650), .B(n212), .Y(n217) );
  sky130_fd_sc_hd__nand3_1 U334 ( .A(n217), .B(n301), .C(n215), .Y(n223) );
  sky130_fd_sc_hd__a21oi_1 U335 ( .A1(n214), .A2(n213), .B1(n435), .Y(n216) );
  sky130_fd_sc_hd__inv_2 U336 ( .A(n218), .Y(n777) );
  sky130_fd_sc_hd__o211ai_1 U337 ( .A1(n216), .A2(n301), .B1(n215), .C1(n777), 
        .Y(n222) );
  sky130_fd_sc_hd__nand2_2 U338 ( .A(n218), .B(n301), .Y(n273) );
  sky130_fd_sc_hd__nand3_1 U339 ( .A(n223), .B(n222), .C(n221), .Y(n758) );
  sky130_fd_sc_hd__nor2_1 U340 ( .A(n660), .B(n758), .Y(n224) );
  sky130_fd_sc_hd__inv_1 U341 ( .A(n224), .Y(n225) );
  sky130_fd_sc_hd__o21ai_1 U342 ( .A1(n295), .A2(n777), .B1(in1[2]), .Y(n227)
         );
  sky130_fd_sc_hd__o21ai_1 U343 ( .A1(n777), .A2(n234), .B1(n227), .Y(n739) );
  sky130_fd_sc_hd__inv_1 U344 ( .A(in1[1]), .Y(n228) );
  sky130_fd_sc_hd__nand2_1 U345 ( .A(n228), .B(n545), .Y(n640) );
  sky130_fd_sc_hd__nor2_1 U346 ( .A(in1[0]), .B(n640), .Y(n734) );
  sky130_fd_sc_hd__o21ai_1 U347 ( .A1(in1[0]), .A2(n295), .B1(n457), .Y(n732)
         );
  sky130_fd_sc_hd__o21ai_1 U348 ( .A1(n355), .A2(n734), .B1(n732), .Y(n343) );
  sky130_fd_sc_hd__and2_1 U349 ( .A(n343), .B(n644), .X(n229) );
  sky130_fd_sc_hd__a21oi_1 U350 ( .A1(n739), .A2(n230), .B1(n229), .Y(n242) );
  sky130_fd_sc_hd__o21ai_1 U351 ( .A1(n295), .A2(n301), .B1(in1[3]), .Y(n231)
         );
  sky130_fd_sc_hd__o21ai_0 U352 ( .A1(n301), .A2(n267), .B1(n231), .Y(n233) );
  sky130_fd_sc_hd__inv_1 U353 ( .A(n271), .Y(n232) );
  sky130_fd_sc_hd__nand2_1 U354 ( .A(n233), .B(n232), .Y(n239) );
  sky130_fd_sc_hd__nand2_1 U355 ( .A(n268), .B(n355), .Y(n236) );
  sky130_fd_sc_hd__xnor2_1 U356 ( .A(n8), .B(n15), .Y(n237) );
  sky130_fd_sc_hd__nand2_1 U357 ( .A(n237), .B(n271), .Y(n238) );
  sky130_fd_sc_hd__nor2_1 U358 ( .A(n7), .B(n741), .Y(n241) );
  sky130_fd_sc_hd__nand2_1 U359 ( .A(n741), .B(n7), .Y(n240) );
  sky130_fd_sc_hd__xnor2_1 U360 ( .A(n7), .B(n255), .Y(n243) );
  sky130_fd_sc_hd__xor2_1 U361 ( .A(n244), .B(n243), .X(n248) );
  sky130_fd_sc_hd__xnor2_1 U362 ( .A(n5), .B(n255), .Y(n245) );
  sky130_fd_sc_hd__xnor2_1 U363 ( .A(n246), .B(n245), .Y(n247) );
  sky130_fd_sc_hd__o22ai_2 U364 ( .A1(n248), .A2(n273), .B1(n247), .B2(n260), 
        .Y(n249) );
  sky130_fd_sc_hd__inv_1 U365 ( .A(n249), .Y(n259) );
  sky130_fd_sc_hd__nand2_1 U366 ( .A(n251), .B(n250), .Y(n252) );
  sky130_fd_sc_hd__xnor2_1 U367 ( .A(n445), .B(n252), .Y(n253) );
  sky130_fd_sc_hd__xnor2_1 U368 ( .A(n255), .B(n254), .Y(n256) );
  sky130_fd_sc_hd__nor2_1 U369 ( .A(n271), .B(n256), .Y(n257) );
  sky130_fd_sc_hd__inv_1 U370 ( .A(n257), .Y(n258) );
  sky130_fd_sc_hd__nand2_2 U371 ( .A(n259), .B(n258), .Y(n745) );
  sky130_fd_sc_hd__nor2_1 U372 ( .A(n16), .B(n745), .Y(n280) );
  sky130_fd_sc_hd__inv_2 U373 ( .A(n260), .Y(n276) );
  sky130_fd_sc_hd__xor2_1 U374 ( .A(n736), .B(n261), .X(n262) );
  sky130_fd_sc_hd__xnor2_1 U375 ( .A(n445), .B(n263), .Y(n265) );
  sky130_fd_sc_hd__xnor2_1 U376 ( .A(n265), .B(n264), .Y(n274) );
  sky130_fd_sc_hd__xnor2_1 U377 ( .A(n639), .B(n267), .Y(n269) );
  sky130_fd_sc_hd__nor2_1 U378 ( .A(n269), .B(n268), .Y(n270) );
  sky130_fd_sc_hd__xnor2_1 U379 ( .A(n266), .B(n270), .Y(n272) );
  sky130_fd_sc_hd__o22ai_2 U380 ( .A1(n274), .A2(n273), .B1(n272), .B2(n271), 
        .Y(n275) );
  sky130_fd_sc_hd__inv_2 U381 ( .A(n277), .Y(n748) );
  sky130_fd_sc_hd__nor2_1 U382 ( .A(n650), .B(n748), .Y(n278) );
  sky130_fd_sc_hd__nor2_1 U383 ( .A(n280), .B(n278), .Y(n283) );
  sky130_fd_sc_hd__nand2_1 U384 ( .A(n748), .B(n650), .Y(n281) );
  sky130_fd_sc_hd__clkbuf_1 U385 ( .A(n745), .X(n750) );
  sky130_fd_sc_hd__nand2_1 U386 ( .A(n750), .B(n16), .Y(n279) );
  sky130_fd_sc_hd__o21ai_1 U387 ( .A1(n281), .A2(n280), .B1(n279), .Y(n282) );
  sky130_fd_sc_hd__a21oi_1 U388 ( .A1(n284), .A2(n283), .B1(n282), .Y(n289) );
  sky130_fd_sc_hd__nand2_1 U389 ( .A(n758), .B(n660), .Y(n286) );
  sky130_fd_sc_hd__nand2_1 U390 ( .A(n12), .B(n17), .Y(n285) );
  sky130_fd_sc_hd__o21a_1 U391 ( .A1(n287), .A2(n286), .B1(n285), .X(n288) );
  sky130_fd_sc_hd__inv_1 U392 ( .A(op[0]), .Y(n552) );
  sky130_fd_sc_hd__inv_1 U393 ( .A(op[1]), .Y(n316) );
  sky130_fd_sc_hd__inv_1 U394 ( .A(op[2]), .Y(n291) );
  sky130_fd_sc_hd__nand4_1 U395 ( .A(n552), .B(op[3]), .C(n316), .D(n291), .Y(
        n778) );
  sky130_fd_sc_hd__inv_1 U396 ( .A(n778), .Y(n783) );
  sky130_fd_sc_hd__nor3_1 U397 ( .A(n294), .B(n293), .C(n292), .Y(n298) );
  sky130_fd_sc_hd__nand2_1 U398 ( .A(n298), .B(n295), .Y(n296) );
  sky130_fd_sc_hd__nand2_1 U399 ( .A(n783), .B(n296), .Y(n634) );
  sky130_fd_sc_hd__inv_1 U400 ( .A(n297), .Y(n678) );
  sky130_fd_sc_hd__nand2_1 U401 ( .A(n298), .B(n687), .Y(n699) );
  sky130_fd_sc_hd__nand3_1 U402 ( .A(n707), .B(n678), .C(n699), .Y(n299) );
  sky130_fd_sc_hd__nor4_1 U403 ( .A(n782), .B(n634), .C(n299), .D(invalid_data), .Y(n300) );
  sky130_fd_sc_hd__nand3_1 U404 ( .A(n777), .B(n301), .C(n300), .Y(n633) );
  sky130_fd_sc_hd__nor2_1 U405 ( .A(in1[3]), .B(n435), .Y(n305) );
  sky130_fd_sc_hd__nand2_1 U406 ( .A(n545), .B(in1[0]), .Y(n323) );
  sky130_fd_sc_hd__nor2_1 U407 ( .A(n457), .B(n355), .Y(n320) );
  sky130_fd_sc_hd__nand2_1 U408 ( .A(n355), .B(n457), .Y(n321) );
  sky130_fd_sc_hd__o21ai_1 U409 ( .A1(n323), .A2(n320), .B1(n321), .Y(n319) );
  sky130_fd_sc_hd__nor2_1 U410 ( .A(in1[2]), .B(n445), .Y(n302) );
  sky130_fd_sc_hd__inv_1 U411 ( .A(n302), .Y(n318) );
  sky130_fd_sc_hd__nand2_1 U412 ( .A(n445), .B(in1[2]), .Y(n317) );
  sky130_fd_sc_hd__inv_1 U413 ( .A(n317), .Y(n303) );
  sky130_fd_sc_hd__a21oi_2 U414 ( .A1(n319), .A2(n318), .B1(n303), .Y(n315) );
  sky130_fd_sc_hd__nand2_1 U415 ( .A(n435), .B(in1[3]), .Y(n304) );
  sky130_fd_sc_hd__o21ai_2 U416 ( .A1(n305), .A2(n315), .B1(n304), .Y(n314) );
  sky130_fd_sc_hd__or2_2 U417 ( .A(in1[4]), .B(n447), .X(n313) );
  sky130_fd_sc_hd__nand2_1 U418 ( .A(n447), .B(in1[4]), .Y(n312) );
  sky130_fd_sc_hd__inv_1 U419 ( .A(n312), .Y(n306) );
  sky130_fd_sc_hd__a21o_1 U420 ( .A1(n314), .A2(n313), .B1(n306), .X(n307) );
  sky130_fd_sc_hd__fa_2 U421 ( .A(n458), .B(in1[5]), .CIN(n307), .COUT(n308), 
        .SUM(n709) );
  sky130_fd_sc_hd__nor2_1 U422 ( .A(n637), .B(n687), .Y(n310) );
  sky130_fd_sc_hd__fa_2 U423 ( .A(in1[6]), .B(n513), .CIN(n308), .COUT(n311), 
        .SUM(n681) );
  sky130_fd_sc_hd__inv_1 U424 ( .A(n311), .Y(n309) );
  sky130_fd_sc_hd__nand2_1 U425 ( .A(n687), .B(n637), .Y(n599) );
  sky130_fd_sc_hd__o21ai_1 U426 ( .A1(n310), .A2(n309), .B1(n599), .Y(n794) );
  sky130_fd_sc_hd__xnor2_1 U427 ( .A(n687), .B(n637), .Y(n515) );
  sky130_fd_sc_hd__xnor2_1 U428 ( .A(n515), .B(n311), .Y(n701) );
  sky130_fd_sc_hd__nand2_1 U429 ( .A(n313), .B(n312), .Y(n336) );
  sky130_fd_sc_hd__xnor2_1 U430 ( .A(n336), .B(n314), .Y(n781) );
  sky130_fd_sc_hd__xnor2_1 U431 ( .A(in1[3]), .B(n435), .Y(n462) );
  sky130_fd_sc_hd__xor2_1 U432 ( .A(n315), .B(n462), .X(n693) );
  sky130_fd_sc_hd__xnor2_1 U433 ( .A(in1[0]), .B(n295), .Y(n729) );
  sky130_fd_sc_hd__nor2_1 U434 ( .A(op[3]), .B(op[2]), .Y(n341) );
  sky130_fd_sc_hd__nand3_1 U435 ( .A(n341), .B(op[0]), .C(n316), .Y(n667) );
  sky130_fd_sc_hd__nand2_1 U436 ( .A(n318), .B(n317), .Y(n342) );
  sky130_fd_sc_hd__xnor2_1 U437 ( .A(n342), .B(n319), .Y(n773) );
  sky130_fd_sc_hd__inv_1 U438 ( .A(n320), .Y(n322) );
  sky130_fd_sc_hd__nand2_1 U439 ( .A(n322), .B(n321), .Y(n430) );
  sky130_fd_sc_hd__xor2_1 U440 ( .A(n430), .B(n323), .X(n670) );
  sky130_fd_sc_hd__or4_1 U441 ( .A(n729), .B(n667), .C(n773), .D(n670), .X(
        n324) );
  sky130_fd_sc_hd__or4_1 U442 ( .A(invalid_data), .B(n781), .C(n693), .D(n324), 
        .X(n325) );
  sky130_fd_sc_hd__or4_4 U443 ( .A(n709), .B(n794), .C(n701), .D(n325), .X(
        n350) );
  sky130_fd_sc_hd__nor2_1 U444 ( .A(in1[3]), .B(n7), .Y(n328) );
  sky130_fd_sc_hd__a21oi_1 U445 ( .A1(n343), .A2(n11), .B1(n10), .Y(n340) );
  sky130_fd_sc_hd__nand2_1 U446 ( .A(n7), .B(in1[3]), .Y(n327) );
  sky130_fd_sc_hd__o21ai_1 U447 ( .A1(n328), .A2(n340), .B1(n327), .Y(n337) );
  sky130_fd_sc_hd__a21o_1 U448 ( .A1(n337), .A2(n329), .B1(n1), .X(n331) );
  sky130_fd_sc_hd__nand2_1 U449 ( .A(n514), .B(in1[6]), .Y(n332) );
  sky130_fd_sc_hd__inv_1 U450 ( .A(n332), .Y(n330) );
  sky130_fd_sc_hd__a21o_1 U451 ( .A1(n334), .A2(n333), .B1(n330), .X(n686) );
  sky130_fd_sc_hd__fa_1 U452 ( .A(in1[5]), .B(n16), .CIN(n331), .COUT(n334), 
        .SUM(n710) );
  sky130_fd_sc_hd__nand2_1 U453 ( .A(n333), .B(n332), .Y(n335) );
  sky130_fd_sc_hd__xnor2_1 U454 ( .A(n335), .B(n334), .Y(n680) );
  sky130_fd_sc_hd__xnor2_1 U455 ( .A(n338), .B(n337), .Y(n785) );
  sky130_fd_sc_hd__xor2_1 U456 ( .A(n340), .B(n339), .X(n692) );
  sky130_fd_sc_hd__nand3_1 U457 ( .A(n341), .B(op[1]), .C(n552), .Y(n668) );
  sky130_fd_sc_hd__xnor2_1 U458 ( .A(n344), .B(n343), .Y(n772) );
  sky130_fd_sc_hd__nor2_1 U459 ( .A(in1[0]), .B(n295), .Y(n345) );
  sky130_fd_sc_hd__xor2_1 U460 ( .A(n346), .B(n345), .X(n669) );
  sky130_fd_sc_hd__or4_1 U461 ( .A(n729), .B(n668), .C(n772), .D(n669), .X(
        n347) );
  sky130_fd_sc_hd__or4_1 U462 ( .A(invalid_data), .B(n785), .C(n692), .D(n347), 
        .X(n348) );
  sky130_fd_sc_hd__or3_1 U463 ( .A(n710), .B(n680), .C(n348), .X(n349) );
  sky130_fd_sc_hd__o22a_1 U464 ( .A1(n681), .A2(n350), .B1(n702), .B2(n349), 
        .X(n632) );
  sky130_fd_sc_hd__xor2_1 U465 ( .A(in1[5]), .B(in1[4]), .X(n351) );
  sky130_fd_sc_hd__xnor2_4 U466 ( .A(in1[4]), .B(in1[3]), .Y(n465) );
  sky130_fd_sc_hd__a21o_1 U467 ( .A1(n454), .A2(n465), .B1(n112), .X(n512) );
  sky130_fd_sc_hd__nor2_1 U468 ( .A(n25), .B(n352), .Y(n517) );
  sky130_fd_sc_hd__inv_1 U469 ( .A(n517), .Y(n359) );
  sky130_fd_sc_hd__xnor2_1 U470 ( .A(n687), .B(n513), .Y(n354) );
  sky130_fd_sc_hd__xnor2_4 U471 ( .A(in1[6]), .B(in1[5]), .Y(n600) );
  sky130_fd_sc_hd__xnor2_1 U472 ( .A(n687), .B(n458), .Y(n356) );
  sky130_fd_sc_hd__xor2_1 U473 ( .A(n687), .B(in1[6]), .X(n353) );
  sky130_fd_sc_hd__nand2_2 U474 ( .A(n600), .B(n353), .Y(n406) );
  sky130_fd_sc_hd__o22ai_1 U475 ( .A1(n354), .A2(n600), .B1(n356), .B2(n406), 
        .Y(n358) );
  sky130_fd_sc_hd__xnor2_1 U476 ( .A(n637), .B(in1[5]), .Y(n360) );
  sky130_fd_sc_hd__o22ai_1 U477 ( .A1(n112), .A2(n465), .B1(n360), .B2(n454), 
        .Y(n357) );
  sky130_fd_sc_hd__nor2_1 U478 ( .A(n25), .B(n16), .Y(n518) );
  sky130_fd_sc_hd__o22ai_1 U479 ( .A1(n515), .A2(n600), .B1(n354), .B2(n406), 
        .Y(n516) );
  sky130_fd_sc_hd__nor2_1 U480 ( .A(n25), .B(n7), .Y(n368) );
  sky130_fd_sc_hd__nor2_1 U481 ( .A(n25), .B(n639), .Y(n367) );
  sky130_fd_sc_hd__xnor2_1 U482 ( .A(n687), .B(n447), .Y(n363) );
  sky130_fd_sc_hd__o22ai_1 U483 ( .A1(n600), .A2(n356), .B1(n363), .B2(n406), 
        .Y(n366) );
  sky130_fd_sc_hd__fa_1 U484 ( .A(n359), .B(n358), .CIN(n357), .COUT(n511), 
        .SUM(n379) );
  sky130_fd_sc_hd__xnor2_1 U485 ( .A(n513), .B(in1[5]), .Y(n369) );
  sky130_fd_sc_hd__o22ai_1 U486 ( .A1(n465), .A2(n360), .B1(n369), .B2(n454), 
        .Y(n377) );
  sky130_fd_sc_hd__xor2_1 U487 ( .A(in1[3]), .B(in1[2]), .X(n361) );
  sky130_fd_sc_hd__xnor2_2 U488 ( .A(in1[2]), .B(in1[1]), .Y(n362) );
  sky130_fd_sc_hd__nand2_2 U489 ( .A(n361), .B(n362), .Y(n460) );
  sky130_fd_sc_hd__inv_1 U490 ( .A(n362), .Y(n370) );
  sky130_fd_sc_hd__inv_1 U491 ( .A(in1[3]), .Y(n439) );
  sky130_fd_sc_hd__a21o_1 U492 ( .A1(n460), .A2(n6), .B1(n439), .X(n376) );
  sky130_fd_sc_hd__inv_1 U493 ( .A(n445), .Y(n643) );
  sky130_fd_sc_hd__nor2_1 U494 ( .A(n25), .B(n643), .Y(n382) );
  sky130_fd_sc_hd__inv_1 U495 ( .A(n367), .Y(n395) );
  sky130_fd_sc_hd__xnor2_1 U496 ( .A(n687), .B(n435), .Y(n372) );
  sky130_fd_sc_hd__o22ai_1 U497 ( .A1(n600), .A2(n363), .B1(n372), .B2(n406), 
        .Y(n381) );
  sky130_fd_sc_hd__nor2_1 U498 ( .A(n364), .B(n365), .Y(n587) );
  sky130_fd_sc_hd__inv_1 U499 ( .A(n587), .Y(n524) );
  sky130_fd_sc_hd__nand2_1 U500 ( .A(n365), .B(n364), .Y(n591) );
  sky130_fd_sc_hd__nand2_1 U501 ( .A(n524), .B(n591), .Y(n509) );
  sky130_fd_sc_hd__xnor2_1 U502 ( .A(in1[5]), .B(n458), .Y(n371) );
  sky130_fd_sc_hd__o22ai_1 U503 ( .A1(n465), .A2(n369), .B1(n371), .B2(n454), 
        .Y(n388) );
  sky130_fd_sc_hd__xnor2_1 U504 ( .A(n637), .B(in1[3]), .Y(n383) );
  sky130_fd_sc_hd__o22ai_1 U505 ( .A1(n439), .A2(n6), .B1(n383), .B2(n460), 
        .Y(n387) );
  sky130_fd_sc_hd__xnor2_1 U506 ( .A(in1[5]), .B(n447), .Y(n384) );
  sky130_fd_sc_hd__xnor2_1 U507 ( .A(n687), .B(n445), .Y(n392) );
  sky130_fd_sc_hd__o22ai_1 U508 ( .A1(n600), .A2(n372), .B1(n392), .B2(n406), 
        .Y(n397) );
  sky130_fd_sc_hd__o21ai_1 U509 ( .A1(n395), .A2(n396), .B1(n397), .Y(n374) );
  sky130_fd_sc_hd__fah_1 U510 ( .A(n377), .B(n376), .CI(n375), .COUT(n378), 
        .SUM(n389) );
  sky130_fd_sc_hd__fah_1 U511 ( .A(n380), .B(n379), .CI(n378), .COUT(n365), 
        .SUM(n505) );
  sky130_fd_sc_hd__nor2_1 U512 ( .A(n504), .B(n505), .Y(n586) );
  sky130_fd_sc_hd__fa_1 U513 ( .A(n382), .B(n395), .CIN(n381), .COUT(n375), 
        .SUM(n404) );
  sky130_fd_sc_hd__xnor2_1 U514 ( .A(n513), .B(in1[3]), .Y(n385) );
  sky130_fd_sc_hd__o22ai_1 U515 ( .A1(n383), .A2(n6), .B1(n385), .B2(n460), 
        .Y(n401) );
  sky130_fd_sc_hd__nor2b_1 U516 ( .B_N(n545), .A(n25), .Y(n412) );
  sky130_fd_sc_hd__xnor2_1 U517 ( .A(in1[5]), .B(n435), .Y(n393) );
  sky130_fd_sc_hd__o22ai_1 U518 ( .A1(n465), .A2(n384), .B1(n393), .B2(n463), 
        .Y(n411) );
  sky130_fd_sc_hd__xnor2_1 U519 ( .A(in1[3]), .B(n458), .Y(n405) );
  sky130_fd_sc_hd__o22ai_1 U520 ( .A1(n385), .A2(n6), .B1(n405), .B2(n460), 
        .Y(n410) );
  sky130_fd_sc_hd__fa_2 U521 ( .A(n391), .B(n390), .CIN(n389), .COUT(n504), 
        .SUM(n503) );
  sky130_fd_sc_hd__nor2_1 U522 ( .A(n586), .B(n622), .Y(n522) );
  sky130_fd_sc_hd__inv_1 U523 ( .A(n522), .Y(n507) );
  sky130_fd_sc_hd__inv_1 U524 ( .A(n639), .Y(n437) );
  sky130_fd_sc_hd__xnor2_1 U525 ( .A(n687), .B(n437), .Y(n408) );
  sky130_fd_sc_hd__o22ai_1 U526 ( .A1(n600), .A2(n392), .B1(n408), .B2(n601), 
        .Y(n415) );
  sky130_fd_sc_hd__inv_1 U527 ( .A(in1[0]), .Y(n544) );
  sky130_fd_sc_hd__xnor2_1 U528 ( .A(n637), .B(n457), .Y(n409) );
  sky130_fd_sc_hd__nand2_2 U529 ( .A(n457), .B(n544), .Y(n468) );
  sky130_fd_sc_hd__o22ai_1 U530 ( .A1(n544), .A2(n228), .B1(n409), .B2(n468), 
        .Y(n414) );
  sky130_fd_sc_hd__xnor2_1 U531 ( .A(in1[5]), .B(n445), .Y(n422) );
  sky130_fd_sc_hd__o22ai_1 U532 ( .A1(n465), .A2(n393), .B1(n422), .B2(n454), 
        .Y(n420) );
  sky130_fd_sc_hd__nand2b_1 U533 ( .A_N(n545), .B(n687), .Y(n394) );
  sky130_fd_sc_hd__o22ai_1 U534 ( .A1(n600), .A2(n394), .B1(n25), .B2(n406), 
        .Y(n419) );
  sky130_fd_sc_hd__inv_1 U535 ( .A(n397), .Y(n398) );
  sky130_fd_sc_hd__fah_1 U536 ( .A(n401), .B(n228), .CI(n400), .COUT(n403), 
        .SUM(n416) );
  sky130_fd_sc_hd__fah_1 U537 ( .A(n404), .B(n403), .CI(n402), .COUT(n502), 
        .SUM(n499) );
  sky130_fd_sc_hd__nor2_1 U538 ( .A(n498), .B(n499), .Y(n577) );
  sky130_fd_sc_hd__xnor2_1 U539 ( .A(in1[3]), .B(n447), .Y(n421) );
  sky130_fd_sc_hd__o22ai_1 U540 ( .A1(n405), .A2(n6), .B1(n421), .B2(n460), 
        .Y(n425) );
  sky130_fd_sc_hd__xnor2_1 U541 ( .A(n687), .B(n545), .Y(n407) );
  sky130_fd_sc_hd__o22ai_1 U542 ( .A1(n600), .A2(n408), .B1(n407), .B2(n406), 
        .Y(n424) );
  sky130_fd_sc_hd__xnor2_1 U543 ( .A(n513), .B(n457), .Y(n470) );
  sky130_fd_sc_hd__o22ai_1 U544 ( .A1(n544), .A2(n409), .B1(n470), .B2(n468), 
        .Y(n423) );
  sky130_fd_sc_hd__fah_1 U545 ( .A(n415), .B(n414), .CI(n413), .COUT(n418), 
        .SUM(n426) );
  sky130_fd_sc_hd__fah_1 U546 ( .A(n418), .B(n417), .CI(n416), .COUT(n498), 
        .SUM(n497) );
  sky130_fd_sc_hd__nor2_1 U547 ( .A(n577), .B(n581), .Y(n501) );
  sky130_fd_sc_hd__ha_1 U548 ( .A(n420), .B(n419), .COUT(n413), .SUM(n489) );
  sky130_fd_sc_hd__nor2b_1 U549 ( .B_N(n545), .A(n600), .Y(n475) );
  sky130_fd_sc_hd__o22ai_1 U550 ( .A1(n6), .A2(n421), .B1(n462), .B2(n460), 
        .Y(n474) );
  sky130_fd_sc_hd__xnor2_1 U551 ( .A(in1[5]), .B(n437), .Y(n456) );
  sky130_fd_sc_hd__o22ai_1 U552 ( .A1(n465), .A2(n422), .B1(n456), .B2(n454), 
        .Y(n473) );
  sky130_fd_sc_hd__fa_1 U553 ( .A(n425), .B(n424), .CIN(n423), .COUT(n428), 
        .SUM(n487) );
  sky130_fd_sc_hd__fah_1 U554 ( .A(n428), .B(n427), .CI(n426), .COUT(n496), 
        .SUM(n495) );
  sky130_fd_sc_hd__nor2_1 U555 ( .A(n494), .B(n495), .Y(n572) );
  sky130_fd_sc_hd__nor2b_1 U556 ( .B_N(n545), .A(n6), .Y(n432) );
  sky130_fd_sc_hd__xnor2_1 U557 ( .A(n457), .B(n445), .Y(n436) );
  sky130_fd_sc_hd__o22ai_1 U558 ( .A1(n544), .A2(n436), .B1(n430), .B2(n468), 
        .Y(n433) );
  sky130_fd_sc_hd__nor2_1 U559 ( .A(n432), .B(n433), .Y(n429) );
  sky130_fd_sc_hd__inv_1 U560 ( .A(n429), .Y(n541) );
  sky130_fd_sc_hd__o22ai_1 U561 ( .A1(n544), .A2(n430), .B1(n545), .B2(n468), 
        .Y(n546) );
  sky130_fd_sc_hd__nand2b_1 U562 ( .A_N(n545), .B(n457), .Y(n431) );
  sky130_fd_sc_hd__nand2_1 U563 ( .A(n468), .B(n431), .Y(n547) );
  sky130_fd_sc_hd__nand2_1 U564 ( .A(n546), .B(n547), .Y(n549) );
  sky130_fd_sc_hd__inv_1 U565 ( .A(n549), .Y(n543) );
  sky130_fd_sc_hd__nand2_1 U566 ( .A(n433), .B(n432), .Y(n540) );
  sky130_fd_sc_hd__inv_1 U567 ( .A(n540), .Y(n434) );
  sky130_fd_sc_hd__a21oi_1 U568 ( .A1(n541), .A2(n543), .B1(n434), .Y(n538) );
  sky130_fd_sc_hd__xnor2_1 U569 ( .A(n457), .B(n435), .Y(n448) );
  sky130_fd_sc_hd__o22ai_1 U570 ( .A1(n544), .A2(n448), .B1(n436), .B2(n468), 
        .Y(n441) );
  sky130_fd_sc_hd__xnor2_1 U571 ( .A(in1[3]), .B(n437), .Y(n446) );
  sky130_fd_sc_hd__xnor2_1 U572 ( .A(in1[3]), .B(n545), .Y(n438) );
  sky130_fd_sc_hd__o22ai_1 U573 ( .A1(n6), .A2(n446), .B1(n438), .B2(n460), 
        .Y(n444) );
  sky130_fd_sc_hd__nand2b_1 U574 ( .A_N(n545), .B(in1[3]), .Y(n440) );
  sky130_fd_sc_hd__o22ai_1 U575 ( .A1(n440), .A2(n6), .B1(n439), .B2(n460), 
        .Y(n443) );
  sky130_fd_sc_hd__nor2_1 U576 ( .A(n441), .B(n442), .Y(n535) );
  sky130_fd_sc_hd__nand2_1 U577 ( .A(n442), .B(n441), .Y(n536) );
  sky130_fd_sc_hd__ha_1 U578 ( .A(n444), .B(n443), .COUT(n449), .SUM(n442) );
  sky130_fd_sc_hd__nor2b_1 U579 ( .B_N(n545), .A(n465), .Y(n453) );
  sky130_fd_sc_hd__xnor2_1 U580 ( .A(in1[3]), .B(n445), .Y(n461) );
  sky130_fd_sc_hd__o22ai_1 U581 ( .A1(n6), .A2(n461), .B1(n446), .B2(n460), 
        .Y(n452) );
  sky130_fd_sc_hd__xnor2_1 U582 ( .A(n457), .B(n447), .Y(n459) );
  sky130_fd_sc_hd__o22ai_1 U583 ( .A1(n544), .A2(n459), .B1(n448), .B2(n468), 
        .Y(n451) );
  sky130_fd_sc_hd__nor2_1 U584 ( .A(n449), .B(n450), .Y(n554) );
  sky130_fd_sc_hd__nand2_1 U585 ( .A(n450), .B(n449), .Y(n555) );
  sky130_fd_sc_hd__o21a_1 U586 ( .A1(n14), .A2(n554), .B1(n555), .X(n533) );
  sky130_fd_sc_hd__fah_1 U587 ( .A(n453), .B(n452), .CI(n451), .COUT(n466), 
        .SUM(n450) );
  sky130_fd_sc_hd__xnor2_1 U588 ( .A(in1[5]), .B(n545), .Y(n455) );
  sky130_fd_sc_hd__o22ai_1 U589 ( .A1(n465), .A2(n456), .B1(n455), .B2(n454), 
        .Y(n478) );
  sky130_fd_sc_hd__xnor2_1 U590 ( .A(n458), .B(n457), .Y(n469) );
  sky130_fd_sc_hd__o22ai_1 U591 ( .A1(n544), .A2(n469), .B1(n459), .B2(n468), 
        .Y(n477) );
  sky130_fd_sc_hd__o22ai_1 U592 ( .A1(n6), .A2(n462), .B1(n461), .B2(n460), 
        .Y(n472) );
  sky130_fd_sc_hd__nand2b_1 U593 ( .A_N(n545), .B(in1[5]), .Y(n464) );
  sky130_fd_sc_hd__o22ai_1 U594 ( .A1(n465), .A2(n464), .B1(n112), .B2(n463), 
        .Y(n471) );
  sky130_fd_sc_hd__nand2_1 U595 ( .A(n467), .B(n466), .Y(n531) );
  sky130_fd_sc_hd__o22ai_1 U596 ( .A1(n544), .A2(n470), .B1(n469), .B2(n468), 
        .Y(n486) );
  sky130_fd_sc_hd__ha_1 U597 ( .A(n472), .B(n471), .COUT(n485), .SUM(n476) );
  sky130_fd_sc_hd__fah_1 U598 ( .A(n475), .B(n474), .CI(n473), .COUT(n488), 
        .SUM(n484) );
  sky130_fd_sc_hd__inv_1 U599 ( .A(n482), .Y(n480) );
  sky130_fd_sc_hd__fah_1 U600 ( .A(n478), .B(n477), .CI(n476), .COUT(n481), 
        .SUM(n467) );
  sky130_fd_sc_hd__inv_1 U601 ( .A(n481), .Y(n479) );
  sky130_fd_sc_hd__nand2_1 U602 ( .A(n561), .B(n560), .Y(n483) );
  sky130_fd_sc_hd__nand2_1 U603 ( .A(n482), .B(n481), .Y(n559) );
  sky130_fd_sc_hd__nand2_1 U604 ( .A(n483), .B(n559), .Y(n566) );
  sky130_fd_sc_hd__fah_1 U605 ( .A(n486), .B(n485), .CI(n484), .COUT(n491), 
        .SUM(n482) );
  sky130_fd_sc_hd__fah_1 U606 ( .A(n489), .B(n488), .CI(n487), .COUT(n494), 
        .SUM(n492) );
  sky130_fd_sc_hd__nor2_1 U607 ( .A(n491), .B(n492), .Y(n490) );
  sky130_fd_sc_hd__inv_1 U608 ( .A(n490), .Y(n565) );
  sky130_fd_sc_hd__nand2_1 U609 ( .A(n492), .B(n491), .Y(n564) );
  sky130_fd_sc_hd__inv_1 U610 ( .A(n564), .Y(n493) );
  sky130_fd_sc_hd__a21oi_2 U611 ( .A1(n566), .A2(n565), .B1(n493), .Y(n575) );
  sky130_fd_sc_hd__nand2_1 U612 ( .A(n495), .B(n494), .Y(n573) );
  sky130_fd_sc_hd__nand2_1 U613 ( .A(n497), .B(n496), .Y(n580) );
  sky130_fd_sc_hd__nand2_1 U614 ( .A(n499), .B(n498), .Y(n578) );
  sky130_fd_sc_hd__o21ai_1 U615 ( .A1(n580), .A2(n577), .B1(n578), .Y(n500) );
  sky130_fd_sc_hd__a21o_1 U616 ( .A1(n501), .A2(n570), .B1(n500), .X(n588) );
  sky130_fd_sc_hd__inv_2 U617 ( .A(n588), .Y(n626) );
  sky130_fd_sc_hd__nand2_2 U618 ( .A(n503), .B(n502), .Y(n623) );
  sky130_fd_sc_hd__nand2_1 U619 ( .A(n505), .B(n504), .Y(n618) );
  sky130_fd_sc_hd__inv_1 U620 ( .A(n525), .Y(n506) );
  sky130_fd_sc_hd__o21ai_1 U621 ( .A1(n507), .A2(n626), .B1(n506), .Y(n508) );
  sky130_fd_sc_hd__xnor2_1 U622 ( .A(n509), .B(n508), .Y(n716) );
  sky130_fd_sc_hd__fah_1 U623 ( .A(n512), .B(n511), .CI(n510), .COUT(n519), 
        .SUM(n364) );
  sky130_fd_sc_hd__inv_1 U624 ( .A(n513), .Y(n514) );
  sky130_fd_sc_hd__nor2_1 U625 ( .A(n25), .B(n514), .Y(n603) );
  sky130_fd_sc_hd__inv_1 U626 ( .A(n603), .Y(n607) );
  sky130_fd_sc_hd__o22ai_1 U627 ( .A1(n25), .A2(n600), .B1(n515), .B2(n601), 
        .Y(n606) );
  sky130_fd_sc_hd__fa_1 U628 ( .A(n518), .B(n517), .CIN(n516), .COUT(n605), 
        .SUM(n510) );
  sky130_fd_sc_hd__nor2_1 U629 ( .A(n519), .B(n520), .Y(n592) );
  sky130_fd_sc_hd__inv_1 U630 ( .A(n592), .Y(n521) );
  sky130_fd_sc_hd__nand2_1 U631 ( .A(n520), .B(n519), .Y(n590) );
  sky130_fd_sc_hd__nand2_1 U632 ( .A(n521), .B(n590), .Y(n529) );
  sky130_fd_sc_hd__nand2_1 U633 ( .A(n522), .B(n524), .Y(n527) );
  sky130_fd_sc_hd__inv_1 U634 ( .A(n591), .Y(n523) );
  sky130_fd_sc_hd__a21oi_1 U635 ( .A1(n525), .A2(n524), .B1(n523), .Y(n526) );
  sky130_fd_sc_hd__o21ai_2 U636 ( .A1(n626), .A2(n527), .B1(n526), .Y(n528) );
  sky130_fd_sc_hd__xnor2_1 U637 ( .A(n529), .B(n528), .Y(n718) );
  sky130_fd_sc_hd__nor2_1 U638 ( .A(n716), .B(n718), .Y(n630) );
  sky130_fd_sc_hd__inv_1 U639 ( .A(n530), .Y(n532) );
  sky130_fd_sc_hd__nand2_1 U640 ( .A(n532), .B(n531), .Y(n534) );
  sky130_fd_sc_hd__xor2_1 U641 ( .A(n534), .B(n533), .X(n706) );
  sky130_fd_sc_hd__inv_1 U642 ( .A(n535), .Y(n537) );
  sky130_fd_sc_hd__nand2_1 U643 ( .A(n537), .B(n536), .Y(n539) );
  sky130_fd_sc_hd__xor2_1 U644 ( .A(n539), .B(n538), .X(n691) );
  sky130_fd_sc_hd__nand2_1 U645 ( .A(n541), .B(n540), .Y(n542) );
  sky130_fd_sc_hd__xnor2_1 U646 ( .A(n543), .B(n542), .Y(n775) );
  sky130_fd_sc_hd__nor2b_1 U647 ( .B_N(n545), .A(n544), .Y(n727) );
  sky130_fd_sc_hd__nor2_1 U648 ( .A(n547), .B(n546), .Y(n548) );
  sky130_fd_sc_hd__inv_1 U649 ( .A(n548), .Y(n550) );
  sky130_fd_sc_hd__nand2_1 U650 ( .A(n550), .B(n549), .Y(n551) );
  sky130_fd_sc_hd__inv_1 U651 ( .A(n551), .Y(n666) );
  sky130_fd_sc_hd__nor2_1 U652 ( .A(op[3]), .B(op[1]), .Y(n553) );
  sky130_fd_sc_hd__nand3_1 U653 ( .A(n553), .B(op[2]), .C(n552), .Y(n797) );
  sky130_fd_sc_hd__or4_4 U654 ( .A(n727), .B(n666), .C(n797), .D(invalid_data), 
        .X(n558) );
  sky130_fd_sc_hd__inv_1 U655 ( .A(n554), .Y(n556) );
  sky130_fd_sc_hd__nand2_1 U656 ( .A(n556), .B(n555), .Y(n557) );
  sky130_fd_sc_hd__xor2_1 U657 ( .A(n557), .B(n14), .X(n780) );
  sky130_fd_sc_hd__or4_4 U658 ( .A(n691), .B(n775), .C(n558), .D(n780), .X(
        n568) );
  sky130_fd_sc_hd__nand2_1 U659 ( .A(n560), .B(n559), .Y(n563) );
  sky130_fd_sc_hd__inv_1 U660 ( .A(n561), .Y(n562) );
  sky130_fd_sc_hd__xor2_1 U661 ( .A(n563), .B(n562), .X(n677) );
  sky130_fd_sc_hd__nand2_1 U662 ( .A(n565), .B(n564), .Y(n567) );
  sky130_fd_sc_hd__xnor2_1 U663 ( .A(n567), .B(n566), .Y(n698) );
  sky130_fd_sc_hd__nor4_1 U664 ( .A(n706), .B(n568), .C(n677), .D(n698), .Y(
        n585) );
  sky130_fd_sc_hd__inv_1 U665 ( .A(n581), .Y(n569) );
  sky130_fd_sc_hd__nand2_1 U666 ( .A(n569), .B(n580), .Y(n571) );
  sky130_fd_sc_hd__inv_1 U667 ( .A(n570), .Y(n582) );
  sky130_fd_sc_hd__xor2_1 U668 ( .A(n571), .B(n582), .X(n685) );
  sky130_fd_sc_hd__inv_1 U669 ( .A(n572), .Y(n574) );
  sky130_fd_sc_hd__nand2_1 U670 ( .A(n574), .B(n573), .Y(n576) );
  sky130_fd_sc_hd__xor2_1 U671 ( .A(n576), .B(n575), .X(n790) );
  sky130_fd_sc_hd__inv_1 U672 ( .A(n577), .Y(n579) );
  sky130_fd_sc_hd__nand2_1 U673 ( .A(n579), .B(n578), .Y(n584) );
  sky130_fd_sc_hd__o21ai_1 U674 ( .A1(n582), .A2(n581), .B1(n580), .Y(n583) );
  sky130_fd_sc_hd__xnor2_1 U675 ( .A(n584), .B(n583), .Y(n714) );
  sky130_fd_sc_hd__inv_1 U676 ( .A(n586), .Y(n619) );
  sky130_fd_sc_hd__nand2_1 U677 ( .A(n619), .B(n594), .Y(n597) );
  sky130_fd_sc_hd__nor2_1 U678 ( .A(n597), .B(n622), .Y(n589) );
  sky130_fd_sc_hd__nand2_1 U679 ( .A(n589), .B(n588), .Y(n598) );
  sky130_fd_sc_hd__inv_1 U680 ( .A(n618), .Y(n595) );
  sky130_fd_sc_hd__o21ai_1 U681 ( .A1(n592), .A2(n591), .B1(n590), .Y(n593) );
  sky130_fd_sc_hd__a21oi_1 U682 ( .A1(n595), .A2(n594), .B1(n593), .Y(n596) );
  sky130_fd_sc_hd__inv_1 U683 ( .A(n614), .Y(n613) );
  sky130_fd_sc_hd__a21o_1 U684 ( .A1(n601), .A2(n600), .B1(n25), .X(n602) );
  sky130_fd_sc_hd__xor3_1 U685 ( .A(n604), .B(n603), .C(n602), .X(n608) );
  sky130_fd_sc_hd__fa_1 U686 ( .A(n607), .B(n606), .CIN(n605), .COUT(n609), 
        .SUM(n520) );
  sky130_fd_sc_hd__nand2_1 U687 ( .A(n609), .B(n608), .Y(n610) );
  sky130_fd_sc_hd__nand2_1 U688 ( .A(n611), .B(n610), .Y(n615) );
  sky130_fd_sc_hd__inv_1 U689 ( .A(n615), .Y(n612) );
  sky130_fd_sc_hd__nand2_1 U690 ( .A(n615), .B(n614), .Y(n616) );
  sky130_fd_sc_hd__nand2_1 U691 ( .A(n619), .B(n618), .Y(n621) );
  sky130_fd_sc_hd__o21ai_2 U692 ( .A1(n626), .A2(n622), .B1(n623), .Y(n620) );
  sky130_fd_sc_hd__inv_1 U693 ( .A(n622), .Y(n624) );
  sky130_fd_sc_hd__nand2_1 U694 ( .A(n624), .B(n623), .Y(n625) );
  sky130_fd_sc_hd__xor2_1 U695 ( .A(n626), .B(n625), .X(n723) );
  sky130_fd_sc_hd__o211ai_2 U696 ( .A1(n725), .A2(n633), .B1(n632), .C1(n631), 
        .Y(zero) );
  sky130_fd_sc_hd__inv_1 U697 ( .A(invalid_data), .Y(n636) );
  sky130_fd_sc_hd__nand4_1 U698 ( .A(n634), .B(n797), .C(n667), .D(n668), .Y(
        n635) );
  sky130_fd_sc_hd__nand2_1 U699 ( .A(n636), .B(n635), .Y(error) );
  sky130_fd_sc_hd__nor2_1 U700 ( .A(n637), .B(n778), .Y(n766) );
  sky130_fd_sc_hd__inv_1 U701 ( .A(n766), .Y(n676) );
  sky130_fd_sc_hd__nor2_1 U702 ( .A(n652), .B(n638), .Y(n649) );
  sky130_fd_sc_hd__and2_1 U703 ( .A(n640), .B(n639), .X(n641) );
  sky130_fd_sc_hd__a21oi_1 U704 ( .A1(n739), .A2(n642), .B1(n641), .Y(n647) );
  sky130_fd_sc_hd__nor2_1 U705 ( .A(n643), .B(n741), .Y(n646) );
  sky130_fd_sc_hd__nand2_1 U706 ( .A(n741), .B(n644), .Y(n645) );
  sky130_fd_sc_hd__o21ai_1 U707 ( .A1(n647), .A2(n646), .B1(n645), .Y(n648) );
  sky130_fd_sc_hd__nand2_1 U708 ( .A(n649), .B(n648), .Y(n656) );
  sky130_fd_sc_hd__nand2_1 U709 ( .A(n748), .B(n7), .Y(n653) );
  sky130_fd_sc_hd__nand2_1 U710 ( .A(n745), .B(n650), .Y(n651) );
  sky130_fd_sc_hd__o21ai_1 U711 ( .A1(n653), .A2(n652), .B1(n651), .Y(n654) );
  sky130_fd_sc_hd__inv_1 U712 ( .A(n654), .Y(n655) );
  sky130_fd_sc_hd__nand2_1 U713 ( .A(n656), .B(n655), .Y(n659) );
  sky130_fd_sc_hd__nor2_1 U714 ( .A(n660), .B(n12), .Y(n663) );
  sky130_fd_sc_hd__nor2_1 U715 ( .A(n16), .B(n758), .Y(n657) );
  sky130_fd_sc_hd__nand2_1 U716 ( .A(n758), .B(n16), .Y(n662) );
  sky130_fd_sc_hd__nand2_1 U717 ( .A(n12), .B(n660), .Y(n661) );
  sky130_fd_sc_hd__o21a_1 U718 ( .A1(n663), .A2(n662), .B1(n661), .X(n664) );
  sky130_fd_sc_hd__inv_1 U719 ( .A(n724), .Y(n675) );
  sky130_fd_sc_hd__inv_1 U720 ( .A(n797), .Y(n779) );
  sky130_fd_sc_hd__nand2_1 U721 ( .A(n666), .B(n779), .Y(n672) );
  sky130_fd_sc_hd__inv_1 U722 ( .A(n667), .Y(n793) );
  sky130_fd_sc_hd__a22oi_1 U723 ( .A1(n670), .A2(n793), .B1(n669), .B2(n784), 
        .Y(n671) );
  sky130_fd_sc_hd__inv_1 U724 ( .A(error), .Y(n788) );
  sky130_fd_sc_hd__o21ai_1 U725 ( .A1(n676), .A2(n675), .B1(n674), .Y(out[1])
         );
  sky130_fd_sc_hd__nand2_1 U726 ( .A(n677), .B(n779), .Y(n684) );
  sky130_fd_sc_hd__a21oi_1 U727 ( .A1(n680), .A2(n784), .B1(n679), .Y(n683) );
  sky130_fd_sc_hd__nand2_1 U728 ( .A(n681), .B(n793), .Y(n682) );
  sky130_fd_sc_hd__nand3_1 U729 ( .A(n684), .B(n683), .C(n682), .Y(out[6]) );
  sky130_fd_sc_hd__inv_1 U730 ( .A(n685), .Y(n690) );
  sky130_fd_sc_hd__inv_1 U731 ( .A(n688), .Y(n689) );
  sky130_fd_sc_hd__o21ai_1 U732 ( .A1(n797), .A2(n690), .B1(n791), .Y(out[9])
         );
  sky130_fd_sc_hd__nand2_1 U733 ( .A(n691), .B(n779), .Y(n697) );
  sky130_fd_sc_hd__a22oi_1 U734 ( .A1(n693), .A2(n793), .B1(n692), .B2(n784), 
        .Y(n696) );
  sky130_fd_sc_hd__nand2_1 U735 ( .A(n694), .B(n783), .Y(n695) );
  sky130_fd_sc_hd__nand4_1 U736 ( .A(n697), .B(n788), .C(n696), .D(n695), .Y(
        out[3]) );
  sky130_fd_sc_hd__nand2_1 U737 ( .A(n698), .B(n779), .Y(n705) );
  sky130_fd_sc_hd__a21oi_1 U738 ( .A1(n701), .A2(n793), .B1(n700), .Y(n704) );
  sky130_fd_sc_hd__nand2_1 U739 ( .A(n702), .B(n784), .Y(n703) );
  sky130_fd_sc_hd__nand3_1 U740 ( .A(n705), .B(n704), .C(n703), .Y(out[7]) );
  sky130_fd_sc_hd__nand2_1 U741 ( .A(n706), .B(n779), .Y(n713) );
  sky130_fd_sc_hd__a21oi_1 U742 ( .A1(n709), .A2(n793), .B1(n708), .Y(n712) );
  sky130_fd_sc_hd__nand2_1 U743 ( .A(n710), .B(n784), .Y(n711) );
  sky130_fd_sc_hd__nand3_1 U744 ( .A(n713), .B(n712), .C(n711), .Y(out[5]) );
  sky130_fd_sc_hd__inv_1 U745 ( .A(n714), .Y(n715) );
  sky130_fd_sc_hd__o21ai_1 U746 ( .A1(n797), .A2(n715), .B1(n791), .Y(out[10])
         );
  sky130_fd_sc_hd__inv_1 U747 ( .A(n716), .Y(n717) );
  sky130_fd_sc_hd__o21ai_1 U748 ( .A1(n797), .A2(n717), .B1(n791), .Y(out[13])
         );
  sky130_fd_sc_hd__inv_1 U749 ( .A(n718), .Y(n719) );
  sky130_fd_sc_hd__o21ai_1 U750 ( .A1(n797), .A2(n719), .B1(n791), .Y(out[14])
         );
  sky130_fd_sc_hd__inv_1 U751 ( .A(n720), .Y(n721) );
  sky130_fd_sc_hd__o21ai_1 U752 ( .A1(n797), .A2(n721), .B1(n791), .Y(out[15])
         );
  sky130_fd_sc_hd__o21ai_1 U753 ( .A1(n797), .A2(n722), .B1(n791), .Y(out[12])
         );
  sky130_fd_sc_hd__o21ai_1 U754 ( .A1(n797), .A2(n4), .B1(n791), .Y(out[11])
         );
  sky130_fd_sc_hd__a22o_1 U755 ( .A1(n779), .A2(n727), .B1(n793), .B2(n729), 
        .X(n728) );
  sky130_fd_sc_hd__a211oi_1 U756 ( .A1(n729), .A2(n784), .B1(n728), .C1(error), 
        .Y(n770) );
  sky130_fd_sc_hd__nor2_1 U757 ( .A(n759), .B(n12), .Y(n762) );
  sky130_fd_sc_hd__nor2_1 U758 ( .A(n757), .B(n758), .Y(n730) );
  sky130_fd_sc_hd__nor2_1 U759 ( .A(n762), .B(n730), .Y(n731) );
  sky130_fd_sc_hd__inv_1 U760 ( .A(n731), .Y(n765) );
  sky130_fd_sc_hd__and2_1 U761 ( .A(n736), .B(n735), .X(n737) );
  sky130_fd_sc_hd__a21oi_1 U762 ( .A1(n739), .A2(n738), .B1(n737), .Y(n744) );
  sky130_fd_sc_hd__nor2_1 U763 ( .A(n740), .B(n741), .Y(n743) );
  sky130_fd_sc_hd__nand2_1 U764 ( .A(n741), .B(n740), .Y(n742) );
  sky130_fd_sc_hd__o21ai_0 U765 ( .A1(n744), .A2(n743), .B1(n742), .Y(n756) );
  sky130_fd_sc_hd__nor2_1 U766 ( .A(n749), .B(n745), .Y(n752) );
  sky130_fd_sc_hd__nor2_1 U767 ( .A(n747), .B(n748), .Y(n746) );
  sky130_fd_sc_hd__nor2_1 U768 ( .A(n752), .B(n746), .Y(n755) );
  sky130_fd_sc_hd__nand2_1 U769 ( .A(n748), .B(n747), .Y(n753) );
  sky130_fd_sc_hd__nand2_1 U770 ( .A(n750), .B(n749), .Y(n751) );
  sky130_fd_sc_hd__o21ai_1 U771 ( .A1(n753), .A2(n752), .B1(n751), .Y(n754) );
  sky130_fd_sc_hd__a21oi_1 U772 ( .A1(n756), .A2(n755), .B1(n754), .Y(n764) );
  sky130_fd_sc_hd__nand2_1 U773 ( .A(n758), .B(n757), .Y(n761) );
  sky130_fd_sc_hd__nand2_1 U774 ( .A(n12), .B(n759), .Y(n760) );
  sky130_fd_sc_hd__o21a_1 U775 ( .A1(n762), .A2(n761), .B1(n760), .X(n763) );
  sky130_fd_sc_hd__o21ai_1 U776 ( .A1(n765), .A2(n764), .B1(n763), .Y(n768) );
  sky130_fd_sc_hd__nand3_1 U777 ( .A(n768), .B(n767), .C(n766), .Y(n769) );
  sky130_fd_sc_hd__nand3_1 U778 ( .A(n771), .B(n770), .C(n769), .Y(out[0]) );
  sky130_fd_sc_hd__a22o_1 U779 ( .A1(n773), .A2(n793), .B1(n772), .B2(n784), 
        .X(n774) );
  sky130_fd_sc_hd__a211oi_1 U780 ( .A1(n775), .A2(n779), .B1(n774), .C1(error), 
        .Y(n776) );
  sky130_fd_sc_hd__o21ai_1 U781 ( .A1(n778), .A2(n777), .B1(n776), .Y(out[2])
         );
  sky130_fd_sc_hd__nand2_1 U782 ( .A(n780), .B(n779), .Y(n789) );
  sky130_fd_sc_hd__a22oi_1 U783 ( .A1(n783), .A2(n782), .B1(n781), .B2(n793), 
        .Y(n787) );
  sky130_fd_sc_hd__nand2_1 U784 ( .A(n785), .B(n784), .Y(n786) );
  sky130_fd_sc_hd__nand4_1 U785 ( .A(n789), .B(n788), .C(n787), .D(n786), .Y(
        out[4]) );
  sky130_fd_sc_hd__inv_1 U786 ( .A(n790), .Y(n796) );
  sky130_fd_sc_hd__inv_1 U787 ( .A(n791), .Y(n792) );
  sky130_fd_sc_hd__a21oi_1 U788 ( .A1(n794), .A2(n793), .B1(n792), .Y(n795) );
endmodule


module register_bank_WIDTH1_1 ( clk, rst, wr_en, in, out );
  input [0:0] in;
  output [0:0] out;
  input clk, rst, wr_en;
  wire   n3, n4, n1, n2, n5;

  sky130_fd_sc_hd__dfrtp_1 \out_reg[0]  ( .D(n4), .CLK(clk), .RESET_B(n3), .Q(
        out[0]) );
  sky130_fd_sc_hd__nand2_1 U2 ( .A(in[0]), .B(wr_en), .Y(n5) );
  sky130_fd_sc_hd__inv_1 U3 ( .A(out[0]), .Y(n1) );
  sky130_fd_sc_hd__or2_1 U4 ( .A(wr_en), .B(n1), .X(n2) );
  sky130_fd_sc_hd__nand2_1 U5 ( .A(n5), .B(n2), .Y(n4) );
  sky130_fd_sc_hd__inv_1 U6 ( .A(rst), .Y(n3) );
endmodule


module memory_WIDTH8 ( clk, memoryWrite, memoryRead, memoryWriteData, 
        memoryAddress, memoryOutData );
  input [15:0] memoryWriteData;
  input [7:0] memoryAddress;
  output [15:0] memoryOutData;
  input clk, memoryWrite, memoryRead;
  wire   \mem_array[0][15] , \mem_array[0][14] , \mem_array[0][13] ,
         \mem_array[0][12] , \mem_array[0][11] , \mem_array[0][10] ,
         \mem_array[0][9] , \mem_array[0][8] , \mem_array[0][7] ,
         \mem_array[0][6] , \mem_array[0][5] , \mem_array[0][4] ,
         \mem_array[0][3] , \mem_array[0][2] , \mem_array[0][1] ,
         \mem_array[0][0] , \mem_array[1][15] , \mem_array[1][14] ,
         \mem_array[1][13] , \mem_array[1][12] , \mem_array[1][11] ,
         \mem_array[1][10] , \mem_array[1][9] , \mem_array[1][8] ,
         \mem_array[1][7] , \mem_array[1][6] , \mem_array[1][5] ,
         \mem_array[1][4] , \mem_array[1][3] , \mem_array[1][2] ,
         \mem_array[1][1] , \mem_array[1][0] , \mem_array[2][15] ,
         \mem_array[2][14] , \mem_array[2][13] , \mem_array[2][12] ,
         \mem_array[2][11] , \mem_array[2][10] , \mem_array[2][9] ,
         \mem_array[2][8] , \mem_array[2][7] , \mem_array[2][6] ,
         \mem_array[2][5] , \mem_array[2][4] , \mem_array[2][3] ,
         \mem_array[2][2] , \mem_array[2][1] , \mem_array[2][0] ,
         \mem_array[3][15] , \mem_array[3][14] , \mem_array[3][13] ,
         \mem_array[3][12] , \mem_array[3][11] , \mem_array[3][10] ,
         \mem_array[3][9] , \mem_array[3][8] , \mem_array[3][7] ,
         \mem_array[3][6] , \mem_array[3][5] , \mem_array[3][4] ,
         \mem_array[3][3] , \mem_array[3][2] , \mem_array[3][1] ,
         \mem_array[3][0] , \mem_array[4][15] , \mem_array[4][14] ,
         \mem_array[4][13] , \mem_array[4][12] , \mem_array[4][11] ,
         \mem_array[4][10] , \mem_array[4][9] , \mem_array[4][8] ,
         \mem_array[4][7] , \mem_array[4][6] , \mem_array[4][5] ,
         \mem_array[4][4] , \mem_array[4][3] , \mem_array[4][2] ,
         \mem_array[4][1] , \mem_array[4][0] , \mem_array[5][15] ,
         \mem_array[5][14] , \mem_array[5][13] , \mem_array[5][12] ,
         \mem_array[5][11] , \mem_array[5][10] , \mem_array[5][9] ,
         \mem_array[5][8] , \mem_array[5][7] , \mem_array[5][6] ,
         \mem_array[5][5] , \mem_array[5][4] , \mem_array[5][3] ,
         \mem_array[5][2] , \mem_array[5][1] , \mem_array[5][0] ,
         \mem_array[6][15] , \mem_array[6][14] , \mem_array[6][13] ,
         \mem_array[6][12] , \mem_array[6][11] , \mem_array[6][10] ,
         \mem_array[6][9] , \mem_array[6][8] , \mem_array[6][7] ,
         \mem_array[6][6] , \mem_array[6][5] , \mem_array[6][4] ,
         \mem_array[6][3] , \mem_array[6][2] , \mem_array[6][1] ,
         \mem_array[6][0] , \mem_array[7][15] , \mem_array[7][14] ,
         \mem_array[7][13] , \mem_array[7][12] , \mem_array[7][11] ,
         \mem_array[7][10] , \mem_array[7][9] , \mem_array[7][8] ,
         \mem_array[7][7] , \mem_array[7][6] , \mem_array[7][5] ,
         \mem_array[7][4] , \mem_array[7][3] , \mem_array[7][2] ,
         \mem_array[7][1] , \mem_array[7][0] , n108, n109, n110, n111, n112,
         n113, n114, n115, n116, n117, n118, n119, n120, n121, n122, n123,
         n124, n125, n126, n127, n128, n129, n130, n131, n132, n133, n134,
         n135, n136, n137, n138, n139, n140, n141, n142, n143, n144, n145,
         n146, n147, n148, n149, n150, n151, n152, n153, n154, n155, n156,
         n157, n158, n159, n160, n161, n162, n163, n164, n165, n166, n167,
         n168, n169, n170, n171, n172, n173, n174, n175, n176, n177, n178,
         n179, n180, n181, n182, n183, n184, n185, n186, n187, n188, n189,
         n190, n191, n192, n193, n194, n195, n196, n197, n198, n199, n200,
         n201, n202, n203, n204, n205, n206, n207, n208, n209, n210, n211,
         n212, n213, n214, n215, n216, n217, n218, n219, n220, n221, n222,
         n223, n224, n225, n226, n227, n228, n229, n230, n231, n232, n233,
         n234, n235, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13,
         n14, n15, n16, n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27,
         n28, n29, n30, n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41,
         n42, n43, n44, n45, n46, n47, n48, n49, n50, n51, n52, n53, n54, n55,
         n56, n57, n58, n59, n60, n61, n62, n63, n64, n65, n66, n67, n68, n69,
         n70, n71, n72, n73, n74, n75, n76, n77, n78, n79, n80, n81, n82, n83,
         n84, n85, n86, n87, n88, n89, n90, n91, n92, n93, n94, n95, n96, n97,
         n98, n99, n100, n101, n102, n103, n104;

  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[0][15]  ( .D(n235), .CLK(clk), .Q(
        \mem_array[0][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[0][14]  ( .D(n234), .CLK(clk), .Q(
        \mem_array[0][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[0][13]  ( .D(n233), .CLK(clk), .Q(
        \mem_array[0][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[0][12]  ( .D(n232), .CLK(clk), .Q(
        \mem_array[0][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[0][11]  ( .D(n231), .CLK(clk), .Q(
        \mem_array[0][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[0][10]  ( .D(n230), .CLK(clk), .Q(
        \mem_array[0][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[0][9]  ( .D(n229), .CLK(clk), .Q(
        \mem_array[0][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[0][8]  ( .D(n228), .CLK(clk), .Q(
        \mem_array[0][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[0][7]  ( .D(n227), .CLK(clk), .Q(
        \mem_array[0][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[0][6]  ( .D(n226), .CLK(clk), .Q(
        \mem_array[0][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[0][5]  ( .D(n225), .CLK(clk), .Q(
        \mem_array[0][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[0][4]  ( .D(n224), .CLK(clk), .Q(
        \mem_array[0][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[0][3]  ( .D(n223), .CLK(clk), .Q(
        \mem_array[0][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[0][2]  ( .D(n222), .CLK(clk), .Q(
        \mem_array[0][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[0][1]  ( .D(n221), .CLK(clk), .Q(
        \mem_array[0][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[0][0]  ( .D(n220), .CLK(clk), .Q(
        \mem_array[0][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[1][15]  ( .D(n219), .CLK(clk), .Q(
        \mem_array[1][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[1][14]  ( .D(n218), .CLK(clk), .Q(
        \mem_array[1][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[1][13]  ( .D(n217), .CLK(clk), .Q(
        \mem_array[1][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[1][12]  ( .D(n216), .CLK(clk), .Q(
        \mem_array[1][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[1][11]  ( .D(n215), .CLK(clk), .Q(
        \mem_array[1][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[1][10]  ( .D(n214), .CLK(clk), .Q(
        \mem_array[1][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[1][9]  ( .D(n213), .CLK(clk), .Q(
        \mem_array[1][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[1][8]  ( .D(n212), .CLK(clk), .Q(
        \mem_array[1][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[1][7]  ( .D(n211), .CLK(clk), .Q(
        \mem_array[1][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[1][6]  ( .D(n210), .CLK(clk), .Q(
        \mem_array[1][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[1][5]  ( .D(n209), .CLK(clk), .Q(
        \mem_array[1][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[1][4]  ( .D(n208), .CLK(clk), .Q(
        \mem_array[1][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[1][3]  ( .D(n207), .CLK(clk), .Q(
        \mem_array[1][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[1][2]  ( .D(n206), .CLK(clk), .Q(
        \mem_array[1][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[1][1]  ( .D(n205), .CLK(clk), .Q(
        \mem_array[1][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[1][0]  ( .D(n204), .CLK(clk), .Q(
        \mem_array[1][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[2][15]  ( .D(n203), .CLK(clk), .Q(
        \mem_array[2][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[2][14]  ( .D(n202), .CLK(clk), .Q(
        \mem_array[2][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[2][13]  ( .D(n201), .CLK(clk), .Q(
        \mem_array[2][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[2][12]  ( .D(n200), .CLK(clk), .Q(
        \mem_array[2][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[2][11]  ( .D(n199), .CLK(clk), .Q(
        \mem_array[2][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[2][10]  ( .D(n198), .CLK(clk), .Q(
        \mem_array[2][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[2][9]  ( .D(n197), .CLK(clk), .Q(
        \mem_array[2][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[2][8]  ( .D(n196), .CLK(clk), .Q(
        \mem_array[2][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[2][7]  ( .D(n195), .CLK(clk), .Q(
        \mem_array[2][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[2][6]  ( .D(n194), .CLK(clk), .Q(
        \mem_array[2][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[2][5]  ( .D(n193), .CLK(clk), .Q(
        \mem_array[2][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[2][4]  ( .D(n192), .CLK(clk), .Q(
        \mem_array[2][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[2][3]  ( .D(n191), .CLK(clk), .Q(
        \mem_array[2][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[2][2]  ( .D(n190), .CLK(clk), .Q(
        \mem_array[2][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[2][1]  ( .D(n189), .CLK(clk), .Q(
        \mem_array[2][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[2][0]  ( .D(n188), .CLK(clk), .Q(
        \mem_array[2][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[3][15]  ( .D(n187), .CLK(clk), .Q(
        \mem_array[3][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[3][14]  ( .D(n186), .CLK(clk), .Q(
        \mem_array[3][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[3][13]  ( .D(n185), .CLK(clk), .Q(
        \mem_array[3][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[3][12]  ( .D(n184), .CLK(clk), .Q(
        \mem_array[3][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[3][11]  ( .D(n183), .CLK(clk), .Q(
        \mem_array[3][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[3][10]  ( .D(n182), .CLK(clk), .Q(
        \mem_array[3][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[3][9]  ( .D(n181), .CLK(clk), .Q(
        \mem_array[3][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[3][8]  ( .D(n180), .CLK(clk), .Q(
        \mem_array[3][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[3][7]  ( .D(n179), .CLK(clk), .Q(
        \mem_array[3][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[3][6]  ( .D(n178), .CLK(clk), .Q(
        \mem_array[3][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[3][5]  ( .D(n177), .CLK(clk), .Q(
        \mem_array[3][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[3][4]  ( .D(n176), .CLK(clk), .Q(
        \mem_array[3][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[3][3]  ( .D(n175), .CLK(clk), .Q(
        \mem_array[3][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[3][2]  ( .D(n174), .CLK(clk), .Q(
        \mem_array[3][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[3][1]  ( .D(n173), .CLK(clk), .Q(
        \mem_array[3][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[3][0]  ( .D(n172), .CLK(clk), .Q(
        \mem_array[3][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[4][15]  ( .D(n171), .CLK(clk), .Q(
        \mem_array[4][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[4][14]  ( .D(n170), .CLK(clk), .Q(
        \mem_array[4][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[4][13]  ( .D(n169), .CLK(clk), .Q(
        \mem_array[4][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[4][12]  ( .D(n168), .CLK(clk), .Q(
        \mem_array[4][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[4][11]  ( .D(n167), .CLK(clk), .Q(
        \mem_array[4][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[4][10]  ( .D(n166), .CLK(clk), .Q(
        \mem_array[4][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[4][9]  ( .D(n165), .CLK(clk), .Q(
        \mem_array[4][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[4][8]  ( .D(n164), .CLK(clk), .Q(
        \mem_array[4][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[4][7]  ( .D(n163), .CLK(clk), .Q(
        \mem_array[4][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[4][6]  ( .D(n162), .CLK(clk), .Q(
        \mem_array[4][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[4][5]  ( .D(n161), .CLK(clk), .Q(
        \mem_array[4][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[4][4]  ( .D(n160), .CLK(clk), .Q(
        \mem_array[4][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[4][3]  ( .D(n159), .CLK(clk), .Q(
        \mem_array[4][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[4][2]  ( .D(n158), .CLK(clk), .Q(
        \mem_array[4][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[4][1]  ( .D(n157), .CLK(clk), .Q(
        \mem_array[4][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[4][0]  ( .D(n156), .CLK(clk), .Q(
        \mem_array[4][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[5][15]  ( .D(n155), .CLK(clk), .Q(
        \mem_array[5][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[5][14]  ( .D(n154), .CLK(clk), .Q(
        \mem_array[5][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[5][13]  ( .D(n153), .CLK(clk), .Q(
        \mem_array[5][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[5][12]  ( .D(n152), .CLK(clk), .Q(
        \mem_array[5][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[5][11]  ( .D(n151), .CLK(clk), .Q(
        \mem_array[5][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[5][10]  ( .D(n150), .CLK(clk), .Q(
        \mem_array[5][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[5][9]  ( .D(n149), .CLK(clk), .Q(
        \mem_array[5][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[5][8]  ( .D(n148), .CLK(clk), .Q(
        \mem_array[5][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[5][7]  ( .D(n147), .CLK(clk), .Q(
        \mem_array[5][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[5][6]  ( .D(n146), .CLK(clk), .Q(
        \mem_array[5][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[5][5]  ( .D(n145), .CLK(clk), .Q(
        \mem_array[5][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[5][4]  ( .D(n144), .CLK(clk), .Q(
        \mem_array[5][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[5][3]  ( .D(n143), .CLK(clk), .Q(
        \mem_array[5][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[5][2]  ( .D(n142), .CLK(clk), .Q(
        \mem_array[5][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[5][1]  ( .D(n141), .CLK(clk), .Q(
        \mem_array[5][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[5][0]  ( .D(n140), .CLK(clk), .Q(
        \mem_array[5][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[6][15]  ( .D(n139), .CLK(clk), .Q(
        \mem_array[6][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[6][14]  ( .D(n138), .CLK(clk), .Q(
        \mem_array[6][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[6][13]  ( .D(n137), .CLK(clk), .Q(
        \mem_array[6][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[6][12]  ( .D(n136), .CLK(clk), .Q(
        \mem_array[6][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[6][11]  ( .D(n135), .CLK(clk), .Q(
        \mem_array[6][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[6][10]  ( .D(n134), .CLK(clk), .Q(
        \mem_array[6][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[6][9]  ( .D(n133), .CLK(clk), .Q(
        \mem_array[6][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[6][8]  ( .D(n132), .CLK(clk), .Q(
        \mem_array[6][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[6][7]  ( .D(n131), .CLK(clk), .Q(
        \mem_array[6][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[6][6]  ( .D(n130), .CLK(clk), .Q(
        \mem_array[6][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[6][5]  ( .D(n129), .CLK(clk), .Q(
        \mem_array[6][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[6][4]  ( .D(n128), .CLK(clk), .Q(
        \mem_array[6][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[6][3]  ( .D(n127), .CLK(clk), .Q(
        \mem_array[6][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[6][2]  ( .D(n126), .CLK(clk), .Q(
        \mem_array[6][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[6][1]  ( .D(n125), .CLK(clk), .Q(
        \mem_array[6][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[6][0]  ( .D(n124), .CLK(clk), .Q(
        \mem_array[6][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[7][15]  ( .D(n123), .CLK(clk), .Q(
        \mem_array[7][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[7][14]  ( .D(n122), .CLK(clk), .Q(
        \mem_array[7][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[7][13]  ( .D(n121), .CLK(clk), .Q(
        \mem_array[7][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[7][12]  ( .D(n120), .CLK(clk), .Q(
        \mem_array[7][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[7][11]  ( .D(n119), .CLK(clk), .Q(
        \mem_array[7][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[7][10]  ( .D(n118), .CLK(clk), .Q(
        \mem_array[7][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[7][9]  ( .D(n117), .CLK(clk), .Q(
        \mem_array[7][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[7][8]  ( .D(n116), .CLK(clk), .Q(
        \mem_array[7][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[7][7]  ( .D(n115), .CLK(clk), .Q(
        \mem_array[7][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[7][6]  ( .D(n114), .CLK(clk), .Q(
        \mem_array[7][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[7][5]  ( .D(n113), .CLK(clk), .Q(
        \mem_array[7][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[7][4]  ( .D(n112), .CLK(clk), .Q(
        \mem_array[7][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[7][3]  ( .D(n111), .CLK(clk), .Q(
        \mem_array[7][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[7][2]  ( .D(n110), .CLK(clk), .Q(
        \mem_array[7][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[7][1]  ( .D(n109), .CLK(clk), .Q(
        \mem_array[7][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_array_reg[7][0]  ( .D(n108), .CLK(clk), .Q(
        \mem_array[7][0] ) );
  sky130_fd_sc_hd__or2_2 U2 ( .A(n29), .B(n9), .X(n4) );
  sky130_fd_sc_hd__or2_2 U3 ( .A(n30), .B(n9), .X(n6) );
  sky130_fd_sc_hd__or2_2 U4 ( .A(n32), .B(n9), .X(n5) );
  sky130_fd_sc_hd__or3_1 U5 ( .A(memoryAddress[0]), .B(memoryAddress[1]), .C(
        n9), .X(n26) );
  sky130_fd_sc_hd__nand2_1 U6 ( .A(memoryWrite), .B(n27), .Y(n7) );
  sky130_fd_sc_hd__nor2_1 U7 ( .A(n28), .B(n30), .Y(n96) );
  sky130_fd_sc_hd__nor2_1 U8 ( .A(n28), .B(n29), .Y(n93) );
  sky130_fd_sc_hd__nor3_1 U9 ( .A(memoryAddress[0]), .B(memoryAddress[1]), .C(
        n31), .Y(n98) );
  sky130_fd_sc_hd__nor2_1 U10 ( .A(n29), .B(n31), .Y(n97) );
  sky130_fd_sc_hd__nor2_1 U11 ( .A(n28), .B(n32), .Y(n95) );
  sky130_fd_sc_hd__inv_1 U12 ( .A(memoryWriteData[5]), .Y(n10) );
  sky130_fd_sc_hd__nand2_1 U13 ( .A(memoryRead), .B(n27), .Y(n28) );
  sky130_fd_sc_hd__inv_2 U14 ( .A(memoryWriteData[15]), .Y(n13) );
  sky130_fd_sc_hd__inv_2 U15 ( .A(memoryWriteData[7]), .Y(n17) );
  sky130_fd_sc_hd__inv_2 U16 ( .A(memoryWriteData[1]), .Y(n23) );
  sky130_fd_sc_hd__inv_2 U17 ( .A(memoryWriteData[0]), .Y(n11) );
  sky130_fd_sc_hd__inv_2 U18 ( .A(memoryWriteData[8]), .Y(n12) );
  sky130_fd_sc_hd__inv_2 U19 ( .A(memoryWriteData[2]), .Y(n19) );
  sky130_fd_sc_hd__inv_2 U20 ( .A(memoryWriteData[9]), .Y(n15) );
  sky130_fd_sc_hd__inv_2 U21 ( .A(memoryWriteData[10]), .Y(n24) );
  sky130_fd_sc_hd__inv_2 U22 ( .A(memoryWriteData[6]), .Y(n18) );
  sky130_fd_sc_hd__inv_2 U23 ( .A(memoryWriteData[11]), .Y(n22) );
  sky130_fd_sc_hd__inv_2 U24 ( .A(memoryWriteData[3]), .Y(n25) );
  sky130_fd_sc_hd__inv_2 U25 ( .A(memoryWriteData[12]), .Y(n16) );
  sky130_fd_sc_hd__inv_2 U26 ( .A(memoryWriteData[14]), .Y(n20) );
  sky130_fd_sc_hd__inv_2 U27 ( .A(memoryWriteData[13]), .Y(n21) );
  sky130_fd_sc_hd__inv_2 U28 ( .A(memoryWriteData[4]), .Y(n14) );
  sky130_fd_sc_hd__nor3_1 U29 ( .A(memoryAddress[0]), .B(memoryAddress[1]), 
        .C(n28), .Y(n94) );
  sky130_fd_sc_hd__nand2b_1 U30 ( .A_N(memoryAddress[1]), .B(memoryAddress[0]), 
        .Y(n30) );
  sky130_fd_sc_hd__inv_1 U31 ( .A(memoryAddress[2]), .Y(n27) );
  sky130_fd_sc_hd__or2_4 U32 ( .A(n30), .B(n7), .X(n2) );
  sky130_fd_sc_hd__o2bb2ai_1 U33 ( .B1(n2), .B2(n20), .A1_N(n2), .A2_N(
        \mem_array[1][14] ), .Y(n218) );
  sky130_fd_sc_hd__o2bb2ai_1 U34 ( .B1(n2), .B2(n13), .A1_N(n2), .A2_N(
        \mem_array[1][15] ), .Y(n219) );
  sky130_fd_sc_hd__o2bb2ai_1 U35 ( .B1(n2), .B2(n16), .A1_N(n2), .A2_N(
        \mem_array[1][12] ), .Y(n216) );
  sky130_fd_sc_hd__nand2_1 U36 ( .A(memoryAddress[0]), .B(memoryAddress[1]), 
        .Y(n32) );
  sky130_fd_sc_hd__or2_4 U37 ( .A(n32), .B(n7), .X(n3) );
  sky130_fd_sc_hd__o2bb2ai_1 U38 ( .B1(n3), .B2(n11), .A1_N(n3), .A2_N(
        \mem_array[3][0] ), .Y(n172) );
  sky130_fd_sc_hd__nand2b_1 U39 ( .A_N(memoryAddress[0]), .B(memoryAddress[1]), 
        .Y(n29) );
  sky130_fd_sc_hd__or2_4 U40 ( .A(n29), .B(n7), .X(n1) );
  sky130_fd_sc_hd__o2bb2ai_1 U41 ( .B1(n1), .B2(n23), .A1_N(n1), .A2_N(
        \mem_array[2][1] ), .Y(n189) );
  sky130_fd_sc_hd__o2bb2ai_1 U42 ( .B1(n2), .B2(n11), .A1_N(n2), .A2_N(
        \mem_array[1][0] ), .Y(n204) );
  sky130_fd_sc_hd__o2bb2ai_1 U43 ( .B1(n3), .B2(n13), .A1_N(n3), .A2_N(
        \mem_array[3][15] ), .Y(n187) );
  sky130_fd_sc_hd__o2bb2ai_1 U44 ( .B1(n1), .B2(n20), .A1_N(n1), .A2_N(
        \mem_array[2][14] ), .Y(n202) );
  sky130_fd_sc_hd__o2bb2ai_1 U45 ( .B1(n3), .B2(n21), .A1_N(n3), .A2_N(
        \mem_array[3][13] ), .Y(n185) );
  sky130_fd_sc_hd__o2bb2ai_1 U46 ( .B1(n1), .B2(n16), .A1_N(n1), .A2_N(
        \mem_array[2][12] ), .Y(n200) );
  sky130_fd_sc_hd__o2bb2ai_1 U47 ( .B1(n3), .B2(n22), .A1_N(n3), .A2_N(
        \mem_array[3][11] ), .Y(n183) );
  sky130_fd_sc_hd__o2bb2ai_1 U48 ( .B1(n2), .B2(n19), .A1_N(n2), .A2_N(
        \mem_array[1][2] ), .Y(n206) );
  sky130_fd_sc_hd__o2bb2ai_1 U49 ( .B1(n3), .B2(n15), .A1_N(n3), .A2_N(
        \mem_array[3][9] ), .Y(n181) );
  sky130_fd_sc_hd__o2bb2ai_1 U50 ( .B1(n1), .B2(n12), .A1_N(n1), .A2_N(
        \mem_array[2][8] ), .Y(n196) );
  sky130_fd_sc_hd__o2bb2ai_1 U51 ( .B1(n3), .B2(n17), .A1_N(n3), .A2_N(
        \mem_array[3][7] ), .Y(n179) );
  sky130_fd_sc_hd__o2bb2ai_1 U52 ( .B1(n1), .B2(n18), .A1_N(n1), .A2_N(
        \mem_array[2][6] ), .Y(n194) );
  sky130_fd_sc_hd__o2bb2ai_1 U53 ( .B1(n3), .B2(n10), .A1_N(n3), .A2_N(
        \mem_array[3][5] ), .Y(n177) );
  sky130_fd_sc_hd__o2bb2ai_1 U54 ( .B1(n1), .B2(n14), .A1_N(n1), .A2_N(
        \mem_array[2][4] ), .Y(n192) );
  sky130_fd_sc_hd__o2bb2ai_1 U55 ( .B1(n3), .B2(n25), .A1_N(n3), .A2_N(
        \mem_array[3][3] ), .Y(n175) );
  sky130_fd_sc_hd__o2bb2ai_1 U56 ( .B1(n1), .B2(n24), .A1_N(n1), .A2_N(
        \mem_array[2][10] ), .Y(n198) );
  sky130_fd_sc_hd__o2bb2ai_1 U57 ( .B1(n2), .B2(n22), .A1_N(n2), .A2_N(
        \mem_array[1][11] ), .Y(n215) );
  sky130_fd_sc_hd__o2bb2ai_1 U58 ( .B1(n2), .B2(n21), .A1_N(n2), .A2_N(
        \mem_array[1][13] ), .Y(n217) );
  sky130_fd_sc_hd__o2bb2ai_1 U59 ( .B1(n2), .B2(n15), .A1_N(n2), .A2_N(
        \mem_array[1][9] ), .Y(n213) );
  sky130_fd_sc_hd__o2bb2ai_1 U60 ( .B1(n2), .B2(n12), .A1_N(n2), .A2_N(
        \mem_array[1][8] ), .Y(n212) );
  sky130_fd_sc_hd__o2bb2ai_1 U61 ( .B1(n2), .B2(n17), .A1_N(n2), .A2_N(
        \mem_array[1][7] ), .Y(n211) );
  sky130_fd_sc_hd__o2bb2ai_1 U62 ( .B1(n2), .B2(n18), .A1_N(n2), .A2_N(
        \mem_array[1][6] ), .Y(n210) );
  sky130_fd_sc_hd__o2bb2ai_1 U63 ( .B1(n2), .B2(n10), .A1_N(n2), .A2_N(
        \mem_array[1][5] ), .Y(n209) );
  sky130_fd_sc_hd__o2bb2ai_1 U64 ( .B1(n2), .B2(n14), .A1_N(n2), .A2_N(
        \mem_array[1][4] ), .Y(n208) );
  sky130_fd_sc_hd__o2bb2ai_1 U65 ( .B1(n2), .B2(n25), .A1_N(n2), .A2_N(
        \mem_array[1][3] ), .Y(n207) );
  sky130_fd_sc_hd__o2bb2ai_1 U66 ( .B1(n1), .B2(n19), .A1_N(n1), .A2_N(
        \mem_array[2][2] ), .Y(n190) );
  sky130_fd_sc_hd__o2bb2ai_1 U67 ( .B1(n2), .B2(n23), .A1_N(n2), .A2_N(
        \mem_array[1][1] ), .Y(n205) );
  sky130_fd_sc_hd__o2bb2ai_1 U68 ( .B1(n1), .B2(n11), .A1_N(n1), .A2_N(
        \mem_array[2][0] ), .Y(n188) );
  sky130_fd_sc_hd__o2bb2ai_1 U69 ( .B1(n1), .B2(n13), .A1_N(n1), .A2_N(
        \mem_array[2][15] ), .Y(n203) );
  sky130_fd_sc_hd__o2bb2ai_1 U70 ( .B1(n3), .B2(n20), .A1_N(n3), .A2_N(
        \mem_array[3][14] ), .Y(n186) );
  sky130_fd_sc_hd__o2bb2ai_1 U71 ( .B1(n1), .B2(n21), .A1_N(n1), .A2_N(
        \mem_array[2][13] ), .Y(n201) );
  sky130_fd_sc_hd__o2bb2ai_1 U72 ( .B1(n3), .B2(n23), .A1_N(n3), .A2_N(
        \mem_array[3][1] ), .Y(n173) );
  sky130_fd_sc_hd__o2bb2ai_1 U73 ( .B1(n1), .B2(n22), .A1_N(n1), .A2_N(
        \mem_array[2][11] ), .Y(n199) );
  sky130_fd_sc_hd__o2bb2ai_1 U74 ( .B1(n3), .B2(n24), .A1_N(n3), .A2_N(
        \mem_array[3][10] ), .Y(n182) );
  sky130_fd_sc_hd__o2bb2ai_1 U75 ( .B1(n1), .B2(n15), .A1_N(n1), .A2_N(
        \mem_array[2][9] ), .Y(n197) );
  sky130_fd_sc_hd__o2bb2ai_1 U76 ( .B1(n3), .B2(n12), .A1_N(n3), .A2_N(
        \mem_array[3][8] ), .Y(n180) );
  sky130_fd_sc_hd__o2bb2ai_1 U77 ( .B1(n1), .B2(n17), .A1_N(n1), .A2_N(
        \mem_array[2][7] ), .Y(n195) );
  sky130_fd_sc_hd__o2bb2ai_1 U78 ( .B1(n3), .B2(n18), .A1_N(n3), .A2_N(
        \mem_array[3][6] ), .Y(n178) );
  sky130_fd_sc_hd__o2bb2ai_1 U79 ( .B1(n1), .B2(n10), .A1_N(n1), .A2_N(
        \mem_array[2][5] ), .Y(n193) );
  sky130_fd_sc_hd__o2bb2ai_1 U80 ( .B1(n3), .B2(n16), .A1_N(n3), .A2_N(
        \mem_array[3][12] ), .Y(n184) );
  sky130_fd_sc_hd__o2bb2ai_1 U81 ( .B1(n1), .B2(n25), .A1_N(n1), .A2_N(
        \mem_array[2][3] ), .Y(n191) );
  sky130_fd_sc_hd__o2bb2ai_1 U82 ( .B1(n3), .B2(n19), .A1_N(n3), .A2_N(
        \mem_array[3][2] ), .Y(n174) );
  sky130_fd_sc_hd__o2bb2ai_1 U83 ( .B1(n2), .B2(n24), .A1_N(n2), .A2_N(
        \mem_array[1][10] ), .Y(n214) );
  sky130_fd_sc_hd__o2bb2ai_1 U84 ( .B1(n3), .B2(n14), .A1_N(n3), .A2_N(
        \mem_array[3][4] ), .Y(n176) );
  sky130_fd_sc_hd__nand2_1 U85 ( .A(memoryAddress[2]), .B(memoryWrite), .Y(n9)
         );
  sky130_fd_sc_hd__o2bb2ai_1 U86 ( .B1(n5), .B2(n21), .A1_N(n5), .A2_N(
        \mem_array[7][13] ), .Y(n121) );
  sky130_fd_sc_hd__o2bb2ai_1 U87 ( .B1(n4), .B2(n13), .A1_N(n4), .A2_N(
        \mem_array[6][15] ), .Y(n139) );
  sky130_fd_sc_hd__o2bb2ai_1 U88 ( .B1(n4), .B2(n20), .A1_N(n4), .A2_N(
        \mem_array[6][14] ), .Y(n138) );
  sky130_fd_sc_hd__o2bb2ai_1 U89 ( .B1(n4), .B2(n21), .A1_N(n4), .A2_N(
        \mem_array[6][13] ), .Y(n137) );
  sky130_fd_sc_hd__o2bb2ai_1 U90 ( .B1(n4), .B2(n16), .A1_N(n4), .A2_N(
        \mem_array[6][12] ), .Y(n136) );
  sky130_fd_sc_hd__o2bb2ai_1 U91 ( .B1(n4), .B2(n22), .A1_N(n4), .A2_N(
        \mem_array[6][11] ), .Y(n135) );
  sky130_fd_sc_hd__o2bb2ai_1 U92 ( .B1(n4), .B2(n24), .A1_N(n4), .A2_N(
        \mem_array[6][10] ), .Y(n134) );
  sky130_fd_sc_hd__o2bb2ai_1 U93 ( .B1(n4), .B2(n15), .A1_N(n4), .A2_N(
        \mem_array[6][9] ), .Y(n133) );
  sky130_fd_sc_hd__o2bb2ai_1 U94 ( .B1(n4), .B2(n12), .A1_N(n4), .A2_N(
        \mem_array[6][8] ), .Y(n132) );
  sky130_fd_sc_hd__o2bb2ai_1 U95 ( .B1(n4), .B2(n17), .A1_N(n4), .A2_N(
        \mem_array[6][7] ), .Y(n131) );
  sky130_fd_sc_hd__o2bb2ai_1 U96 ( .B1(n4), .B2(n18), .A1_N(n4), .A2_N(
        \mem_array[6][6] ), .Y(n130) );
  sky130_fd_sc_hd__o2bb2ai_1 U97 ( .B1(n4), .B2(n10), .A1_N(n4), .A2_N(
        \mem_array[6][5] ), .Y(n129) );
  sky130_fd_sc_hd__o2bb2ai_1 U98 ( .B1(n4), .B2(n14), .A1_N(n4), .A2_N(
        \mem_array[6][4] ), .Y(n128) );
  sky130_fd_sc_hd__o2bb2ai_1 U99 ( .B1(n4), .B2(n25), .A1_N(n4), .A2_N(
        \mem_array[6][3] ), .Y(n127) );
  sky130_fd_sc_hd__o2bb2ai_1 U100 ( .B1(n4), .B2(n19), .A1_N(n4), .A2_N(
        \mem_array[6][2] ), .Y(n126) );
  sky130_fd_sc_hd__o2bb2ai_1 U101 ( .B1(n4), .B2(n23), .A1_N(n4), .A2_N(
        \mem_array[6][1] ), .Y(n125) );
  sky130_fd_sc_hd__o2bb2ai_1 U102 ( .B1(n4), .B2(n11), .A1_N(n4), .A2_N(
        \mem_array[6][0] ), .Y(n124) );
  sky130_fd_sc_hd__o2bb2ai_1 U103 ( .B1(n5), .B2(n13), .A1_N(n5), .A2_N(
        \mem_array[7][15] ), .Y(n123) );
  sky130_fd_sc_hd__o2bb2ai_1 U104 ( .B1(n5), .B2(n20), .A1_N(n5), .A2_N(
        \mem_array[7][14] ), .Y(n122) );
  sky130_fd_sc_hd__o2bb2ai_1 U105 ( .B1(n5), .B2(n17), .A1_N(n5), .A2_N(
        \mem_array[7][7] ), .Y(n115) );
  sky130_fd_sc_hd__o2bb2ai_1 U106 ( .B1(n5), .B2(n16), .A1_N(n5), .A2_N(
        \mem_array[7][12] ), .Y(n120) );
  sky130_fd_sc_hd__o2bb2ai_1 U107 ( .B1(n5), .B2(n22), .A1_N(n5), .A2_N(
        \mem_array[7][11] ), .Y(n119) );
  sky130_fd_sc_hd__o2bb2ai_1 U108 ( .B1(n5), .B2(n24), .A1_N(n5), .A2_N(
        \mem_array[7][10] ), .Y(n118) );
  sky130_fd_sc_hd__o2bb2ai_1 U109 ( .B1(n5), .B2(n15), .A1_N(n5), .A2_N(
        \mem_array[7][9] ), .Y(n117) );
  sky130_fd_sc_hd__o2bb2ai_1 U110 ( .B1(n5), .B2(n12), .A1_N(n5), .A2_N(
        \mem_array[7][8] ), .Y(n116) );
  sky130_fd_sc_hd__o2bb2ai_1 U111 ( .B1(n5), .B2(n23), .A1_N(n5), .A2_N(
        \mem_array[7][1] ), .Y(n109) );
  sky130_fd_sc_hd__o2bb2ai_1 U112 ( .B1(n5), .B2(n18), .A1_N(n5), .A2_N(
        \mem_array[7][6] ), .Y(n114) );
  sky130_fd_sc_hd__o2bb2ai_1 U113 ( .B1(n5), .B2(n10), .A1_N(n5), .A2_N(
        \mem_array[7][5] ), .Y(n113) );
  sky130_fd_sc_hd__o2bb2ai_1 U114 ( .B1(n5), .B2(n14), .A1_N(n5), .A2_N(
        \mem_array[7][4] ), .Y(n112) );
  sky130_fd_sc_hd__o2bb2ai_1 U115 ( .B1(n5), .B2(n25), .A1_N(n5), .A2_N(
        \mem_array[7][3] ), .Y(n111) );
  sky130_fd_sc_hd__o2bb2ai_1 U116 ( .B1(n5), .B2(n19), .A1_N(n5), .A2_N(
        \mem_array[7][2] ), .Y(n110) );
  sky130_fd_sc_hd__o2bb2ai_1 U117 ( .B1(n5), .B2(n11), .A1_N(n5), .A2_N(
        \mem_array[7][0] ), .Y(n108) );
  sky130_fd_sc_hd__o2bb2ai_1 U118 ( .B1(n6), .B2(n21), .A1_N(n6), .A2_N(
        \mem_array[5][13] ), .Y(n153) );
  sky130_fd_sc_hd__o2bb2ai_1 U119 ( .B1(n6), .B2(n25), .A1_N(n6), .A2_N(
        \mem_array[5][3] ), .Y(n143) );
  sky130_fd_sc_hd__o2bb2ai_1 U120 ( .B1(n6), .B2(n20), .A1_N(n6), .A2_N(
        \mem_array[5][14] ), .Y(n154) );
  sky130_fd_sc_hd__o2bb2ai_1 U121 ( .B1(n6), .B2(n13), .A1_N(n6), .A2_N(
        \mem_array[5][15] ), .Y(n155) );
  sky130_fd_sc_hd__o2bb2ai_1 U122 ( .B1(n6), .B2(n11), .A1_N(n6), .A2_N(
        \mem_array[5][0] ), .Y(n140) );
  sky130_fd_sc_hd__o2bb2ai_1 U123 ( .B1(n6), .B2(n17), .A1_N(n6), .A2_N(
        \mem_array[5][7] ), .Y(n147) );
  sky130_fd_sc_hd__o2bb2ai_1 U124 ( .B1(n6), .B2(n16), .A1_N(n6), .A2_N(
        \mem_array[5][12] ), .Y(n152) );
  sky130_fd_sc_hd__o2bb2ai_1 U125 ( .B1(n6), .B2(n22), .A1_N(n6), .A2_N(
        \mem_array[5][11] ), .Y(n151) );
  sky130_fd_sc_hd__o2bb2ai_1 U126 ( .B1(n6), .B2(n24), .A1_N(n6), .A2_N(
        \mem_array[5][10] ), .Y(n150) );
  sky130_fd_sc_hd__o2bb2ai_1 U127 ( .B1(n6), .B2(n15), .A1_N(n6), .A2_N(
        \mem_array[5][9] ), .Y(n149) );
  sky130_fd_sc_hd__o2bb2ai_1 U128 ( .B1(n6), .B2(n12), .A1_N(n6), .A2_N(
        \mem_array[5][8] ), .Y(n148) );
  sky130_fd_sc_hd__o2bb2ai_1 U129 ( .B1(n6), .B2(n23), .A1_N(n6), .A2_N(
        \mem_array[5][1] ), .Y(n141) );
  sky130_fd_sc_hd__o2bb2ai_1 U130 ( .B1(n6), .B2(n18), .A1_N(n6), .A2_N(
        \mem_array[5][6] ), .Y(n146) );
  sky130_fd_sc_hd__o2bb2ai_1 U131 ( .B1(n6), .B2(n10), .A1_N(n6), .A2_N(
        \mem_array[5][5] ), .Y(n145) );
  sky130_fd_sc_hd__o2bb2ai_1 U132 ( .B1(n6), .B2(n14), .A1_N(n6), .A2_N(
        \mem_array[5][4] ), .Y(n144) );
  sky130_fd_sc_hd__o2bb2ai_1 U133 ( .B1(n6), .B2(n19), .A1_N(n6), .A2_N(
        \mem_array[5][2] ), .Y(n142) );
  sky130_fd_sc_hd__or3_4 U134 ( .A(memoryAddress[0]), .B(memoryAddress[1]), 
        .C(n7), .X(n8) );
  sky130_fd_sc_hd__o2bb2ai_1 U135 ( .B1(n8), .B2(n20), .A1_N(n8), .A2_N(
        \mem_array[0][14] ), .Y(n234) );
  sky130_fd_sc_hd__o2bb2ai_1 U136 ( .B1(n8), .B2(n21), .A1_N(n8), .A2_N(
        \mem_array[0][13] ), .Y(n233) );
  sky130_fd_sc_hd__o2bb2ai_1 U137 ( .B1(n8), .B2(n16), .A1_N(n8), .A2_N(
        \mem_array[0][12] ), .Y(n232) );
  sky130_fd_sc_hd__o2bb2ai_1 U138 ( .B1(n8), .B2(n13), .A1_N(n8), .A2_N(
        \mem_array[0][15] ), .Y(n235) );
  sky130_fd_sc_hd__o2bb2ai_1 U139 ( .B1(n8), .B2(n22), .A1_N(n8), .A2_N(
        \mem_array[0][11] ), .Y(n231) );
  sky130_fd_sc_hd__o2bb2ai_1 U140 ( .B1(n8), .B2(n24), .A1_N(n8), .A2_N(
        \mem_array[0][10] ), .Y(n230) );
  sky130_fd_sc_hd__o2bb2ai_1 U141 ( .B1(n8), .B2(n15), .A1_N(n8), .A2_N(
        \mem_array[0][9] ), .Y(n229) );
  sky130_fd_sc_hd__o2bb2ai_1 U142 ( .B1(n8), .B2(n12), .A1_N(n8), .A2_N(
        \mem_array[0][8] ), .Y(n228) );
  sky130_fd_sc_hd__o2bb2ai_1 U143 ( .B1(n8), .B2(n17), .A1_N(n8), .A2_N(
        \mem_array[0][7] ), .Y(n227) );
  sky130_fd_sc_hd__o2bb2ai_1 U144 ( .B1(n8), .B2(n18), .A1_N(n8), .A2_N(
        \mem_array[0][6] ), .Y(n226) );
  sky130_fd_sc_hd__o2bb2ai_1 U145 ( .B1(n8), .B2(n10), .A1_N(n8), .A2_N(
        \mem_array[0][5] ), .Y(n225) );
  sky130_fd_sc_hd__o2bb2ai_1 U146 ( .B1(n8), .B2(n14), .A1_N(n8), .A2_N(
        \mem_array[0][4] ), .Y(n224) );
  sky130_fd_sc_hd__o2bb2ai_1 U147 ( .B1(n8), .B2(n19), .A1_N(n8), .A2_N(
        \mem_array[0][2] ), .Y(n222) );
  sky130_fd_sc_hd__o2bb2ai_1 U148 ( .B1(n8), .B2(n25), .A1_N(n8), .A2_N(
        \mem_array[0][3] ), .Y(n223) );
  sky130_fd_sc_hd__o2bb2ai_1 U149 ( .B1(n8), .B2(n11), .A1_N(n8), .A2_N(
        \mem_array[0][0] ), .Y(n220) );
  sky130_fd_sc_hd__o2bb2ai_1 U150 ( .B1(n8), .B2(n23), .A1_N(n8), .A2_N(
        \mem_array[0][1] ), .Y(n221) );
  sky130_fd_sc_hd__o2bb2ai_1 U151 ( .B1(n26), .B2(n10), .A1_N(n26), .A2_N(
        \mem_array[4][5] ), .Y(n161) );
  sky130_fd_sc_hd__o2bb2ai_1 U152 ( .B1(n26), .B2(n11), .A1_N(n26), .A2_N(
        \mem_array[4][0] ), .Y(n156) );
  sky130_fd_sc_hd__o2bb2ai_1 U153 ( .B1(n26), .B2(n12), .A1_N(n26), .A2_N(
        \mem_array[4][8] ), .Y(n164) );
  sky130_fd_sc_hd__o2bb2ai_1 U154 ( .B1(n26), .B2(n13), .A1_N(n26), .A2_N(
        \mem_array[4][15] ), .Y(n171) );
  sky130_fd_sc_hd__o2bb2ai_1 U155 ( .B1(n26), .B2(n14), .A1_N(n26), .A2_N(
        \mem_array[4][4] ), .Y(n160) );
  sky130_fd_sc_hd__o2bb2ai_1 U156 ( .B1(n26), .B2(n15), .A1_N(n26), .A2_N(
        \mem_array[4][9] ), .Y(n165) );
  sky130_fd_sc_hd__o2bb2ai_1 U157 ( .B1(n26), .B2(n16), .A1_N(n26), .A2_N(
        \mem_array[4][12] ), .Y(n168) );
  sky130_fd_sc_hd__o2bb2ai_1 U158 ( .B1(n26), .B2(n17), .A1_N(n26), .A2_N(
        \mem_array[4][7] ), .Y(n163) );
  sky130_fd_sc_hd__o2bb2ai_1 U159 ( .B1(n26), .B2(n18), .A1_N(n26), .A2_N(
        \mem_array[4][6] ), .Y(n162) );
  sky130_fd_sc_hd__o2bb2ai_1 U160 ( .B1(n26), .B2(n19), .A1_N(n26), .A2_N(
        \mem_array[4][2] ), .Y(n158) );
  sky130_fd_sc_hd__o2bb2ai_1 U161 ( .B1(n26), .B2(n20), .A1_N(n26), .A2_N(
        \mem_array[4][14] ), .Y(n170) );
  sky130_fd_sc_hd__o2bb2ai_1 U162 ( .B1(n26), .B2(n21), .A1_N(n26), .A2_N(
        \mem_array[4][13] ), .Y(n169) );
  sky130_fd_sc_hd__o2bb2ai_1 U163 ( .B1(n26), .B2(n22), .A1_N(n26), .A2_N(
        \mem_array[4][11] ), .Y(n167) );
  sky130_fd_sc_hd__o2bb2ai_1 U164 ( .B1(n26), .B2(n23), .A1_N(n26), .A2_N(
        \mem_array[4][1] ), .Y(n157) );
  sky130_fd_sc_hd__o2bb2ai_1 U165 ( .B1(n26), .B2(n24), .A1_N(n26), .A2_N(
        \mem_array[4][10] ), .Y(n166) );
  sky130_fd_sc_hd__o2bb2ai_1 U166 ( .B1(n26), .B2(n25), .A1_N(n26), .A2_N(
        \mem_array[4][3] ), .Y(n159) );
  sky130_fd_sc_hd__a22oi_1 U167 ( .A1(\mem_array[0][0] ), .A2(n94), .B1(
        \mem_array[2][0] ), .B2(n93), .Y(n36) );
  sky130_fd_sc_hd__a22oi_1 U168 ( .A1(\mem_array[1][0] ), .A2(n96), .B1(
        \mem_array[3][0] ), .B2(n95), .Y(n35) );
  sky130_fd_sc_hd__nand2_1 U169 ( .A(memoryAddress[2]), .B(memoryRead), .Y(n31) );
  sky130_fd_sc_hd__a22oi_1 U170 ( .A1(\mem_array[4][0] ), .A2(n98), .B1(
        \mem_array[6][0] ), .B2(n97), .Y(n34) );
  sky130_fd_sc_hd__nor2_1 U171 ( .A(n30), .B(n31), .Y(n100) );
  sky130_fd_sc_hd__nor2_1 U172 ( .A(n32), .B(n31), .Y(n99) );
  sky130_fd_sc_hd__a22oi_1 U173 ( .A1(\mem_array[5][0] ), .A2(n100), .B1(
        \mem_array[7][0] ), .B2(n99), .Y(n33) );
  sky130_fd_sc_hd__nand4_1 U174 ( .A(n36), .B(n35), .C(n34), .D(n33), .Y(
        memoryOutData[0]) );
  sky130_fd_sc_hd__a22oi_1 U175 ( .A1(n94), .A2(\mem_array[0][1] ), .B1(n93), 
        .B2(\mem_array[2][1] ), .Y(n40) );
  sky130_fd_sc_hd__a22oi_1 U176 ( .A1(n96), .A2(\mem_array[1][1] ), .B1(n95), 
        .B2(\mem_array[3][1] ), .Y(n39) );
  sky130_fd_sc_hd__a22oi_1 U177 ( .A1(n98), .A2(\mem_array[4][1] ), .B1(n97), 
        .B2(\mem_array[6][1] ), .Y(n38) );
  sky130_fd_sc_hd__a22oi_1 U178 ( .A1(n100), .A2(\mem_array[5][1] ), .B1(n99), 
        .B2(\mem_array[7][1] ), .Y(n37) );
  sky130_fd_sc_hd__nand4_1 U179 ( .A(n40), .B(n39), .C(n38), .D(n37), .Y(
        memoryOutData[1]) );
  sky130_fd_sc_hd__a22oi_1 U180 ( .A1(n94), .A2(\mem_array[0][2] ), .B1(n93), 
        .B2(\mem_array[2][2] ), .Y(n44) );
  sky130_fd_sc_hd__a22oi_1 U181 ( .A1(n96), .A2(\mem_array[1][2] ), .B1(n95), 
        .B2(\mem_array[3][2] ), .Y(n43) );
  sky130_fd_sc_hd__a22oi_1 U182 ( .A1(n98), .A2(\mem_array[4][2] ), .B1(n97), 
        .B2(\mem_array[6][2] ), .Y(n42) );
  sky130_fd_sc_hd__a22oi_1 U183 ( .A1(n100), .A2(\mem_array[5][2] ), .B1(n99), 
        .B2(\mem_array[7][2] ), .Y(n41) );
  sky130_fd_sc_hd__nand4_1 U184 ( .A(n44), .B(n43), .C(n42), .D(n41), .Y(
        memoryOutData[2]) );
  sky130_fd_sc_hd__a22oi_1 U185 ( .A1(n94), .A2(\mem_array[0][3] ), .B1(n93), 
        .B2(\mem_array[2][3] ), .Y(n48) );
  sky130_fd_sc_hd__a22oi_1 U186 ( .A1(n96), .A2(\mem_array[1][3] ), .B1(n95), 
        .B2(\mem_array[3][3] ), .Y(n47) );
  sky130_fd_sc_hd__a22oi_1 U187 ( .A1(n98), .A2(\mem_array[4][3] ), .B1(n97), 
        .B2(\mem_array[6][3] ), .Y(n46) );
  sky130_fd_sc_hd__a22oi_1 U188 ( .A1(n100), .A2(\mem_array[5][3] ), .B1(n99), 
        .B2(\mem_array[7][3] ), .Y(n45) );
  sky130_fd_sc_hd__nand4_1 U189 ( .A(n48), .B(n47), .C(n46), .D(n45), .Y(
        memoryOutData[3]) );
  sky130_fd_sc_hd__a22oi_1 U190 ( .A1(n94), .A2(\mem_array[0][4] ), .B1(n93), 
        .B2(\mem_array[2][4] ), .Y(n52) );
  sky130_fd_sc_hd__a22oi_1 U191 ( .A1(n96), .A2(\mem_array[1][4] ), .B1(n95), 
        .B2(\mem_array[3][4] ), .Y(n51) );
  sky130_fd_sc_hd__a22oi_1 U192 ( .A1(n98), .A2(\mem_array[4][4] ), .B1(n97), 
        .B2(\mem_array[6][4] ), .Y(n50) );
  sky130_fd_sc_hd__a22oi_1 U193 ( .A1(n100), .A2(\mem_array[5][4] ), .B1(n99), 
        .B2(\mem_array[7][4] ), .Y(n49) );
  sky130_fd_sc_hd__nand4_1 U194 ( .A(n52), .B(n51), .C(n50), .D(n49), .Y(
        memoryOutData[4]) );
  sky130_fd_sc_hd__a22oi_1 U195 ( .A1(n94), .A2(\mem_array[0][5] ), .B1(n93), 
        .B2(\mem_array[2][5] ), .Y(n56) );
  sky130_fd_sc_hd__a22oi_1 U196 ( .A1(n96), .A2(\mem_array[1][5] ), .B1(n95), 
        .B2(\mem_array[3][5] ), .Y(n55) );
  sky130_fd_sc_hd__a22oi_1 U197 ( .A1(n98), .A2(\mem_array[4][5] ), .B1(n97), 
        .B2(\mem_array[6][5] ), .Y(n54) );
  sky130_fd_sc_hd__a22oi_1 U198 ( .A1(n100), .A2(\mem_array[5][5] ), .B1(n99), 
        .B2(\mem_array[7][5] ), .Y(n53) );
  sky130_fd_sc_hd__nand4_1 U199 ( .A(n56), .B(n55), .C(n54), .D(n53), .Y(
        memoryOutData[5]) );
  sky130_fd_sc_hd__a22oi_1 U200 ( .A1(n94), .A2(\mem_array[0][6] ), .B1(n93), 
        .B2(\mem_array[2][6] ), .Y(n60) );
  sky130_fd_sc_hd__a22oi_1 U201 ( .A1(n96), .A2(\mem_array[1][6] ), .B1(n95), 
        .B2(\mem_array[3][6] ), .Y(n59) );
  sky130_fd_sc_hd__a22oi_1 U202 ( .A1(n98), .A2(\mem_array[4][6] ), .B1(n97), 
        .B2(\mem_array[6][6] ), .Y(n58) );
  sky130_fd_sc_hd__a22oi_1 U203 ( .A1(n100), .A2(\mem_array[5][6] ), .B1(n99), 
        .B2(\mem_array[7][6] ), .Y(n57) );
  sky130_fd_sc_hd__nand4_1 U204 ( .A(n60), .B(n59), .C(n58), .D(n57), .Y(
        memoryOutData[6]) );
  sky130_fd_sc_hd__a22oi_1 U205 ( .A1(n94), .A2(\mem_array[0][7] ), .B1(n93), 
        .B2(\mem_array[2][7] ), .Y(n64) );
  sky130_fd_sc_hd__a22oi_1 U206 ( .A1(n96), .A2(\mem_array[1][7] ), .B1(n95), 
        .B2(\mem_array[3][7] ), .Y(n63) );
  sky130_fd_sc_hd__a22oi_1 U207 ( .A1(n98), .A2(\mem_array[4][7] ), .B1(n97), 
        .B2(\mem_array[6][7] ), .Y(n62) );
  sky130_fd_sc_hd__a22oi_1 U208 ( .A1(n100), .A2(\mem_array[5][7] ), .B1(n99), 
        .B2(\mem_array[7][7] ), .Y(n61) );
  sky130_fd_sc_hd__nand4_1 U209 ( .A(n64), .B(n63), .C(n62), .D(n61), .Y(
        memoryOutData[7]) );
  sky130_fd_sc_hd__a22oi_1 U210 ( .A1(n94), .A2(\mem_array[0][8] ), .B1(n93), 
        .B2(\mem_array[2][8] ), .Y(n68) );
  sky130_fd_sc_hd__a22oi_1 U211 ( .A1(n96), .A2(\mem_array[1][8] ), .B1(n95), 
        .B2(\mem_array[3][8] ), .Y(n67) );
  sky130_fd_sc_hd__a22oi_1 U212 ( .A1(n98), .A2(\mem_array[4][8] ), .B1(n97), 
        .B2(\mem_array[6][8] ), .Y(n66) );
  sky130_fd_sc_hd__a22oi_1 U213 ( .A1(n100), .A2(\mem_array[5][8] ), .B1(n99), 
        .B2(\mem_array[7][8] ), .Y(n65) );
  sky130_fd_sc_hd__nand4_1 U214 ( .A(n68), .B(n67), .C(n66), .D(n65), .Y(
        memoryOutData[8]) );
  sky130_fd_sc_hd__a22oi_1 U215 ( .A1(n94), .A2(\mem_array[0][9] ), .B1(n93), 
        .B2(\mem_array[2][9] ), .Y(n72) );
  sky130_fd_sc_hd__a22oi_1 U216 ( .A1(n96), .A2(\mem_array[1][9] ), .B1(n95), 
        .B2(\mem_array[3][9] ), .Y(n71) );
  sky130_fd_sc_hd__a22oi_1 U217 ( .A1(n98), .A2(\mem_array[4][9] ), .B1(n97), 
        .B2(\mem_array[6][9] ), .Y(n70) );
  sky130_fd_sc_hd__a22oi_1 U218 ( .A1(n100), .A2(\mem_array[5][9] ), .B1(n99), 
        .B2(\mem_array[7][9] ), .Y(n69) );
  sky130_fd_sc_hd__nand4_1 U219 ( .A(n72), .B(n71), .C(n70), .D(n69), .Y(
        memoryOutData[9]) );
  sky130_fd_sc_hd__a22oi_1 U220 ( .A1(n94), .A2(\mem_array[0][10] ), .B1(n93), 
        .B2(\mem_array[2][10] ), .Y(n76) );
  sky130_fd_sc_hd__a22oi_1 U221 ( .A1(n96), .A2(\mem_array[1][10] ), .B1(n95), 
        .B2(\mem_array[3][10] ), .Y(n75) );
  sky130_fd_sc_hd__a22oi_1 U222 ( .A1(n98), .A2(\mem_array[4][10] ), .B1(n97), 
        .B2(\mem_array[6][10] ), .Y(n74) );
  sky130_fd_sc_hd__a22oi_1 U223 ( .A1(n100), .A2(\mem_array[5][10] ), .B1(n99), 
        .B2(\mem_array[7][10] ), .Y(n73) );
  sky130_fd_sc_hd__nand4_1 U224 ( .A(n76), .B(n75), .C(n74), .D(n73), .Y(
        memoryOutData[10]) );
  sky130_fd_sc_hd__a22oi_1 U225 ( .A1(n94), .A2(\mem_array[0][11] ), .B1(n93), 
        .B2(\mem_array[2][11] ), .Y(n80) );
  sky130_fd_sc_hd__a22oi_1 U226 ( .A1(n96), .A2(\mem_array[1][11] ), .B1(n95), 
        .B2(\mem_array[3][11] ), .Y(n79) );
  sky130_fd_sc_hd__a22oi_1 U227 ( .A1(n98), .A2(\mem_array[4][11] ), .B1(n97), 
        .B2(\mem_array[6][11] ), .Y(n78) );
  sky130_fd_sc_hd__a22oi_1 U228 ( .A1(n100), .A2(\mem_array[5][11] ), .B1(n99), 
        .B2(\mem_array[7][11] ), .Y(n77) );
  sky130_fd_sc_hd__nand4_1 U229 ( .A(n80), .B(n79), .C(n78), .D(n77), .Y(
        memoryOutData[11]) );
  sky130_fd_sc_hd__a22oi_1 U230 ( .A1(n94), .A2(\mem_array[0][12] ), .B1(n93), 
        .B2(\mem_array[2][12] ), .Y(n84) );
  sky130_fd_sc_hd__a22oi_1 U231 ( .A1(n96), .A2(\mem_array[1][12] ), .B1(n95), 
        .B2(\mem_array[3][12] ), .Y(n83) );
  sky130_fd_sc_hd__a22oi_1 U232 ( .A1(n98), .A2(\mem_array[4][12] ), .B1(n97), 
        .B2(\mem_array[6][12] ), .Y(n82) );
  sky130_fd_sc_hd__a22oi_1 U233 ( .A1(n100), .A2(\mem_array[5][12] ), .B1(n99), 
        .B2(\mem_array[7][12] ), .Y(n81) );
  sky130_fd_sc_hd__nand4_1 U234 ( .A(n84), .B(n83), .C(n82), .D(n81), .Y(
        memoryOutData[12]) );
  sky130_fd_sc_hd__a22oi_1 U235 ( .A1(n94), .A2(\mem_array[0][13] ), .B1(n93), 
        .B2(\mem_array[2][13] ), .Y(n88) );
  sky130_fd_sc_hd__a22oi_1 U236 ( .A1(n96), .A2(\mem_array[1][13] ), .B1(n95), 
        .B2(\mem_array[3][13] ), .Y(n87) );
  sky130_fd_sc_hd__a22oi_1 U237 ( .A1(n98), .A2(\mem_array[4][13] ), .B1(n97), 
        .B2(\mem_array[6][13] ), .Y(n86) );
  sky130_fd_sc_hd__a22oi_1 U238 ( .A1(n100), .A2(\mem_array[5][13] ), .B1(n99), 
        .B2(\mem_array[7][13] ), .Y(n85) );
  sky130_fd_sc_hd__nand4_1 U239 ( .A(n88), .B(n87), .C(n86), .D(n85), .Y(
        memoryOutData[13]) );
  sky130_fd_sc_hd__a22oi_1 U240 ( .A1(n94), .A2(\mem_array[0][14] ), .B1(n93), 
        .B2(\mem_array[2][14] ), .Y(n92) );
  sky130_fd_sc_hd__a22oi_1 U241 ( .A1(n96), .A2(\mem_array[1][14] ), .B1(n95), 
        .B2(\mem_array[3][14] ), .Y(n91) );
  sky130_fd_sc_hd__a22oi_1 U242 ( .A1(n98), .A2(\mem_array[4][14] ), .B1(n97), 
        .B2(\mem_array[6][14] ), .Y(n90) );
  sky130_fd_sc_hd__a22oi_1 U243 ( .A1(n100), .A2(\mem_array[5][14] ), .B1(n99), 
        .B2(\mem_array[7][14] ), .Y(n89) );
  sky130_fd_sc_hd__nand4_1 U244 ( .A(n92), .B(n91), .C(n90), .D(n89), .Y(
        memoryOutData[14]) );
  sky130_fd_sc_hd__a22oi_1 U245 ( .A1(n94), .A2(\mem_array[0][15] ), .B1(n93), 
        .B2(\mem_array[2][15] ), .Y(n104) );
  sky130_fd_sc_hd__a22oi_1 U246 ( .A1(n96), .A2(\mem_array[1][15] ), .B1(n95), 
        .B2(\mem_array[3][15] ), .Y(n103) );
  sky130_fd_sc_hd__a22oi_1 U247 ( .A1(n98), .A2(\mem_array[4][15] ), .B1(n97), 
        .B2(\mem_array[6][15] ), .Y(n102) );
  sky130_fd_sc_hd__a22oi_1 U248 ( .A1(n100), .A2(\mem_array[5][15] ), .B1(n99), 
        .B2(\mem_array[7][15] ), .Y(n101) );
  sky130_fd_sc_hd__nand4_1 U249 ( .A(n104), .B(n103), .C(n102), .D(n101), .Y(
        memoryOutData[15]) );
endmodule


module mux2_WIDTH16 ( din1, din2, select, dout );
  input [15:0] din1;
  input [15:0] din2;
  output [15:0] dout;
  input select;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14;

  sky130_fd_sc_hd__mux2_2 U1 ( .A0(din2[10]), .A1(din1[10]), .S(n14), .X(
        dout[10]) );
  sky130_fd_sc_hd__mux2_2 U2 ( .A0(din2[9]), .A1(din1[9]), .S(n14), .X(dout[9]) );
  sky130_fd_sc_hd__inv_1 U3 ( .A(n2), .Y(dout[11]) );
  sky130_fd_sc_hd__mux2_2 U4 ( .A0(din2[6]), .A1(din1[6]), .S(n14), .X(dout[6]) );
  sky130_fd_sc_hd__or2_0 U5 ( .A(n4), .B(n3), .X(n1) );
  sky130_fd_sc_hd__inv_1 U6 ( .A(din2[0]), .Y(n3) );
  sky130_fd_sc_hd__inv_1 U7 ( .A(select), .Y(n4) );
  sky130_fd_sc_hd__mux2_2 U8 ( .A0(din2[8]), .A1(din1[8]), .S(n14), .X(dout[8]) );
  sky130_fd_sc_hd__inv_2 U9 ( .A(select), .Y(n14) );
  sky130_fd_sc_hd__mux2i_1 U10 ( .A0(din2[11]), .A1(din1[11]), .S(n14), .Y(n2)
         );
  sky130_fd_sc_hd__nand2_1 U11 ( .A(din1[0]), .B(n14), .Y(n5) );
  sky130_fd_sc_hd__nand2_1 U12 ( .A(n5), .B(n1), .Y(dout[0]) );
  sky130_fd_sc_hd__mux2_2 U13 ( .A0(din2[2]), .A1(din1[2]), .S(n14), .X(
        dout[2]) );
  sky130_fd_sc_hd__mux2_2 U14 ( .A0(din2[3]), .A1(din1[3]), .S(n14), .X(
        dout[3]) );
  sky130_fd_sc_hd__a22o_1 U15 ( .A1(din2[1]), .A2(select), .B1(din1[1]), .B2(
        n14), .X(dout[1]) );
  sky130_fd_sc_hd__a22o_1 U16 ( .A1(din2[7]), .A2(select), .B1(din1[7]), .B2(
        n14), .X(dout[7]) );
  sky130_fd_sc_hd__nand2_1 U17 ( .A(din1[12]), .B(n14), .Y(n7) );
  sky130_fd_sc_hd__nand2_1 U18 ( .A(din2[12]), .B(select), .Y(n6) );
  sky130_fd_sc_hd__nand2_1 U19 ( .A(n7), .B(n6), .Y(dout[12]) );
  sky130_fd_sc_hd__nand2_1 U20 ( .A(din1[13]), .B(n14), .Y(n9) );
  sky130_fd_sc_hd__nand2_1 U21 ( .A(din2[13]), .B(select), .Y(n8) );
  sky130_fd_sc_hd__nand2_1 U22 ( .A(n9), .B(n8), .Y(dout[13]) );
  sky130_fd_sc_hd__nand2_1 U23 ( .A(din1[14]), .B(n14), .Y(n11) );
  sky130_fd_sc_hd__nand2_1 U24 ( .A(din2[14]), .B(select), .Y(n10) );
  sky130_fd_sc_hd__nand2_1 U25 ( .A(n11), .B(n10), .Y(dout[14]) );
  sky130_fd_sc_hd__nand2_1 U26 ( .A(din1[15]), .B(n14), .Y(n13) );
  sky130_fd_sc_hd__nand2_1 U27 ( .A(din2[15]), .B(select), .Y(n12) );
  sky130_fd_sc_hd__nand2_1 U28 ( .A(n13), .B(n12), .Y(dout[15]) );
  sky130_fd_sc_hd__a22o_1 U29 ( .A1(select), .A2(din2[4]), .B1(n14), .B2(
        din1[4]), .X(dout[4]) );
  sky130_fd_sc_hd__a22o_1 U30 ( .A1(select), .A2(din2[5]), .B1(n14), .B2(
        din1[5]), .X(dout[5]) );
endmodule


module register_bank_WIDTH16 ( clk, rst, wr_en, in, out );
  input [15:0] in;
  output [15:0] out;
  input clk, rst, wr_en;
  wire   n3, n5, n7, n9, n11, n13, n15, n17, n19, n21, n23, n25, n27, n29, n31,
         n33, n1, n2, n4, n6, n8, n10, n12, n14, n16, n18, n20, n22, n24, n26,
         n28, n30, n32, n34, n35, n36, n37, n38, n39, n40, n41, n42, n43, n44,
         n45, n46, n47, n48;

  sky130_fd_sc_hd__dfrtp_1 \out_reg[15]  ( .D(n33), .CLK(clk), .RESET_B(n48), 
        .Q(out[15]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[14]  ( .D(n31), .CLK(clk), .RESET_B(n48), 
        .Q(out[14]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[13]  ( .D(n29), .CLK(clk), .RESET_B(n48), 
        .Q(out[13]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[12]  ( .D(n27), .CLK(clk), .RESET_B(n48), 
        .Q(out[12]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[11]  ( .D(n25), .CLK(clk), .RESET_B(n48), 
        .Q(out[11]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[10]  ( .D(n23), .CLK(clk), .RESET_B(n48), 
        .Q(out[10]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[9]  ( .D(n21), .CLK(clk), .RESET_B(n48), 
        .Q(out[9]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[8]  ( .D(n19), .CLK(clk), .RESET_B(n48), 
        .Q(out[8]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[7]  ( .D(n17), .CLK(clk), .RESET_B(n48), 
        .Q(out[7]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[6]  ( .D(n15), .CLK(clk), .RESET_B(n48), 
        .Q(out[6]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[3]  ( .D(n9), .CLK(clk), .RESET_B(n48), 
        .Q(out[3]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[2]  ( .D(n7), .CLK(clk), .RESET_B(n48), 
        .Q(out[2]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[1]  ( .D(n5), .CLK(clk), .RESET_B(n48), 
        .Q(out[1]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[5]  ( .D(n13), .CLK(clk), .RESET_B(n48), 
        .Q(out[5]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[4]  ( .D(n11), .CLK(clk), .RESET_B(n48), 
        .Q(out[4]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[0]  ( .D(n3), .CLK(clk), .RESET_B(n48), 
        .Q(out[0]) );
  sky130_fd_sc_hd__buf_4 U2 ( .A(wr_en), .X(n47) );
  sky130_fd_sc_hd__nand2_1 U3 ( .A(in[14]), .B(n47), .Y(n4) );
  sky130_fd_sc_hd__or2_0 U4 ( .A(n1), .B(n47), .X(n2) );
  sky130_fd_sc_hd__nand2_1 U5 ( .A(n4), .B(n2), .Y(n31) );
  sky130_fd_sc_hd__inv_1 U6 ( .A(out[14]), .Y(n1) );
  sky130_fd_sc_hd__inv_1 U7 ( .A(rst), .Y(n48) );
  sky130_fd_sc_hd__inv_1 U8 ( .A(n47), .Y(n6) );
  sky130_fd_sc_hd__a22o_1 U9 ( .A1(n47), .A2(in[4]), .B1(n6), .B2(out[4]), .X(
        n11) );
  sky130_fd_sc_hd__a22o_1 U10 ( .A1(n47), .A2(in[5]), .B1(n6), .B2(out[5]), 
        .X(n13) );
  sky130_fd_sc_hd__nand2_1 U11 ( .A(in[0]), .B(n47), .Y(n10) );
  sky130_fd_sc_hd__nand2_1 U12 ( .A(n6), .B(out[0]), .Y(n8) );
  sky130_fd_sc_hd__nand2_1 U13 ( .A(n10), .B(n8), .Y(n3) );
  sky130_fd_sc_hd__inv_1 U14 ( .A(out[1]), .Y(n14) );
  sky130_fd_sc_hd__nand2_1 U15 ( .A(in[1]), .B(n47), .Y(n12) );
  sky130_fd_sc_hd__o21ai_1 U16 ( .A1(n47), .A2(n14), .B1(n12), .Y(n5) );
  sky130_fd_sc_hd__inv_1 U17 ( .A(out[2]), .Y(n18) );
  sky130_fd_sc_hd__nand2_1 U18 ( .A(in[2]), .B(n47), .Y(n16) );
  sky130_fd_sc_hd__o21ai_1 U19 ( .A1(n47), .A2(n18), .B1(n16), .Y(n7) );
  sky130_fd_sc_hd__inv_1 U20 ( .A(out[3]), .Y(n22) );
  sky130_fd_sc_hd__nand2_1 U21 ( .A(in[3]), .B(n47), .Y(n20) );
  sky130_fd_sc_hd__o21ai_1 U22 ( .A1(n47), .A2(n22), .B1(n20), .Y(n9) );
  sky130_fd_sc_hd__inv_1 U23 ( .A(out[6]), .Y(n26) );
  sky130_fd_sc_hd__nand2_1 U24 ( .A(in[6]), .B(n47), .Y(n24) );
  sky130_fd_sc_hd__o21ai_1 U25 ( .A1(n47), .A2(n26), .B1(n24), .Y(n15) );
  sky130_fd_sc_hd__inv_1 U26 ( .A(out[7]), .Y(n30) );
  sky130_fd_sc_hd__nand2_1 U27 ( .A(in[7]), .B(n47), .Y(n28) );
  sky130_fd_sc_hd__o21ai_1 U28 ( .A1(n47), .A2(n30), .B1(n28), .Y(n17) );
  sky130_fd_sc_hd__inv_1 U29 ( .A(out[8]), .Y(n34) );
  sky130_fd_sc_hd__nand2_1 U30 ( .A(in[8]), .B(n47), .Y(n32) );
  sky130_fd_sc_hd__o21ai_1 U31 ( .A1(n47), .A2(n34), .B1(n32), .Y(n19) );
  sky130_fd_sc_hd__inv_1 U32 ( .A(out[9]), .Y(n36) );
  sky130_fd_sc_hd__nand2_1 U33 ( .A(in[9]), .B(n47), .Y(n35) );
  sky130_fd_sc_hd__o21ai_1 U34 ( .A1(n47), .A2(n36), .B1(n35), .Y(n21) );
  sky130_fd_sc_hd__inv_1 U35 ( .A(out[10]), .Y(n38) );
  sky130_fd_sc_hd__nand2_1 U36 ( .A(in[10]), .B(n47), .Y(n37) );
  sky130_fd_sc_hd__o21ai_1 U37 ( .A1(n47), .A2(n38), .B1(n37), .Y(n23) );
  sky130_fd_sc_hd__inv_1 U38 ( .A(out[11]), .Y(n40) );
  sky130_fd_sc_hd__nand2_1 U39 ( .A(in[11]), .B(n47), .Y(n39) );
  sky130_fd_sc_hd__o21ai_1 U40 ( .A1(n47), .A2(n40), .B1(n39), .Y(n25) );
  sky130_fd_sc_hd__inv_1 U41 ( .A(out[12]), .Y(n42) );
  sky130_fd_sc_hd__nand2_1 U42 ( .A(in[12]), .B(n47), .Y(n41) );
  sky130_fd_sc_hd__o21ai_1 U43 ( .A1(n47), .A2(n42), .B1(n41), .Y(n27) );
  sky130_fd_sc_hd__inv_1 U44 ( .A(out[13]), .Y(n44) );
  sky130_fd_sc_hd__nand2_1 U45 ( .A(in[13]), .B(n47), .Y(n43) );
  sky130_fd_sc_hd__o21ai_1 U46 ( .A1(n47), .A2(n44), .B1(n43), .Y(n29) );
  sky130_fd_sc_hd__inv_1 U47 ( .A(out[15]), .Y(n46) );
  sky130_fd_sc_hd__nand2_1 U48 ( .A(in[15]), .B(n47), .Y(n45) );
  sky130_fd_sc_hd__o21ai_1 U49 ( .A1(n47), .A2(n46), .B1(n45), .Y(n33) );
endmodule


module mux2_registered_WIDTH8 ( clk, rst, sel, wr_en, in1, in2, out );
  input [15:0] in1;
  input [15:0] in2;
  output [15:0] out;
  input clk, rst, sel, wr_en;

  wire   [15:0] mux_out;

  mux2_WIDTH16 u_mux2 ( .din1(in1), .din2(in2), .select(sel), .dout(mux_out)
         );
  register_bank_WIDTH16 u_reg_bank ( .clk(clk), .rst(rst), .wr_en(wr_en), .in(
        mux_out), .out(out) );
endmodule


module register_bank_WIDTH7 ( clk, rst, wr_en, in, out );
  input [6:0] in;
  output [6:0] out;
  input clk, rst, wr_en;
  wire   n2, n3, n5, n7, n9, n11, n13, n15, n1;

  sky130_fd_sc_hd__dfrtp_1 \out_reg[6]  ( .D(n15), .CLK(clk), .RESET_B(n2), 
        .Q(out[6]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[5]  ( .D(n13), .CLK(clk), .RESET_B(n2), 
        .Q(out[5]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[4]  ( .D(n11), .CLK(clk), .RESET_B(n2), 
        .Q(out[4]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[3]  ( .D(n9), .CLK(clk), .RESET_B(n2), .Q(
        out[3]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[2]  ( .D(n7), .CLK(clk), .RESET_B(n2), .Q(
        out[2]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[1]  ( .D(n5), .CLK(clk), .RESET_B(n2), .Q(
        out[1]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[0]  ( .D(n3), .CLK(clk), .RESET_B(n2), .Q(
        out[0]) );
  sky130_fd_sc_hd__inv_1 U2 ( .A(wr_en), .Y(n1) );
  sky130_fd_sc_hd__inv_1 U3 ( .A(rst), .Y(n2) );
  sky130_fd_sc_hd__a22o_1 U4 ( .A1(wr_en), .A2(in[6]), .B1(n1), .B2(out[6]), 
        .X(n15) );
  sky130_fd_sc_hd__a22o_1 U5 ( .A1(wr_en), .A2(in[5]), .B1(n1), .B2(out[5]), 
        .X(n13) );
  sky130_fd_sc_hd__a22o_1 U6 ( .A1(wr_en), .A2(in[4]), .B1(n1), .B2(out[4]), 
        .X(n11) );
  sky130_fd_sc_hd__a22o_1 U7 ( .A1(wr_en), .A2(in[3]), .B1(n1), .B2(out[3]), 
        .X(n9) );
  sky130_fd_sc_hd__a22o_1 U8 ( .A1(wr_en), .A2(in[2]), .B1(n1), .B2(out[2]), 
        .X(n7) );
  sky130_fd_sc_hd__a22o_1 U9 ( .A1(wr_en), .A2(in[1]), .B1(n1), .B2(out[1]), 
        .X(n5) );
  sky130_fd_sc_hd__a22o_1 U10 ( .A1(wr_en), .A2(in[0]), .B1(n1), .B2(out[0]), 
        .X(n3) );
endmodule


module control ( clk, rst, cmd_in, p_error, aluin_reg_en, datain_reg_en, 
        memoryWrite, memoryRead, selmux2, cpu_rdy, aluout_reg_en, nvalid_data, 
        in_select_a, in_select_b, opcode );
  input [6:0] cmd_in;
  output [1:0] in_select_a;
  output [1:0] in_select_b;
  output [3:0] opcode;
  input clk, rst, p_error;
  output aluin_reg_en, datain_reg_en, memoryWrite, memoryRead, selmux2,
         cpu_rdy, aluout_reg_en, nvalid_data;
  wire   memoryRead, \cmd_in[6] , \cmd_in[5] , \cmd_in[4] , \cmd_in[3] , n7,
         n9, n10, n1, n2, n3, n4, n5, n6, n8;
  wire   [1:0] current_state;
  assign selmux2 = memoryRead;
  assign in_select_a[1] = \cmd_in[6] ;
  assign \cmd_in[6]  = cmd_in[6];
  assign in_select_a[0] = \cmd_in[5] ;
  assign \cmd_in[5]  = cmd_in[5];
  assign in_select_b[1] = \cmd_in[4] ;
  assign \cmd_in[4]  = cmd_in[4];
  assign in_select_b[0] = \cmd_in[3] ;
  assign \cmd_in[3]  = cmd_in[3];

  sky130_fd_sc_hd__dfrtp_1 \current_state_reg[0]  ( .D(n10), .CLK(clk), 
        .RESET_B(n7), .Q(current_state[0]) );
  sky130_fd_sc_hd__dfrtp_1 \current_state_reg[1]  ( .D(n9), .CLK(clk), 
        .RESET_B(n7), .Q(current_state[1]) );
  sky130_fd_sc_hd__nor2_2 U3 ( .A(n1), .B(current_state[1]), .Y(aluin_reg_en)
         );
  sky130_fd_sc_hd__inv_1 U4 ( .A(cmd_in[1]), .Y(n4) );
  sky130_fd_sc_hd__nand2_1 U5 ( .A(cmd_in[0]), .B(n4), .Y(n2) );
  sky130_fd_sc_hd__nand2_1 U6 ( .A(current_state[1]), .B(n1), .Y(n6) );
  sky130_fd_sc_hd__and2_1 U7 ( .A(current_state[1]), .B(current_state[0]), .X(
        cpu_rdy) );
  sky130_fd_sc_hd__inv_1 U8 ( .A(aluin_reg_en), .Y(n10) );
  sky130_fd_sc_hd__inv_2 U9 ( .A(current_state[0]), .Y(n1) );
  sky130_fd_sc_hd__inv_2 U10 ( .A(n9), .Y(datain_reg_en) );
  sky130_fd_sc_hd__a21oi_2 U11 ( .A1(cmd_in[2]), .A2(n2), .B1(n6), .Y(
        aluout_reg_en) );
  sky130_fd_sc_hd__nand2_1 U12 ( .A(n6), .B(n10), .Y(n9) );
  sky130_fd_sc_hd__inv_1 U13 ( .A(rst), .Y(n7) );
  sky130_fd_sc_hd__inv_1 U14 ( .A(cmd_in[2]), .Y(n3) );
  sky130_fd_sc_hd__nor3_4 U15 ( .A(n3), .B(n6), .C(n2), .Y(memoryRead) );
  sky130_fd_sc_hd__o21ai_1 U16 ( .A1(cmd_in[1]), .A2(cmd_in[0]), .B1(n3), .Y(
        opcode[0]) );
  sky130_fd_sc_hd__nor2_1 U17 ( .A(cmd_in[2]), .B(n2), .Y(opcode[1]) );
  sky130_fd_sc_hd__nor3_1 U18 ( .A(cmd_in[2]), .B(cmd_in[0]), .C(n4), .Y(
        opcode[2]) );
  sky130_fd_sc_hd__and3_1 U19 ( .A(n3), .B(cmd_in[1]), .C(cmd_in[0]), .X(
        opcode[3]) );
  sky130_fd_sc_hd__nor2_1 U20 ( .A(cmd_in[0]), .B(n4), .Y(n5) );
  sky130_fd_sc_hd__and3_1 U21 ( .A(cpu_rdy), .B(cmd_in[2]), .C(n5), .X(
        memoryWrite) );
  sky130_fd_sc_hd__a22oi_1 U22 ( .A1(\cmd_in[3] ), .A2(\cmd_in[4] ), .B1(
        \cmd_in[5] ), .B2(\cmd_in[6] ), .Y(n8) );
  sky130_fd_sc_hd__nor3b_1 U23 ( .C_N(p_error), .A(n8), .B(n6), .Y(nvalid_data) );
endmodule


module register_bank_WIDTH8_0 ( clk, rst, wr_en, in, out );
  input [7:0] in;
  output [7:0] out;
  input clk, rst, wr_en;
  wire   n1, n2, n4, n6, n8, n10, n12, n14, n16, n18, n19, n20, n21, n22, n23,
         n24, n25, n26, n27, n28, n29, n30, n31, n32, n33;

  sky130_fd_sc_hd__dfrtp_1 \out_reg[5]  ( .D(n28), .CLK(clk), .RESET_B(n25), 
        .Q(out[5]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[4]  ( .D(n29), .CLK(clk), .RESET_B(n25), 
        .Q(out[4]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[3]  ( .D(n30), .CLK(clk), .RESET_B(n25), 
        .Q(out[3]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[2]  ( .D(n31), .CLK(clk), .RESET_B(n25), 
        .Q(out[2]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[1]  ( .D(n32), .CLK(clk), .RESET_B(n25), 
        .Q(out[1]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[0]  ( .D(n33), .CLK(clk), .RESET_B(n25), 
        .Q(out[0]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[6]  ( .D(n27), .CLK(clk), .RESET_B(n25), 
        .Q(out[6]) );
  sky130_fd_sc_hd__dfrtp_1 \out_reg[7]  ( .D(n26), .CLK(clk), .RESET_B(n25), 
        .Q(out[7]) );
  sky130_fd_sc_hd__o21ai_0 U2 ( .A1(wr_en), .A2(n23), .B1(n22), .Y(n26) );
  sky130_fd_sc_hd__o21ai_0 U3 ( .A1(wr_en), .A2(n24), .B1(n21), .Y(n27) );
  sky130_fd_sc_hd__o21ai_0 U4 ( .A1(wr_en), .A2(n20), .B1(n19), .Y(n33) );
  sky130_fd_sc_hd__o21ai_0 U5 ( .A1(wr_en), .A2(n18), .B1(n16), .Y(n32) );
  sky130_fd_sc_hd__o21ai_0 U6 ( .A1(wr_en), .A2(n14), .B1(n12), .Y(n31) );
  sky130_fd_sc_hd__o21ai_0 U7 ( .A1(wr_en), .A2(n6), .B1(n4), .Y(n30) );
  sky130_fd_sc_hd__o21ai_0 U8 ( .A1(wr_en), .A2(n10), .B1(n8), .Y(n29) );
  sky130_fd_sc_hd__o21ai_0 U9 ( .A1(wr_en), .A2(n2), .B1(n1), .Y(n28) );
  sky130_fd_sc_hd__inv_1 U10 ( .A(rst), .Y(n25) );
  sky130_fd_sc_hd__inv_1 U11 ( .A(out[5]), .Y(n2) );
  sky130_fd_sc_hd__nand2_1 U12 ( .A(in[5]), .B(wr_en), .Y(n1) );
  sky130_fd_sc_hd__inv_1 U13 ( .A(out[3]), .Y(n6) );
  sky130_fd_sc_hd__nand2_1 U14 ( .A(in[3]), .B(wr_en), .Y(n4) );
  sky130_fd_sc_hd__inv_1 U15 ( .A(out[4]), .Y(n10) );
  sky130_fd_sc_hd__nand2_1 U16 ( .A(in[4]), .B(wr_en), .Y(n8) );
  sky130_fd_sc_hd__inv_1 U17 ( .A(out[2]), .Y(n14) );
  sky130_fd_sc_hd__nand2_1 U18 ( .A(in[2]), .B(wr_en), .Y(n12) );
  sky130_fd_sc_hd__inv_1 U19 ( .A(out[1]), .Y(n18) );
  sky130_fd_sc_hd__nand2_1 U20 ( .A(in[1]), .B(wr_en), .Y(n16) );
  sky130_fd_sc_hd__inv_1 U21 ( .A(out[0]), .Y(n20) );
  sky130_fd_sc_hd__nand2_1 U22 ( .A(in[0]), .B(wr_en), .Y(n19) );
  sky130_fd_sc_hd__inv_1 U23 ( .A(out[6]), .Y(n24) );
  sky130_fd_sc_hd__nand2_1 U24 ( .A(in[6]), .B(wr_en), .Y(n21) );
  sky130_fd_sc_hd__inv_1 U25 ( .A(out[7]), .Y(n23) );
  sky130_fd_sc_hd__nand2_1 U26 ( .A(in[7]), .B(wr_en), .Y(n22) );
endmodule


module mux4_WIDTH8_0 ( din1, din2, din3, din4, select, dout );
  input [7:0] din1;
  input [7:0] din2;
  input [7:0] din3;
  input [7:0] din4;
  input [1:0] select;
  output [7:0] dout;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22;

  sky130_fd_sc_hd__inv_1 U1 ( .A(select[0]), .Y(n1) );
  sky130_fd_sc_hd__nor2_1 U2 ( .A(select[1]), .B(n1), .Y(n18) );
  sky130_fd_sc_hd__inv_1 U3 ( .A(select[1]), .Y(n2) );
  sky130_fd_sc_hd__nor2_1 U4 ( .A(n2), .B(n1), .Y(n17) );
  sky130_fd_sc_hd__a22oi_1 U5 ( .A1(n18), .A2(din2[0]), .B1(n17), .B2(din4[0]), 
        .Y(n4) );
  sky130_fd_sc_hd__nor2_1 U6 ( .A(select[1]), .B(select[0]), .Y(n20) );
  sky130_fd_sc_hd__nor2_1 U7 ( .A(select[0]), .B(n2), .Y(n19) );
  sky130_fd_sc_hd__a22oi_1 U8 ( .A1(n20), .A2(din1[0]), .B1(n19), .B2(din3[0]), 
        .Y(n3) );
  sky130_fd_sc_hd__nand2_1 U9 ( .A(n4), .B(n3), .Y(dout[0]) );
  sky130_fd_sc_hd__a22oi_1 U10 ( .A1(n18), .A2(din2[1]), .B1(n17), .B2(din4[1]), .Y(n6) );
  sky130_fd_sc_hd__a22oi_1 U11 ( .A1(n20), .A2(din1[1]), .B1(n19), .B2(din3[1]), .Y(n5) );
  sky130_fd_sc_hd__nand2_1 U12 ( .A(n6), .B(n5), .Y(dout[1]) );
  sky130_fd_sc_hd__a22oi_1 U13 ( .A1(n18), .A2(din2[2]), .B1(n17), .B2(din4[2]), .Y(n8) );
  sky130_fd_sc_hd__a22oi_1 U14 ( .A1(n20), .A2(din1[2]), .B1(n19), .B2(din3[2]), .Y(n7) );
  sky130_fd_sc_hd__nand2_1 U15 ( .A(n8), .B(n7), .Y(dout[2]) );
  sky130_fd_sc_hd__a22oi_1 U16 ( .A1(n18), .A2(din2[3]), .B1(n17), .B2(din4[3]), .Y(n10) );
  sky130_fd_sc_hd__a22oi_1 U17 ( .A1(n20), .A2(din1[3]), .B1(n19), .B2(din3[3]), .Y(n9) );
  sky130_fd_sc_hd__nand2_1 U18 ( .A(n10), .B(n9), .Y(dout[3]) );
  sky130_fd_sc_hd__a22oi_1 U19 ( .A1(n18), .A2(din2[4]), .B1(n17), .B2(din4[4]), .Y(n12) );
  sky130_fd_sc_hd__a22oi_1 U20 ( .A1(n20), .A2(din1[4]), .B1(n19), .B2(din3[4]), .Y(n11) );
  sky130_fd_sc_hd__nand2_1 U21 ( .A(n12), .B(n11), .Y(dout[4]) );
  sky130_fd_sc_hd__a22oi_1 U22 ( .A1(n18), .A2(din2[5]), .B1(n17), .B2(din4[5]), .Y(n14) );
  sky130_fd_sc_hd__a22oi_1 U23 ( .A1(n20), .A2(din1[5]), .B1(n19), .B2(din3[5]), .Y(n13) );
  sky130_fd_sc_hd__nand2_1 U24 ( .A(n14), .B(n13), .Y(dout[5]) );
  sky130_fd_sc_hd__a22oi_1 U25 ( .A1(n18), .A2(din2[6]), .B1(n17), .B2(din4[6]), .Y(n16) );
  sky130_fd_sc_hd__a22oi_1 U26 ( .A1(n20), .A2(din1[6]), .B1(n19), .B2(din3[6]), .Y(n15) );
  sky130_fd_sc_hd__nand2_1 U27 ( .A(n16), .B(n15), .Y(dout[6]) );
  sky130_fd_sc_hd__a22oi_1 U28 ( .A1(n18), .A2(din2[7]), .B1(n17), .B2(din4[7]), .Y(n22) );
  sky130_fd_sc_hd__a22oi_1 U29 ( .A1(n20), .A2(din1[7]), .B1(n19), .B2(din3[7]), .Y(n21) );
  sky130_fd_sc_hd__nand2_1 U30 ( .A(n22), .B(n21), .Y(dout[7]) );
endmodule


module mux4_registered_WIDTH8_0 ( clk, rst, wr_en, sel, in1, in2, in3, in4, 
        out );
  input [1:0] sel;
  input [7:0] in1;
  input [7:0] in2;
  input [7:0] in3;
  input [7:0] in4;
  output [7:0] out;
  input clk, rst, wr_en;

  wire   [7:0] mux_out;

  mux4_WIDTH8_0 u_mux4 ( .din1(in1), .din2(in2), .din3(in3), .din4(in4), 
        .select(sel), .dout(mux_out) );
  register_bank_WIDTH8_0 u_reg_bank ( .clk(clk), .rst(rst), .wr_en(wr_en), 
        .in(mux_out), .out(out) );
endmodule


module register_bank_WIDTH1_0 ( clk, rst, wr_en, in, out );
  input [0:0] in;
  output [0:0] out;
  input clk, rst, wr_en;
  wire   n1, n2, n5, n6;

  sky130_fd_sc_hd__dfrtp_1 \out_reg[0]  ( .D(n5), .CLK(clk), .RESET_B(n6), .Q(
        out[0]) );
  sky130_fd_sc_hd__o21ai_0 U2 ( .A1(n2), .A2(wr_en), .B1(n1), .Y(n5) );
  sky130_fd_sc_hd__inv_1 U3 ( .A(rst), .Y(n6) );
  sky130_fd_sc_hd__inv_1 U4 ( .A(out[0]), .Y(n2) );
  sky130_fd_sc_hd__nand2_1 U5 ( .A(wr_en), .B(in[0]), .Y(n1) );
endmodule


module top ( clk, rst, cmd_in, din_1, din_2, din_3, dout_low, dout_high, 
        cpu_rdy, zero, error );
  input [6:0] cmd_in;
  input [7:0] din_1;
  input [7:0] din_2;
  input [7:0] din_3;
  output [7:0] dout_low;
  output [7:0] dout_high;
  input clk, rst;
  output cpu_rdy, zero, error;
  wire   aluin_reg_en, nvalid_data, alu_zero, alu_error, aluout_reg_en,
         memoryWrite, memoryRead, selmux2, datain_reg_en, n6;
  wire   [1:0] in_select_a;
  wire   [7:0] mux_a_out;
  wire   [1:0] in_select_b;
  wire   [7:0] mux_b_out;
  wire   [3:0] opcode;
  wire   [15:0] alu_out;
  wire   [15:0] mem_data_out;
  wire   [6:0] cmd_reg_out;

  mux4_registered_WIDTH8_1 mux_A ( .clk(clk), .rst(rst), .wr_en(aluin_reg_en), 
        .sel(in_select_a), .in1(din_1), .in2(din_2), .in3(din_3), .in4(
        dout_high), .out(mux_a_out) );
  mux4_registered_WIDTH8_0 mux_B ( .clk(clk), .rst(rst), .wr_en(aluin_reg_en), 
        .sel(in_select_b), .in1(din_1), .in2(din_2), .in3(din_3), .in4(
        dout_low), .out(mux_b_out) );
  ALU_WIDTH8 u_alu ( .in1(mux_a_out), .in2(mux_b_out), .op(opcode), 
        .invalid_data(nvalid_data), .out(alu_out), .zero(alu_zero), .error(
        alu_error) );
  register_bank_WIDTH1_1 reg_zero ( .clk(clk), .rst(rst), .wr_en(aluout_reg_en), .in(alu_zero), .out(zero) );
  register_bank_WIDTH1_0 reg_error ( .clk(clk), .rst(rst), .wr_en(
        aluout_reg_en), .in(alu_error), .out(error) );
  memory_WIDTH8 u_memory ( .clk(clk), .memoryWrite(memoryWrite), .memoryRead(
        memoryRead), .memoryWriteData({dout_high, dout_low}), .memoryAddress({
        net7670, net7671, net7672, net7673, net7674, mux_a_out[2], n6, 
        mux_a_out[0]}), .memoryOutData(mem_data_out) );
  mux2_registered_WIDTH8 mux_out ( .clk(clk), .rst(rst), .sel(selmux2), 
        .wr_en(aluout_reg_en), .in1(alu_out), .in2(mem_data_out), .out({
        dout_high, dout_low}) );
  register_bank_WIDTH7 reg_cmd ( .clk(clk), .rst(rst), .wr_en(datain_reg_en), 
        .in(cmd_in), .out(cmd_reg_out) );
  control u_control ( .clk(clk), .rst(rst), .cmd_in(cmd_reg_out), .p_error(
        error), .aluin_reg_en(aluin_reg_en), .datain_reg_en(datain_reg_en), 
        .memoryWrite(memoryWrite), .memoryRead(memoryRead), .selmux2(selmux2), 
        .cpu_rdy(cpu_rdy), .aluout_reg_en(aluout_reg_en), .nvalid_data(
        nvalid_data), .in_select_a(in_select_a), .in_select_b(in_select_b), 
        .opcode(opcode) );
  sky130_fd_sc_hd__buf_2 U3 ( .A(mux_a_out[1]), .X(n6) );
endmodule

