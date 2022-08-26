`timescale 1ns/1ns

`define  Add 6'b000001
`define  Sub 6'b000010
`define  And 6'b000100
`define  Or 6'b001000
`define  Slt 6'b010000

`define  R_TYPE 6'd0
`define  Addi 6'd1
`define  Slti 6'd2
`define  Lw 6'd3
`define  Sw 6'd4
`define  Beq 6'd5
`define  J 6'd6
`define  Jr 6'd7
`define  Jal 6'd8

`define RT 2'd0
`define SLA 2'd1
`define SB 2'd2

module ALU_controller(ALUOP, alu_function, ALU_control);
	input [1:0] ALUOP;
	input [5:0] alu_function;
	output [2:0] ALU_control;
	reg [2:0] ALU_control;
	always @(ALUOP, alu_function)begin
		if(ALUOP == `RT)
			case(alu_function)
				`Add:ALU_control = 3'd0;
				`Sub:ALU_control = 3'd1;
				`And:ALU_control = 3'd2;
				`Or:ALU_control = 3'd3;
				`Slt:ALU_control = 3'd4;
			endcase
		else if(ALUOP == `SLA)
			ALU_control = 3'd0;
		else if(ALUOP == `SB)
			ALU_control = 3'd1;
	end
endmodule

module main_controller(ControlSignals, ALUOP, ctrl_in, Loads, zero);
	input [31:0]ctrl_in;
	input zero;
	/*output sel_wr_2, sel_wr_1, RegWrite, sel_B, MemRead, MemWrite, MemtoReg, branch, sel_data, sel_pc_1, pc_src, slt_sel;*/
	output [1:0] ALUOP;
	//                     14      13      12      11       10        9:8        7        6        5       4        3         2        1        0
	//ControlSignals = [Alusrc, M3_ctrl, M8_ctrl, M9_ctrl, Regdst, Ex_Mem_sel, Memread, Memwrite, Pcsrc, Memtoreg, M5_ctrl, M7_ctrl, M10_crl, regwrite]
	//	     2      1      0
	//Loads = [LD_ID, LD_EX, LD_MEM]
	output[14:0] ControlSignals;
	output [2:0] Loads;
	reg [14:0] ControlSignals;
	reg [1:0] ALUOP;
	reg [2:0] Loads;
	/*reg sel_wr_2, sel_wr_1, RegWrite, sel_B, MemRead, MemWrite, MemtoReg, branch, sel_data, sel_pc_1, pc_src, slt_sel;
	reg [1:0] ALUOP;*/
	always@(ctrl_in) begin
		ControlSignals = 15'b0;
		Loads = 3'b111;
		if(ctrl_in[31:26] == `R_TYPE && ctrl_in[5:0] == `Slt)begin
			{ControlSignals[0], ControlSignals[10], ControlSignals[1]} = 3'b111; ALUOP=2'b00;end
		else if (ctrl_in[31:26] == `R_TYPE)
			begin{ControlSignals[0], ControlSignals[10]} = 2'b11;ALUOP=2'b00;end
		case(ctrl_in[31:26])
			`Addi:begin{ControlSignals[0], ControlSignals[14]} = 2'b11; ALUOP=2'b01;end
			`Slti:begin{ControlSignals[0], ControlSignals[14], ControlSignals[1]} = 3'b111;ALUOP=2'b10;end
			`Lw:begin{ControlSignals[0], ControlSignals[14], ControlSignals[7], ControlSignals[4]} = 4'b1111;ALUOP=2'b01;end
			`Sw:begin{ControlSignals[6], ControlSignals[14]} = 2'b11;ALUOP=2'b01;end
			`Beq:begin if(zero)ControlSignals[5]=1'b1;else ControlSignals[5]=1'b0;ControlSignals[9:8]=2'b00;ALUOP=2'b10;end
			`J:begin{ControlSignals[5], ControlSignals[9:8]} = 3'b110;end
			`Jr:begin{ControlSignals[13], ControlSignals[5], ControlSignals[9:8]} = 4'b1101;end
			`Jal:begin{ControlSignals[5], ControlSignals[0], ControlSignals[3], ControlSignals[9:8]} = 4'b11110;end
		endcase
	end
endmodule

module Forwarding_Unit(Id_Ex_out8, Id_Ex_out6, Ex_Mem_out5, Mem_Wb_out3, Regwrite_mem, Regwrite_wb, M89_sel);
	input [4:0] Id_Ex_out8, Id_Ex_out6, Ex_Mem_out5, Mem_Wb_out3;
	input Regwrite_mem, Regwrite_wb;
	output [1:0] M89_sel;
	reg [1:0] M89_sel;
	//assign M89_sel = Regwrite_mem ? ((Ex_Mem_out5 == Id_Ex_out8) ? (Ex_Mem_out5 != 0)):  
	always@(Id_Ex_out8, Id_Ex_out6, Ex_Mem_out5, Mem_Wb_out3, Regwrite_mem, Regwrite_wb)begin
		if(Regwrite_mem == 1'b1 && Ex_Mem_out5 == Id_Ex_out8 && Ex_Mem_out5 != 5'b0) M89_sel=2'b10;
		else if ( Regwrite_wb == 1'b1 && Mem_Wb_out3 == Id_Ex_out8 && Mem_Wb_out3 != 5'b0 && ~(Regwrite_mem == 1'b1 && Ex_Mem_out5 == Id_Ex_out8 && Ex_Mem_out5 != 5'b0)) M89_sel=2'b01;
		else M89_sel=2'b00;
	end
endmodule

module Hazard_Unit(ID_EX_memread, ID_EX_Register_Rt, Rs, Rt, PcWrite, IF_ID_Write, Mux_Sel);
	input ID_EX_memread;
	input [4:0] ID_EX_Register_Rt, Rs, Rt;
	output PcWrite, IF_ID_Write, Mux_Sel;
	reg PcWrite, IF_ID_Write, Mux_Sel;
	//initial begin {PcWrite, IF_ID_Write, Mux_Sel} = 3'b111; end
	always@(ID_EX_Register_Rt, Rs, Rt, ID_EX_memread)begin
		if (ID_EX_memread == 1'b1 && (ID_EX_Register_Rt == Rs || ID_EX_Register_Rt == Rt)) PcWrite = 1'b0;
		else PcWrite = 1'b1;
		if (ID_EX_memread == 1'b1 && (ID_EX_Register_Rt == Rs || ID_EX_Register_Rt == Rt)) IF_ID_Write = 1'b0;
		else IF_ID_Write = 1'b1;
		if (ID_EX_memread == 1'b1 && (ID_EX_Register_Rt == Rs || ID_EX_Register_Rt == Rt)) Mux_Sel = 1'b0;
		else Mux_Sel = 1'b1;
	end
endmodule