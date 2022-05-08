module memory_control(
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic 			CLK,
	
	// Avalon Reset Input
	input logic 			RESET,
	
	// Avalon-MM Slave Signals
	input  logic 			AVL_READ,			// Avalon-MM Read
	input  logic 			AVL_WRITE,			// Avalon-MM Write
	input  logic 			AVL_CS,				// Avalon-MM Chip Select
	input  logic [3:0] 	AVL_BYTE_EN,		// Avalon-MM Byte Enable
	input  logic [11:0] 	AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] 	AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] 	AVL_READDATA,		// Avalon-MM Read Data
	
	output logic [31:0] pattern
	
);

	Ram ram0(	.address_a(AVL_ADDR),
					.address_b(0),
					.byteena_a(AVL_BYTE_EN),
					.clock(CLK),
					.data_a(AVL_WRITEDATA),
					.data_b(),
					.rden_a(AVL_READ && AVL_CS),
					.rden_b(1),
					.wren_a(AVL_WRITE && AVL_CS),
					.wren_b(0),
					.q_a(AVL_READDATA),
					.q_b(pattern));
					
			
endmodule
