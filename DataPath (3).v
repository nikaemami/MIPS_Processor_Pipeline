`define  Beq 6'd5
`define  J 6'd6
`define  Jr 6'd7
`define  Jal 6'd8

module DP(clk, rst, M89_ctrl, Memory_out, Inst_out, Signals, Ex_Mem_out3, Ex_Mem_out4, Pc_out, Memread, Memwrite, Id_Ex_out8, Id_Ex_out6, Ex_Mem_out5, Mem_Wb_out3, Regwrite_mem, Regwrite_wb, Inst, Loads, Signal_pass_ex, MUXSEL, zero, Comprator);
	input clk, rst, MUXSEL;
	input [1:0] M89_ctrl;
	input [17:0] Signals;
	input [31:0] Memory_out, Inst_out;
	input [4:0] Loads;
	wire [2:0] Aluop;
	output [31:0] Ex_Mem_out3, Ex_Mem_out4, Pc_out, Inst;
	output Memread, Memwrite, Regwrite_mem, Regwrite_wb, zero, Comprator;
	output [4:0] Mem_Wb_out3, Ex_Mem_out5, Id_Ex_out8, Id_Ex_out6;
	output [9:0] Signal_pass_ex;
	wire [31:0] M13_out, R4_out, Ex_Mem_out4, Ex_Mem_out3, Result, M10_out, M11_out, Memory_out, Inst_out, M7_out, M5_out, Mem_Wb_out1, Mem_Wb_out2, Ex_Mem_out1, Ex_Mem_out2, Ex_Mem_out5, Ex_Mem_out6, M6_out, M3_out, M2_out, M9_out, M8_out, Add_Ex_out, Shl2_out, M1_out, M4_out, Add_If_out, Inst, If_Id_out1, Read1, Read2, Se26_out, Se16_out, Id_Ex_out1, Id_Ex_out2, Id_Ex_out3, Id_Ex_out4, Id_Ex_out5;
	wire [4:0] R1_out, R2_out, R3_out, Loads, Mem_Wb_out3, Id_Ex_out6, Id_Ex_out7, Id_Ex_out8, Signal_use_m;
	wire M13_ctrl, Regwrite_mem, Regwrite_wb, Memread, Memwrite, M10_ctrl, zero, negative, clk, rst, Regwrite, Ld_id_ex, Ld_if_id, Alu_src, M3_ctrl, Regdst, Ld_ex_mem, Ld_mem_wb, Memtoreg, M5_ctrl, M7_ctrl, Pcsrc;
	wire [5:0] Signal_use_wb, Signal_pass_m;
	wire [1:0] Ex_Mem_sel, M89_ctrl;
	wire [17:0] Signals, Signals_pass, Signal_;
	wire [7:0] Signal_use_ex;
	wire [9:0] Signal_pass_ex;
	wire LD_pc, LD_IF, LD_ID, LD_EX, LD_MEM, Comprator;
	assign Comprator = (Read1 == Read2)?1'b1:1'b0;
	assign Aluop = Signal_use_ex[7:5];
	assign Alu_src = Signal_use_ex[4];
	assign M3_ctrl = Signal_use_ex[3];
	assign M8_ctrl = Signal_use_ex[2];
	assign M9_ctrl = Signal_use_ex[1];
	assign Regdst = Signal_use_ex[0];
	assign Ex_Mem_sel = Signal_use_m[4:3];
	assign Memread = Signal_use_m[2];
	assign Memwrite = Signal_use_m[1];
	assign Pcsrc = (/*Inst_out[31:26] != `Beq && */Inst_out[31:26] !=`J && Inst_out[31:26] != `Jr && Inst_out[31:26] !=` Jal)?Signals[5]:Signal_use_m[0];
	assign Memtoreg = Signal_use_wb[4];
	assign M5_ctrl = Signal_use_wb[3];
	assign M7_ctrl = Signal_use_wb[2];
	assign M10_ctrl = Signal_use_wb[1];
	assign Regwrite = Signal_use_wb[0];
	assign Regwrite_mem = Signal_pass_ex[0];
	assign Regwrite_wb = Signal_use_wb[0];
	assign LD_pc = Loads[4];
	assign LD_IF = Loads[3];
	assign LD_ID = Loads[2];
	assign LD_EX = Loads[1];
	assign LD_MEM = Loads[0];
	assign M13_ctrl = (Signals_pass[9:8] == 2'b00)?1'b0:(Signals_pass[9:8] == 2'b10)?1'b1:1'bz;
	mux2to1_18 M12(18'd0, Signals_pass, MUXSEL, Signal_);
	mux2to1_32 M13(Add_Ex_out, Se26_out, M13_ctrl, M13_out);
	PC pc(clk, rst, LD_pc, M1_out, Pc_out);
	adder_32 adder_IF(32'd4, Pc_out, Add_If_out);
	Register_File RF(clk, rst, Inst[25:21], Inst[20:16], M5_out, M10_out, Regwrite, Read1, Read2);
	Sign_Extend_26 Se26(clk, rst, Inst[25:0], Se26_out);
	Sign_Extend Se16(clk, rst, Inst[15:0], Se16_out);
	Shift_Left_2 ShL2(Se16_out, Shl2_out);
	adder_32 adder_EX(If_Id_out1, Shl2_out, Add_Ex_out);
	ALU alu(M8_out, M3_out, Aluop, Result, zero, negative);
	mux2to1_32 M1(Add_If_out, M13_out, Pcsrc, M1_out);
	mux2to1_32 M2(M9_out, Id_Ex_out5, Alu_src, M2_out);
	mux2to1_32 M3(M2_out, 32'b0, M3_ctrl, M3_out);
	mux2to1_32 M4(Mem_Wb_out2, Mem_Wb_out1, Memtoreg, M4_out);
	mux2to1_5 M5(Mem_Wb_out3, 32'd31, M5_ctrl, M5_out);
	mux2to1_5 M6(Id_Ex_out6, Id_Ex_out7, Regdst, M6_out);
	mux2to1_32 M7(M4_out, Add_If_out, M7_ctrl, M7_out);
	mux2to1_32 M10(M4_out, M11_out, M10_ctrl, M10_out);
	mux2to1_32 M11(32'b0, 32'd1, Signal_use_wb[5], M11_out);
	mux4to1_32 M8(Id_Ex_out2, M4_out, Ex_Mem_out3, 32'bx, M89_ctrl, M8_out);
	mux4to1_32 M9(Id_Ex_out3, M4_out, Ex_Mem_out3, 32'bx, M89_ctrl, M9_out);

	Register_5 R1(clk, rst, Inst[20:16], R1_out);
	Register_5 R2(clk, rst, Inst[15:11], R2_out);
	Register_5 R3(clk, rst, Inst[25:21], R3_out);
	Register_32 R4(clk, rst, If_Id_out1, R4_out);

	Pipe_IF_ID pipe_if_id(clk, rst, LD_IF, Signals, Add_If_out, Inst_out, If_Id_out1, Inst, Signals_pass);
	Pipe_ID_EX pipe_id_ex(clk, rst, LD_ID, If_Id_out1, Read1, Read2, Se26_out, Se16_out, Inst[20:16], Inst[15:11], Inst[25:21], Signal_, Id_Ex_out1, Id_Ex_out2, Id_Ex_out3, Id_Ex_out4, Id_Ex_out5, Id_Ex_out6, Id_Ex_out7, Id_Ex_out8, Signal_use_ex, Signal_pass_ex);
	Pipe_EX_MEM pipe_ex_mem(clk, rst, LD_EX, Ex_Mem_sel, Signal_pass_ex, Add_Ex_out, zero, Result, Id_Ex_out4, Id_Ex_out3, M6_out, negative, Ex_Mem_out1, Ex_Mem_out2, Ex_Mem_out3, Ex_Mem_out4, Ex_Mem_out5, Ex_Mem_out6, Signal_use_m, Signal_pass_m, negative);
	Pipe_MEM_WB pipe_mem_wb(clk, rst, LD_MEM, Signal_pass_m, Memory_out, Ex_Mem_out3, Ex_Mem_out5, Mem_Wb_out1, Mem_Wb_out2, Mem_Wb_out3, Signal_use_wb);
endmodule
