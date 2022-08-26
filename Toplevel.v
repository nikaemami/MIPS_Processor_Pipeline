module Top_Level (clk, rst, Memory_out, Inst_out, Pc_out, Ex_Mem_out3, Ex_Mem_out4, Memread, Memwrite);
	input [31:0] Memory_out, Inst_out, Pc_out; 
	input clk, rst;
	output [31:0] Ex_Mem_out3, Ex_Mem_out4;
	output Memread, Memwrite;
	wire Memread, Memwrite, Regwrite_mem, Regwrite_wb;
	wire [31:0] Ex_Mem_out3, Ex_Mem_out4, Inst;
	wire [1:0] ALUOP, M89_ctrl;
	wire [2:0]  ALU_control, Loads;
	wire [5:0] alu_function;
	wire [14:0] ControlSignals;
	wire [17:0] Signals_;
	wire [4:0] Id_Ex_out8, Id_Ex_out6, Ex_Mem_out5, Mem_Wb_out3, Loads_;
	wire ID_EX_memread, Mux_Sel, PcWrite, IF_ID_Write, zero, Comprator;
	wire [9:0] Signal_pass_ex;
	wire [14:0] Signals;
	assign Loads_[4] = PcWrite;
	assign Loads_[3] = IF_ID_Write;
	assign Loads_[2:0] = Loads;
	assign Signals_[17:15] = ALU_control;
	assign Signals_[14:0] = Signals;
	assign ID_EX_memread = Signal_pass_ex[7];
	DP datapath(clk, rst, M89_ctrl, Memory_out, Inst_out, Signals_, Ex_Mem_out3, Ex_Mem_out4, Pc_out, Memread, Memwrite, Id_Ex_out8, Id_Ex_out6, Ex_Mem_out5, Mem_Wb_out3, Regwrite_mem, Regwrite_wb, Inst, Loads_, Signal_pass_ex, Mux_Sel, zero, Comprator);
	ALU_controller alu_ctrl(ALUOP, Inst[5:0], ALU_control);
	main_controller main_ctrl(Signals, ALUOP, Inst, Loads, Comprator);
	Forwarding_Unit FU(Id_Ex_out8, Id_Ex_out6, Ex_Mem_out5, Mem_Wb_out3, Regwrite_mem, Regwrite_wb, M89_ctrl);
	Hazard_Unit HU(ID_EX_memread, Id_Ex_out6, Inst[25:21], Inst[20:16], PcWrite, IF_ID_Write, Mux_Sel);
endmodule

