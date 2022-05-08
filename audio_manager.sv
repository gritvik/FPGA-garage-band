module audio_manager(	//input 	KEY,
								input		lrclk,
								input [31:0] pattern,
								output [31:0] out,
								output int count
);

logic [13:0] addr;
logic [31:0] audio_A, audio_B, audio_C, audio_D;
enum logic [2:0] {S0, S1, S2, S3, S4, S5, S6, S7} state, next_state;


always_comb begin
	case(state)
		S0: next_state = S1;
		S1: next_state = S2;
		S2: next_state = S3;
		S3: next_state = S4;
		S4: next_state = S5;
		S5: next_state = S6;
		S6: next_state = S7;
		S7: next_state = S0;
	endcase
end

always_comb begin
	case(state)
		S0: count = (0*16384)+addr; 
		S1: count = (1*16384)+addr;
		S2: count = (2*16384)+addr;
		S3: count = (3*16384)+addr;
		S4: count = (4*16384)+addr;
		S5: count = (5*16384)+addr;
		S6: count = (6*16384)+addr;
		S7: count = (7*16384)+addr;
	endcase
end

always_comb begin
	case(state) 

		S0 : out = 	(audio_A*pattern[(0*8)+7])+(audio_B*pattern[(1*8)+7])+
						(audio_C*pattern[(2*8)+7])+(audio_D*pattern[(3*8)+7]);
		S1 : out = 	(audio_A*pattern[(0*8)+6])+(audio_B*pattern[(1*8)+6])+
						(audio_C*pattern[(2*8)+6])+(audio_D*pattern[(3*8)+6]);
		S2 : out = 	(audio_A*pattern[(0*8)+5])+(audio_B*pattern[(1*8)+5])+
						(audio_C*pattern[(2*8)+5])+(audio_D*pattern[(3*8)+5]); 
		S3 : out = 	(audio_A*pattern[(0*8)+4])+(audio_B*pattern[(1*8)+4])+
						(audio_C*pattern[(2*8)+4])+(audio_D*pattern[(3*8)+4]);
		S4 : out = 	(audio_A*pattern[(0*8)+3])+(audio_B*pattern[(1*8)+3])+
						(audio_C*pattern[(2*8)+3])+(audio_D*pattern[(3*8)+3]); 
		S5 : out = 	(audio_A*pattern[(0*8)+2])+(audio_B*pattern[(1*8)+2])+
						(audio_C*pattern[(2*8)+2])+(audio_D*pattern[(3*8)+2]);
		S6 : out = 	(audio_A*pattern[(0*8)+1])+(audio_B*pattern[(1*8)+1])+
						(audio_C*pattern[(2*8)+1])+(audio_D*pattern[(3*8)+1]);
		S7 : out = 	(audio_A*pattern[(0*8)+0])+(audio_B*pattern[(1*8)+0])+
						(audio_C*pattern[(2*8)+0])+(audio_D*pattern[(3*8)+0]); 

	  endcase
end

always_ff@(negedge addr[13]) begin
	state <= next_state;
end

always_ff@(posedge lrclk) begin
	addr <= addr + 1'b1;
end

audioromA audioA(.addr(addr), .data_Out(audio_A));
audioromB audioB(.addr(addr), .data_Out(audio_B));
audioromC audioC(.addr(addr), .data_Out(audio_C));
audioromD audioD(.addr(addr), .data_Out(audio_D));

endmodule

module audioromA(input logic [13:0] addr, output logic [31:0] data_Out);//output logic [7:0] data_Out);
	logic [7:0] mem [5292];
	initial $readmemh("audio_files/8_snare_audio.txt", mem);
	always_comb begin
		if (addr>5292)
			data_Out <= 32'h0000;
		else
			data_Out <= {{7'b0},mem[addr],{17'b0}};
	end
endmodule

module audioromB(input logic [13:0] addr, output logic [31:0] data_Out);//output logic [7:0] data_Out);
	logic [7:0] mem [13230];
	initial $readmemh("audio_files/8_piano_audio.txt", mem);
	always_comb begin
		if (addr>13230)
			data_Out <= 32'h0000;
		else
			data_Out <= {{7'b0},mem[addr],{17'b0}};
	end
endmodule

module audioromC(input logic [13:0] addr, output logic [31:0] data_Out);//output logic [7:0] data_Out);
	logic [7:0] mem [13230];
	initial $readmemh("audio_files/8_kick_audio.txt", mem);
	always_comb begin
		if (addr>13230)
			data_Out <= 32'h0000;
		else
			data_Out <= {{4'b0},mem[addr],{20'b0}};
	end
endmodule

module audioromD(input logic [13:0] addr, output logic [31:0] data_Out);//output logic [7:0] data_Out);
	logic [7:0] mem [6966];
	initial $readmemh("audio_files/8_hat_audio.txt", mem);
	always_comb begin
		if (addr>6966)
			data_Out <= 32'h0000;
		else
			data_Out <= {{7'b0},mem[addr],{17'b0}};
	end
endmodule
