module sprite_control(	input logic [31:0] pattern,
								input int count,
								input logic CLK, RESET,
								output logic [3:0]  red, green, blue,
								output logic hs, vs
							);
							
	logic pixel_clk, blank, sync;
	logic [9:0] DrawX, DrawY;						
	logic [2:0] CellX, CellY;
	logic [6:0] SpriteX, SpriteY;
	logic [79:0] SpriteData;
	logic [4:0] CellAddr;
	logic pat_pix, count_pix;
	
	//logic [79:0] sprite_rom [60];
	
	vga_controller vgacontroller0(	.Clk(CLK), 
												.Reset(RESET), 
												.hs(hs), 
												.vs(vs),
												.pixel_clk(pixel_clk),
	                                 .blank(blank),    
	                                 .sync(sync),
												.DrawX(DrawX),
												.DrawY(DrawY));
	
	sprite_rom spriterom0(	.addr(SpriteY), .data(SpriteData));
	
	always_comb begin
		CellX = DrawX/80;
		CellY = DrawY/60;
		SpriteX = DrawX % 80;
		SpriteY  = DrawY % 60;
		CellAddr = (8*CellY) + (7-CellX);
		if(DrawY >= 240) 
			pat_pix = 1'b0;
		else if(pattern[CellAddr]==1)
			pat_pix = SpriteData[SpriteX];
		else
			pat_pix = 1'b0;
	end
		

	always_ff @(posedge pixel_clk) begin

		if(!blank) begin
			red = 4'h0;
			green = 4'h0;
			blue = 4'h0;
		end
		else if (DrawY >= 240) begin
			red = 4'h0+DrawY[9:6];
			green = 4'h0+DrawY[9:6];
			blue = 4'h0+DrawY[9:6];		
		end
		else if((DrawX>=(count*640/(16384*8))-1)&&(DrawX<=(count*640/(16384*8))+1)) begin
			red = 4'hf;
			green = 4'hf;
			blue = 4'h5;		
		end
		else if(pat_pix) begin
			if(CellY==0) begin
				red = 4'h5;
				green = 4'h5;
				blue = 4'hf;
			end
			else if(CellY==1) begin
				red = 4'h5;
				green = 4'hf;
				blue = 4'h5;
			end
			else if(CellY==2) begin
				red = 4'h5;
				green = 4'hf;
				blue = 4'hf;
			end
			else if(CellY==3) begin
				red = 4'hf;
				green = 4'h5;
				blue = 4'hf;
			end
			else begin
				red = 4'hf;
				green = 4'hf;
				blue = 4'hf;			
			end
		end
		else begin
			red = 4'h0+DrawY[9:6];
			green = 4'h0+DrawY[9:6];
			blue = 4'h0+DrawY[9:6];
		end

	end

endmodule


module sprite_rom ( input [5:0]	addr,
						output [79:0]	data
					 );

	parameter ADDR_WIDTH = 6;
   parameter DATA_WIDTH =  80;
	//logic [ADDR_WIDTH-1:0] addr_reg;
	parameter [0:2**ADDR_WIDTH-1][DATA_WIDTH-1:0] ROM = {
	
	{{10'b0},{60{1'b1}},{10'b0}},
	{{6'b0}, {68{1'b1}},{6'b0}},
	{{4'b0},{72{1'b1}},{4'b0}},
	{{3'b0},{74{1'b1}},{3'b0}},
	{{2'b0},{76{1'b1}},{2'b0}},
	{{2'b0},{76{1'b1}},{2'b0}},
	{{1'b0},{78{1'b1}},{1'b0}},
	{{1'b0},{78{1'b1}},{1'b0}},
	{{1'b0},{78{1'b1}},{1'b0}},
	{{1'b0},{78{1'b1}},{1'b0}},
	{80{1'b1}},
	{80{1'b1}},
	{80{1'b1}},
	{80{1'b1}},
	{80{1'b1}},
	{80{1'b1}},
	{80{1'b1}},
	{80{1'b1}},
	{80{1'b1}},
	{80{1'b1}},
	{80{1'b1}},
	{80{1'b1}},
	{80{1'b1}},
	{80{1'b1}},
	{80{1'b1}},
	{80{1'b1}},
	{80{1'b1}},
	{80{1'b1}},
	{80{1'b1}},
	{80{1'b1}},
	{{1'b0},{78{1'b1}},{1'b0}},
	{{1'b0},{78{1'b1}},{1'b0}},
	{{1'b0},{78{1'b1}},{1'b0}},
	{{1'b0},{78{1'b1}},{1'b0}},
	{{2'b0},{76{1'b1}},{2'b0}},
	{{2'b0},{76{1'b1}},{2'b0}},
	{{3'b0},{74{1'b1}},{3'b0}},
	{{4'b0},{72{1'b1}},{4'b0}},
	{{6'b0}, {68{1'b1}},{6'b0}},
	{{10'b0},{60{1'b1}},{10'b0}},
	{80'b0},
	{80'b0},
	{80'b0},
	{80'b0},
	{80'b0},
	{80'b0},
	{80'b0},
	{80'b0},
	{80'b0},
	{80'b0},
	{80'b0},
	{80'b0},
	{80'b0},
	{80'b0},
	{80'b0},
	{80'b0},
	{80'b0},
	{80'b0},
	{80'b0},
	{80'b0}
	};
	assign data = ROM[addr];
	
endmodule
