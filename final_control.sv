module final_control(

      ///////// Clocks /////////
      input    MAX10_CLK1_50,
					MAX10_CLK2_50,

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,

      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N 

);

//=======================================================
//  I2C
//=======================================================

	logic	i2c_serial_scl_in,
			i2c_serial_scl_oe,
			i2c_serial_sda_in,
			i2c_serial_sda_oe,
			arduino_adc_scl,
			arduino_adc_sda;
	logic [1:0] aud_mclk_ctr;

	assign ARDUINO_IO[3] = aud_mclk_ctr[1]; //master clk
	always_ff@(posedge MAX10_CLK2_50) begin
		aud_mclk_ctr <= aud_mclk_ctr +1;
	end

	assign i2c_serial_scl_in = ARDUINO_IO[15];
	assign ARDUINO_IO[15] = i2c_serial_scl_oe ? 1'b0 : 1'bz;
	
	assign i2c_serial_sda_in = ARDUINO_IO[14];
	assign ARDUINO_IO[14] = i2c_serial_sda_oe ? 1'b0 : 1'bz;
	
	assign ARDUINO_IO[2] = ARDUINO_IO[1];
	//assign ARDUINO_IO[1] = 1'bZ;
	
//=======================================================
//  I2S
//=======================================================	
	//logic [7:0] bits_8;
	logic [31:0] bits_32;
	logic [31:0] pattern;
	int count;
	i2s i2s0 (
		.i2s_din(ARDUINO_IO[1]),
		.lrclk(ARDUINO_IO[4]),
		.in(bits_32),
		.sclk(ARDUINO_IO[5])
	);
	
	audio_manager am0 (
		.lrclk(ARDUINO_IO[4]),
		.pattern(pattern),
		.out(bits_32),
		.count(count)
	);

//=======================================================
//  sprite
//=======================================================
	
	sprite_control(	.pattern(pattern),
							.count(count),
							.CLK(MAX10_CLK1_50),
							.RESET(1'b0),
							.red(VGA_R), 
							.green(VGA_G), 
							.blue(VGA_B),
							.hs(VGA_HS), 
							.vs(VGA_VS)
							);


//=======================================================
//  REG/WIRE declarations
//=======================================================
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; //4 bit input hex digits
	logic [1:0] signs;
	logic [1:0] hundreds;
	logic [7:0] keycode;

//=======================================================
//  Structural coding
//=======================================================
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ;
	assign USB_IRQ = ARDUINO_IO[9];
	
	//Assignments specific to Sparkfun USBHostShield-v13
	//assign ARDUINO_IO[7] = USB_RST;
	//assign ARDUINO_IO[8] = 1'bZ;
	//assign USB_GPX = ARDUINO_IO[8];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[8] = 1'bZ;
	//GPX is unconnected to shield, not needed for standard USB host - set to 0 to prevent interrupt
	assign USB_GPX = 1'b0;
	
	//HEX drivers to convert numbers to HEX output
	HexDriver hex_driver4 (hex_num_4, HEX4[6:0]);
	assign HEX4[7] = 1'b1;
	
	HexDriver hex_driver3 (hex_num_3, HEX3[6:0]);
	assign HEX3[7] = 1'b1;
	
	HexDriver hex_driver1 (hex_num_1, HEX1[6:0]);
	assign HEX1[7] = 1'b1;
	
	HexDriver hex_driver0 (hex_num_0, HEX0[6:0]);
	assign HEX0[7] = 1'b1;
	
	//fill in the hundreds digit as well as the negative sign
	assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
	assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
	
	
	assign {Reset_h}=~ (KEY[0]); 

	//assign signs = 2'b00;
	//assign hex_num_4 = 4'h4;
	//assign hex_num_3 = 4'h3;
	//assign hex_num_1 = 4'h1;
	//assign hex_num_0 = 4'h0;
	
	//remember to rename the SOC as necessary
	 final_soc u0 (
		.clk_clk(MAX10_CLK1_50),					//clk.clk
		.reset_reset_n(1'b1),						//reset.reset_n
	
		.key_external_connection_export(KEY),	//key_external_connection.export
		.sw_export(SW),                      	//sw.export
	
		.sdram_clk_clk(DRAM_CLK),					//sdram_clk.clk
		.sdram_wire_addr(DRAM_ADDR),				//sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),					//.ba
		.sdram_wire_cas_n(DRAM_CAS_N),			//.cas_n
		.sdram_wire_cke(DRAM_CKE),					//.cke
		.sdram_wire_cs_n(DRAM_CS_N),				//.cs_n
		.sdram_wire_dq(DRAM_DQ),					//.dq
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),//.dqm
		.sdram_wire_ras_n(DRAM_RAS_N),			//.ras_n
		.sdram_wire_we_n(DRAM_WE_N),				//.we_n
	
		.spi0_MISO(SPI0_CS_N),						//spi0.MISO
		.spi0_MOSI(SPI0_MOSI),						//    .MOSI
		.spi0_SCLK(SPI0_MISO),						//    .SCLK
		.spi0_SS_n(SPI0_SCLK),						//    .SS_n
			
		.usb_gpx_export(USB_GPX),					//usb_gpx.export
		.usb_irq_export(USB_IRQ),					//usb_irq.export
		.usb_rst_export(USB_RST),					//usb_rst.export
			
		.hex_digits_export({hex_num_4, hex_num_3, hex_num_1, hex_num_0}),	//hex_digits.export
		.keycode_export(keycode),					//keycode.export
		.leds_export({hundreds, signs, LEDR}),	//leds.export
			
		.i2c_sda_in(i2c_serial_sda_in),			//i2c.sda_in
		.i2c_scl_in(i2c_serial_scl_in),			//   .scl_in
		.i2c_sda_oe(i2c_serial_sda_oe),			//   .sda_oe
		.i2c_scl_oe(i2c_serial_scl_oe),			//   .scl_oe
		
		.pattern(pattern)
		
	);

endmodule
