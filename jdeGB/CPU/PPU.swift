//
//  PPU.swift
//  jdeGB
//
//  Created by David Ensminger on 2/15/21.
//

class PPU {
	// the colors for the background palette indices
	//  Each 32-bit int is in the order: AABBGGRR (not RRGGBB like you might suspect)
	// Alpha is always 100% so it's set to FF
	let COLORS = [0xFF0FBC9B, 0xFF0FAC8B, 0xFF306230, 0xFF0F380F]
	
	var vram = Array(repeating: 0, count: 0x2000)
	var oam = Array(repeating: 0, count: 160)
	var bus: Bus!
	
	// LCD Control Register
	var lcdc = 0
	var lcd_display_enable: Bool {
		get {
			return lcdc & 0b1000_0000 > 0
		}
		set(v) {
			if (v) {
				lcdc |= 0b1000_0000
			} else {
				lcdc &= 0x0111_1111
			}
		}
	}
	var window_tile_map_display_select: Int {
		get {
			return (lcdc & 0b0100_0000 > 0) ? 1 : 0
		}
		set (v) {
			precondition(v == 0 || v == 1)
			if (v == 1) {
				lcdc |= 0b0100_0000
			} else {
				lcdc &= 0b1011_1111
			}
		}
	}
	var window_display_enable: Bool {
		get {
			return lcdc & 0b0010_0000 > 0
		}
		set(v) {
			if (v) {
				lcdc |= 0b0010_0000
			} else {
				lcdc &= 0b1101_1111
			}
		}
	}
	var tile_data_select: Int {
		get {
			return (lcdc & 0b0001_0000 > 0) ? 1 : 0
		}
		set (v) {
			precondition(v == 0 || v == 1)
			if (v == 1) {
				lcdc |= 0b0001_0000
			} else {
				lcdc &= 0b1110_1111
			}
		}
	}
	var bg_tile_map_display_select: Int {
		get {
			return (lcdc & 0b0000_1000 > 0) ? 1 : 0
		}
		set (v) {
			precondition(v == 0 || v == 1)
			if (v == 1) {
				lcdc |= 0b0000_1000
			} else {
				lcdc &= 0b1111_0111
			}
		}
	}
	var sprite_small: Bool {
		get {
			return lcdc & 0b0000_0100 > 0
		}
		set(v) {
			if (v) {
				lcdc |= 0b0000_0100
			} else {
				lcdc &= 0b1111_1011
			}
		}
	}
	var sprite_display_enable: Bool {
		get {
			return lcdc & 0b0000_0010 > 0
		}
		set(v) {
			if (v) {
				lcdc |= 0b0000_0010
			} else {
				lcdc &= 0b1111_1101
			}
		}
	}
	var bg_window_priority: Bool {
		get {
			return lcdc & 0b0000_0001 > 0
		}
		set(v) {
			if (v) {
				lcdc |= 0b0000_0001
			} else {
				lcdc &= 0b1111_1110
			}
		}
	}
	
	// LCDC Status Register
	var lcdc_status = 0
	var lyc_ly_coincidence_interrupt: Bool {
		get {
			return lcdc_status & 0b0100_0000 > 0
		}
		set(v) {
			if (v) {
				lcdc_status |= 0b0100_0000
			} else {
				lcdc_status &= 0b1011_1111
			}
		}
	}
	var mode2_oam_interrupt: Bool {
		get {
			return lcdc_status & 0b0010_0000 > 0
		}
		set(v) {
			if (v) {
				lcdc_status |= 0b0010_0000
			} else {
				lcdc_status &= 0b1101_1111
			}
		}
	}
	var mode1_vblank_interrupt: Bool {
		get {
			return lcdc_status & 0b0001_0000 > 0
		}
		set(v) {
			if (v) {
				lcdc_status |= 0b0001_0000
			} else {
				lcdc_status &= 0b1110_1111
			}
		}
	}
	var mode0_hblank_interrupt: Bool {
		get {
			return lcdc_status & 0b0000_1000 > 0
		}
		set(v) {
			if (v) {
				lcdc_status |= 0b0000_1000
			} else {
				lcdc_status &= 0b1111_0111
			}
		}
	}
	var coincidence_flag: Bool {
		get {
			return lcdc_status & 0b0000_0100 > 0
		}
		set(v) {
			if (v) {
				lcdc_status |= 0b0000_0100
			} else {
				lcdc_status &= 0b1111_1011
			}
		}
	}
	var mode: Int {
		get {
			return lcdc_status & 0b0000_0011
		}
		set(v) {
			lcdc_status = (lcdc_status & 0b1111_1100) | v
		}
	}

	var ly = 0 {
		didSet {
			if lyc_ly_coincidence_interrupt && ly == lyc {
				// request lcdstat interrupt
				bus.write(0xFF0F, bus.read(0xFF0F) | 0b0000_0010)
			}
		}
	}
	var lyc = 0
	var scx = 0
	var scy = 0
	var wx = 0
	var wy = 0
	
	var bg_palette = 0b11100100
	var sprite_palette_0 = 0b11100100
	var sprite_palette_1 = 0b11100100
	
	var clock_count = 0
	var dot_count = 0

	func read(_ addr: Int) -> Int {
		return vram[addr & 0x7FFF] & 0xFF
	}
	
	func write(_ addr: Int, _ data: Int) {
		vram[addr & 0x7FFF] = data & 0xFF
	}
	
	func connect(bus: Bus) {
		self.bus = bus
	}
	
	func do_mode_0() {
	}
	
	func do_mode_1() {
	}
	
	func do_mode_2() {
	}
	
	func do_mode_3() {
	}
	
	func clock() {
		// this clock function will ensure that the timing of the ppu modes are as follows:
		// for lines 0 -> 143:
		// Mode 2 will run for 20 clock ticks (or 80 "dots")
		// Mode 3 will run for 42 clock ticks (or 168 "dots")
		// Mode 0 will run for 52 clock ticks (or 208 "dots")
		// for lines 144 -> 153:
		// Mode 1 will run for 114 clock ticks (or 456 "dots")
		//
		// All the "work" for each mode will happen during the FIRST clock tick of that mode.
		if ly <= 143 {
			switch dot_count {
			case 0:
				mode = 2
				do_mode_0()
			case 20:
				mode = 3
				do_mode_3()
			case 62:
				mode = 0
				do_mode_0()
			case 114:
				ly += 1
				dot_count = 0
				if ly == 144 {
					mode = 1
					// request v-blank interrupt
					bus.write(0xFF0F, bus.read(0xFF0F) | 0b0000_0001)
					do_mode_1()
				}
			default:
				break
			}
		} else {
			if dot_count == 114 {
				ly += 1
				dot_count = 0
				if ly == 154 {
					ly = 0
					mode = 2
				}
			}
		}
		
		dot_count += 1
		clock_count += 1
	}
}
