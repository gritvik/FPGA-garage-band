/*
 *  text_mode_vga.h
 *	Minimal driver for text mode VGA support, ECE 385 Summer 2021 Lab 6
 *  You may wish to extend this driver for your final project/extra credit project
 *
 *  Created on: Jul 17, 2021
 *      Author: zuofu
 */

#ifndef FINAL_H_
#define FINAL_H_

#include <system.h>
#include <alt_types.h>

struct STORAGE_STRUCT {
//	alt_u8 VRAM [ROWS*COLUMNS*2]; //Week 2 - extended VRAM
//	//modify this by adding const bytes to skip to palette, or manually compute palette
//	alt_u8 const deadspace0 [3392];
//	alt_u32 PALETTE [8];
//	alt_u8 const deadspace1 [8160];

	alt_u8 PATTERNS [4]; //4 bytes of storage for music patterns

};

//you may have to change this line depending on your platform designer
static volatile struct STORAGE_STRUCT* ctrl = 0x8000; //VGA_TEXT_MODE_CONTROLLER_0_BASE;



#endif
