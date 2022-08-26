`define S0 3'd0
`define S1 3'd1
`define S2 3'd2
`define S3 3'd3
`define S4 3'd4

module ALU(A, B, ALU_control, ALU_out, zero, negative);
	input [31:0]A, B;
	input [2:0] ALU_control;
	output [31:0] ALU_out;
	output zero, negative;
	reg zero, negative;
	reg [31:0] ALU_out;
	initial begin negative = 1'b0;end
	always@(A, B, ALU_control) begin
		case(ALU_control)
			`S0:ALU_out = A+B;
			`S1:ALU_out = A-B;
			`S2:ALU_out = A&B;
			`S3:ALU_out = A|B;
			`S4:negative = A<B?1'b1:1'b0;
			default:ALU_out = A+B;
		endcase
	end
	assign zero = A==B?1'b1:1'b0;
endmodule

module mux2to1_5(A, B, Sel, Out);
	input [4:0] A, B;
	input Sel;
	output [4:0] Out;
	assign Out = (~Sel)?A:
		 (Sel)?B:5'bx;
endmodule

module mux2to1_32(A, B, Sel, Out);
	input [31:0] A, B;
	input Sel;
	output [31:0] Out;
	assign Out = (~Sel)?A:
		 (Sel)?B:32'bx;
endmodule

module mux2to1_32(A, B, Sel, Out);
	input [31:0] A, B;
	input Sel;
	output [31:0] Out;
	assign Out = (~Sel)?A:
		 (Sel)?B:32'bx;
endmodule

module mux2to1_18(A, B, Sel, Out);
	input [17:0] A, B;
	input Sel;
	output [17:0] Out;
	assign Out = (~Sel)?A:
		 (Sel)?B:18'bx;
endmodule

module Register_5(clk, rst, Input, Output);
	input clk, rst;
	input[4:0] Input;
	output [4:0] Output;
	reg [4:0] Output;
	always@(posedge clk, posedge rst)begin
		if(rst)
			Output <= 5'b0;
		else
			Output <= Input;
	end
endmodule

module Register_32(clk, rst, Input, Output);
	input clk, rst;
	input[31:0] Input;
	output [31:0] Output;
	reg [31:0] Output;
	always@(posedge clk, posedge rst)begin
		if(rst)
			Output <= 32'b0;
		else
			Output <= Input;
	end
endmodule

module Sign_Extend_26(clk, rst, Input, Output);
	input [25:0]Input;
	input clk, rst;
	output [31:0]Output;
	assign Output = {6'b0, Input};
	/*reg [31:0]Output;
	always@(posedge clk, posedge rst)begin
		if(rst)
			Output <= 32'b0;
		else
			Output <= {6'b0, Input};
	end*/
endmodule

module Sign_Extend(clk, rst, Input, Output);
	input [15:0] Input;
	input clk, rst;
	output [31:0] Output;
	//reg [31:0]Output;
	assign Output = {16'd0, Input};
	/*always@(posedge clk, posedge rst)begin
		if(rst)
			Output <= 32'b0;
		else
			Output <= {16'd0, Input};
	end*/
endmodule

module Shift_Left_2(Input, Output);
	input [31:0]Input;
	output [31:0]Output;
	assign Output = {Input[29:0], 2'd0};
endmodule

module adder_32(A, B, Sum);
	input [31:0]A, B;
	output [31:0]Sum;
	assign Sum = A+B;
endmodule

module Register_File(clk, rst, Read_Reg1, Read_Reg2, Write_Reg, Write_Data, RegWrite, Read1, Read2);
	input [4:0] Read_Reg1, Read_Reg2, Write_Reg;
	input [31:0] Write_Data;
	input RegWrite, clk, rst;
	output [31:0] Read1, Read2;
	reg [0:31][31:0] registers;
	reg [31:0] Read1, Read2;
	integer n;
	always@(posedge clk, posedge rst)begin
		if(rst)
			for(n=0; n<32; n = n+1)begin
				registers[n] <= 32'b0;
			end
		/*Read1 <= registers[Read_Reg1][31:0];
		Read2 <= registers[Read_Reg2][31:0];*/
	end
	always@(negedge clk)begin
		if(RegWrite)begin
			registers[Write_Reg][31:0] <= Write_Data;
		end
	end
	assign Read1 = registers[Read_Reg1][31:0];
	assign Read2 = registers[Read_Reg2][31:0];
endmodule

module PC(clk, rst, ld, Input, Output);
	input [31:0] Input;
	input clk, rst, ld;
	output [31:0] Output;
	reg [31:0] Output;
	always@(posedge clk)begin
		if(rst) 
			Output <= 32'b0;
		else if (ld)
			Output <= Input;
		else Output <= Output;
	end
endmodule

module Pipe_IF_ID(clk, rst, ld, IF, A, B, Out1, Out2, IF_pass);
	input clk, rst, ld;
	input [31:0] A, B;
	input [17:0] IF;
	output [31:0] Out1, Out2;
	output [17:0] IF_pass;
	reg [17:0] IF_pass; 
	reg [31:0] Out1, Out2;
	assign IF_pass = IF;
	always@(posedge clk)begin
		if (rst)begin
			Out1 <= 32'b0;
			Out2 <= 32'b0;
			//IF_pass <= IF;
		end
		else if(ld) begin
			Out1 <= A;
			Out2 <= B;
			//IF_pass <= IF;
		end
		else begin
			Out1 <= Out1;
			Out2 <= Out2;
			//IF_pass <= IF_pass;
		end
	end
endmodule

module Pipe_ID_EX(clk, rst, ld, A, B, C, D, E, F, G, H, Ex, Out1, Out2, Out3, Out4, Out5, Out6, Out7, Out8, Ex_use, Ex_pass);
	input clk, rst, ld;
	input [31:0] A, B, C, D, E;
	input [4:0] F, G, H;
	input [17:0] Ex;
	output [31:0] Out1, Out2, Out3, Out4, Out5;
	output [4:0] Out6, Out7, Out8;
	output [7:0] Ex_use;
	output [9:0] Ex_pass;
	reg [31:0] Out1, Out2, Out3, Out4, Out5;
	reg [4:0] Out6, Out7, Out8;
	reg [7:0] Ex_use;
	reg [9:0] Ex_pass;
	//assign Ex_pass = Ex[9:0];
	//assign Ex_use = Ex[17:10];
	always@(posedge clk)begin
		if (rst)begin
			Out1 <= 32'b0;
			Out2 <= 32'b0;
			Out3 <= 32'b0;
			Out4 <= 32'b0;
			Out5 <= 32'b0;
			Out6 <= 5'b0;
			Out7 <= 5'b0;
			Out8 <= 5'b0;
			//Ex_pass <= Ex[9:0];
			//Ex_use <= Ex[17:10];
		end
		else if(ld)begin
			Out1 <= A;
			Out2 <= B;
			Out3 <= C;
			Out4 <= D;
			Out5 <= E;
			Out6 <= F;
			Out7 <= G;
			Out8 <= H;
			Ex_pass <= Ex[9:0];
			Ex_use <= Ex[17:10];
		end
		else begin
			Out1 <= Out1;
			Out2 <= Out2;
			Out3 <= Out3;
			Out4 <= Out4;
			Out5 <= Out5;
			Out6 <= Out6;
			Out7 <= Out7;
			Out8 <= Out8;
			Ex_pass <= Ex_pass;
			Ex_use <= Ex_use;
		end
	end
endmodule

module Pipe_EX_MEM(clk, rst, ld, Sel, M, A, B, C, D, E, F, G, Out1, Out2, Out3, Out4, Out5, Out6, M_use, M_pass, negative_flag);
	input clk, rst, B, G, ld, negative_flag;
	input [31:0] A, C, D, E;
	input [4:0] F;
	input [1:0] Sel;
	input [9:0] M;
	output Out2, Out6;
	output [31:0] Out1, Out3, Out4;
	output [4:0] Out5, M_use;
	output [5:0] M_pass;
	reg Out2, Out6;
	reg [31:0] Out1, Out3, Out4;
	reg [4:0] Out5, M_use;
	reg [5:0] M_pass;
	//assign M_pass = M[4:0];
	//assign M_use = M[9:5];
	always@(posedge clk)begin
		if (rst)begin
			Out1 <= 32'b0;
			Out2 <= 1'b0;
			Out3 <= 32'b0;
			Out4 <= 32'b0;
			Out5 <= 5'b0;
			Out6 <= 1'b0;
		end
		else if(ld)begin
			Out1 <= (Sel == 2'b00)?A:
		 		(Sel == 2'b01)?C:
		 		(Sel == 2'b10)?D:32'bx;
			Out2 <= B;
			Out3 <= C;
			Out4 <= E;
			Out5 <= F;
			Out6 <= G;
			M_pass <= {negative_flag, M[4:0]};
			M_use <= M[9:5];
		end
		else begin
			Out1 <= Out1;
			Out2 <= Out2;
			Out3 <= Out3;
			Out4 <= Out4;
			Out5 <= Out5;
			Out6 <= Out6;
			M_pass <= M_pass;
			M_use <= M_use;
		
		end
	end
endmodule

module Pipe_MEM_WB(clk, rst, ld, Wb, A, B, C, Out1, Out2, Out3, Wb_use);
	input clk, rst, ld;
	input [31:0] A, B;
	input [4:0] C;
	input [5:0] Wb;
	output [31:0] Out1, Out2;
	output [4:0] Out3;
	output [5:0] Wb_use;
	reg [31:0] Out1, Out2;
	reg [4:0] Out3;
	reg [5:0] Wb_use;
	//assign Wb_use = Wb[4:0];
	always@(posedge clk)begin
		if (rst)begin
			Out1 <= 32'b0;
			Out2 <= 32'b0;
			Out3 <= 5'b0;
		end
		else if(ld) begin
			Out1 <= A;
			Out2 <= B;
			Out3 <= C;
			Wb_use <= Wb[5:0];
		end
		else begin
			Out1 <= Out1;
			Out2 <= Out2;
			Out3 <= Out3;
			Wb_use <= Wb_use;
		end
	end
endmodule