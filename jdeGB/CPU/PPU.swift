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
	let COLORS: [UInt32] = [0xFF0FBC9B, 0xFF0FAC8B, 0xFF306230, 0xFF0F380F]
	
	var vram = Array(repeating: 0, count: 0x2000)
	var oam = Array(repeating: 0, count: 160)
	var bus: Bus!
	
	var screen = Sprite(width: 160, height: 144)
	
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
	
	var bg_palette = 0x00
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
	
	func bg_palette_index(_ i: Int) -> Int {
		return (bg_palette & (0b11 << (i*2))) >> (i*2)
	}

	// this is for debugging
	func write_tilsets_to_screen() {
		for tile in 0..<128 {
			for y in 0..<8 {
				for x in 0..<8 {
					let byte1 = vram[0x0800*(tile_data_select==0 ? 2 : 0) + tile*16 + 2*y+1]
					let byte0 = vram[0x0800*(tile_data_select==0 ? 2 : 0) + tile*16 + 2*y]
					let shift = 7-x
					let palette_index = ((byte1 & (1 << shift)) >> (shift-1)) | ((byte0 & (1 << shift)) >> shift)
					let bg_color = bg_palette_index(palette_index)
					screen[(tile*8 + x) % 160,(tile/20)*8 + y] = COLORS[bg_color]
				}
			}
		}
		for tile in 0..<128 {
			for y in 0..<8 {
				for x in 0..<8 {
					let byte1 = vram[0x0800*1 + tile*16 + 2*y+1]
					let byte0 = vram[0x0800*1 + tile*16 + 2*y]
					let shift = 7-x
					let palette_index = ((byte1 & (1 << shift)) >> (shift-1)) | ((byte0 & (1 << shift)) >> shift)
					let bg_color = bg_palette_index(palette_index)
					screen[(tile*8 + x) % 160,(tile/20)*8 + y + 7*8] = COLORS[bg_color]
				}
			}
		}
	}
	
	func do_mode_0() {
	}
	
	func do_mode_1() {
//		for y in 0..<32 {
//			for x in 0..<32 {
//				print("\(String(format: "%02i", bus.read(0x9800 + (bg_tile_map_display_select * 0x0400) + y*32 + x))) ", terminator: "")
//			}
//			print("")
//		}
//		print("------")
	}
	
	func do_mode_2() {
	}
	
	func do_mode_3() {
		if bg_window_priority {
			let y = ly
			for x in 0..<160 {
				let nx = (x + scx) % 256
				let ny = (y + scy) % 256
				let tilei = (ny/8)*32 + nx/8
				let tile = bus.read(0x9800 + (bg_tile_map_display_select * 0x0400) + tilei)
				let addr: Int
				if tile > 127 {
					addr = 0x8800 + ((tile-128)*16) + (2*(ny%8))
				} else {
					addr = 0x8000 + (tile_data_select == 0 ? 0x1000 : 0) + (tile*16) + (2*(ny%8))
				}
				let byte1 = bus.read(addr+1)
				let byte0 = bus.read(addr)
				let shift = 7-((scx + x)%8)
				let palette_index = ((byte1 & (1 << shift)) >> (shift-1)) | ((byte0 & (1 << shift)) >> shift)
				let bg_color = bg_palette_index(palette_index)
				screen[x,y] = COLORS[bg_color]
//				print("x,y = (\(x),\(y)), scx,scy = (\(scx),\(scy)), tilei=\(tilei), tile=\(tile), addr=\(addr), byte0=\(byte0), byte1=\(byte1)")
			}
		}
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
