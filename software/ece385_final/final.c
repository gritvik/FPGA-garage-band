//SGTL5000 register control with the Intel FPGA I2C peripheral
//Written by Zuofu Cheng for ECE 385
//Configured for Fs=44.1kHz, SGTL5000 as I2S master
//Line-in -> ADC -> I2S Out
//I2S In -> DAC -> Headphone Out


#include <stdio.h>
#include "system.h"
#include "altera_avalon_spi.h"
#include "altera_avalon_spi_regs.h"
#include "altera_avalon_pio_regs.h"
#include "altera_avalon_i2c.h"
#include "altera_avalon_i2c_regs.h"
#include "sys/alt_irq.h"
#include "sgtl5000/GenericTypeDefs.h"
#include "sgtl5000/sgtl5000.h"
#include "final.h"

volatile unsigned int 		*LED_PIO = 		(unsigned int*)0x200; //make a pointer to access the PIO block
volatile unsigned int 		*SW_PIO = 		(unsigned int*)0x1e0;
volatile unsigned int 		*KEY_PIO = 	    (unsigned int*)0x1f0;
//volatile unsigned int *ALT_AVALON_I2C_DEV_t =	(unsigned int*)0x00A;

int pause = 0;
void clr_patterns(){
	ctrl->PATTERNS[0] = 0;
	ctrl->PATTERNS[1] = 0;
	ctrl->PATTERNS[2] = 0;
	ctrl->PATTERNS[3] = 0;
}
void str_switches(){
	int pattern_select = (*SW_PIO & 0x0300)>>8;
	int pattern = *SW_PIO & 0x00FF;
	if(*KEY_PIO==1){
		clr_patterns();
		pause = 1;
	}
	if(*KEY_PIO==2 && pause==0){
		ctrl->PATTERNS[pattern_select] = pattern;//SW[7:0];
		pause = 1;
		printf("pattern_select: %x\n",pattern_select);
		printf("pattern: %x\n",pattern);
	}
	if(*KEY_PIO==3){
		pause = 0;
	}
	*LED_PIO = ctrl->PATTERNS[pattern_select];
}

int main(){
	setup();
	while(1==1){
		str_switches();
	}
	return 0;
}

void setup()
{
	clr_patterns();

	ALT_AVALON_I2C_DEV_t *i2c_dev; //pointer to instance structure
	//get a pointer to the Avalon i2c instance
	i2c_dev = alt_avalon_i2c_open("/dev/i2c_0"); //this has to reflect Platform Designer name
	if (NULL==i2c_dev)						     //check the BSP if unsure
	{
		printf("Error: Cannot find /dev/i2c_0\n");
	}
	alt_avalon_i2c_master_target_set(i2c_dev,0x0A); //CODEC at address 0b0001010
	BYTE int_divisor = 180633600/12500000;
	WORD frac_divisor = (WORD)(((180633600.0f/12500000.0f) - (float)int_divisor) * 2048.0f);
	SGTL5000_Reg_Wr(i2c_dev, SGTL5000_CHIP_PLL_CTRL, \
				int_divisor << SGTL5000_PLL_INT_DIV_SHIFT|
				frac_divisor << SGTL5000_PLL_FRAC_DIV_SHIFT);

	//configure power control, disable internal VDDD, VDDIO=3.3V, VDDA=VDDD=1.8V (ext)
	SGTL5000_Reg_Wr(i2c_dev, SGTL5000_CHIP_ANA_POWER, \
			SGTL5000_DAC_STEREO|
			SGTL5000_PLL_POWERUP|
			SGTL5000_VCOAMP_POWERUP|
			SGTL5000_VAG_POWERUP|
			SGTL5000_ADC_STEREO|
			SGTL5000_REFTOP_POWERUP|
			SGTL5000_HP_POWERUP|
			SGTL5000_DAC_POWERUP|
			SGTL5000_CAPLESS_HP_POWERUP|
			SGTL5000_ADC_POWERUP);
	//select internal ground bias to .9V (1.8V/2)
	SGTL5000_Reg_Wr(i2c_dev, SGTL5000_CHIP_REF_CTRL, 0x004E);

	//enable core modules
	SGTL5000_Reg_Wr(i2c_dev, SGTL5000_CHIP_DIG_POWER,\
			SGTL5000_ADC_EN|
			SGTL5000_DAC_EN|
			//SGTL5000_DAP_POWERUP| //disable digital audio processor in CODEC
			SGTL5000_I2S_OUT_POWERUP|
			SGTL5000_I2S_IN_POWERUP);

	//MCLK is 12.5 MHz, configure clocks to use PLL
	SGTL5000_Reg_Wr(i2c_dev, SGTL5000_CHIP_CLK_CTRL, \
			SGTL5000_SYS_FS_44_1k << SGTL5000_SYS_FS_SHIFT |
			SGTL5000_MCLK_FREQ_PLL << SGTL5000_MCLK_FREQ_SHIFT);

	//Set as I2S master
	SGTL5000_Reg_Wr(i2c_dev, SGTL5000_CHIP_I2S_CTRL, SGTL5000_I2S_MASTER);

	//ADC input from Line
	SGTL5000_Reg_Wr(i2c_dev, SGTL5000_CHIP_ANA_CTRL, \
			SGTL5000_ADC_SEL_LINE_IN << SGTL5000_ADC_SEL_SHIFT);

	//ADC -> I2S out, I2S in -> DAC
	SGTL5000_Reg_Wr(i2c_dev, SGTL5000_CHIP_SSS_CTRL, \
			SGTL5000_DAC_SEL_I2S_IN << SGTL5000_DAC_SEL_SHIFT |
			SGTL5000_I2S_OUT_SEL_ADC << SGTL5000_I2S_OUT_SEL_SHIFT);

	//ADC -> I2S out, I2S in -> DAC
	SGTL5000_Reg_Wr(i2c_dev, SGTL5000_CHIP_ADCDAC_CTRL, 0x0000);

}
