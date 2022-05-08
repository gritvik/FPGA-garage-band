module i2s(	input	sclk,
				input	lrclk,
				//input [7:0] bits_8,
				//input	data_in,
input [31:0] in,
				// Parallel datastreams
				output i2s_din
);
//	logic [31:0] in;
	logic [31:0] l_reg, r_reg;
//	logic [7:0] bits_8;
	logic l_out, r_out;
	
//	audiorom audiorom0 (
//		.clk(lrclk),
//		.data_Out(bits_8)
//	);

	//assign in = {{1'b0},{3{bits_8[7]}},bits_8,{20'b0}};
	//assign in = {{5'b0},bits_8,{19'b0}};
	
	always_ff @(negedge sclk) begin
		if(lrclk)
			l_reg <= in;
		else begin
			l_out <= l_reg[31];
			l_reg <= {l_reg[30:0],{1'b0}};
		end
	end
	
	always_ff @(negedge sclk) begin
		if(~lrclk)
			r_reg <= in;
		else begin
			r_out <= r_reg[31];
			r_reg <= {r_reg[30:0],{1'b0}};
		end
	end
	
	always_comb begin
		if(lrclk)
			i2s_din <= r_out;
		else
			i2s_din <= l_out;
	end
				
endmodule
//din is connected to line-out (headphone jack)
//freq sample of 44.1kHz
//samples are 8 to 32 bits
//shifting 64*LRCLK
//1 dummy bit, 8 bits sample, 23 zeros} shift register
//
//ld 8 bits from memory
//shift 1 bit at a time @ posedge SCLK
//every LR clk, ld again
//
//inputs: memory address
//			lrclk
//			sclk
//output: i2sdin


//module audiorom
//(
//		input logic clk,
//		output logic [7:0] data_Out
//);
//	// mem has width of 3 bits and a total of 400 addresses
//	logic [7:0] mem [5336];
//	logic [12:0] addr;
//
//	initial begin
//		 $readmemh("snare_audio.txt", mem);
//	end
//
//	always @(posedge clk) begin
//
//		addr<= addr + 1'b1;
//			
//		if (addr>(5336))
//			data_Out<= 2'h00;
//		else
//			data_Out <= mem[addr];
//	end
//
//endmodule

