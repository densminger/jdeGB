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
	var tile_map = Sprite(width: 256, height: 256)
	var tile_map_enable = false
	
	var scanline_sprite_ids = Array<Int>()
	
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
	var sprite_large: Bool {
		get {
			return lcdc & 0b0000_0100 != 0
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
			coincidence_flag = (ly == lyc)
			if ly == lyc && lyc_ly_coincidence_interrupt {
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
	
	// This is just for debugging
	var display_rendering_enabled = true

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

	func spr_palette_index(_ i: Int, palette: Int) -> Int {
		if palette == 0 {
			return (sprite_palette_0 & (0b11 << (i*2))) >> (i*2)
		} else {
			return (sprite_palette_1 & (0b11 << (i*2))) >> (i*2)
		}
	}

	// this is for debugging
	func write_tilset(_ tileset: Int, to buffer: Sprite) {
		let tiles_across = buffer.width/8
		for tile in 0..<128 {
			for y in 0..<8 {
				for x in 0..<8 {
					let byte1 = vram[0x0800*tileset + tile*16 + 2*y+1]
					let byte0 = vram[0x0800*tileset + tile*16 + 2*y]
					let shift = 7-x
					let palette_index = ((byte1 & (1 << shift)) >> (shift-1)) | ((byte0 & (1 << shift)) >> shift)
					let bg_color = bg_palette_index(palette_index)
					buffer[(tile*8 + x) % buffer.width,(tile/tiles_across)*8 + y] = COLORS[bg_color]
				}
			}
		}
	}
	
	func get_oam_y(index: Int) -> Int {
		return oam[index * 4 + 0]
	}
	
	func get_oam_x(index: Int) -> Int {
		return oam[index * 4 + 1]
	}
	
	func get_oam_tile(index: Int) -> Int {
		return oam[index * 4 + 2]
	}
	
	func get_oam_attr(index: Int) -> Int {
		return oam[index * 4 + 3]
	}
	
	func do_mode_0() {
		mode = 0
		if mode0_hblank_interrupt {
			bus.write(0xFF0F, bus.read(0xFF0F) | 0b0000_0010)
		}
	}
	
	func do_mode_1() {
		mode = 1
		if mode1_vblank_interrupt {
			bus.write(0xFF0F, bus.read(0xFF0F) | 0b0000_0010)
		}
//		for y in 0..<32 {
//			for x in 0..<32 {
//				print("\(String(format: "%02i", bus.read(0x9800 + (bg_tile_map_display_select * 0x0400) + y*32 + x))) ", terminator: "")
//			}
//			print("")
//		}
//		print("------")
	}
	
	func do_mode_2() {
		mode = 2
		if mode2_oam_interrupt {
			bus.write(0xFF0F, bus.read(0xFF0F) | 0b0000_0010)
		}
		// get a list of the (up to) 10 sprites that will be on this line
		scanline_sprite_ids.removeAll()
		for i in 0..<40 {
			let y = get_oam_y(index: i)
			
			let top = y - 16
			let bottom = top + (sprite_large ? 16 : 8)
			if ly >= top && ly < bottom {
				scanline_sprite_ids.append(i)
			}
			
			// maximum of 10
			if scanline_sprite_ids.count == 10 {
				break
			}
		}
	}
	
	func do_mode_3() {
		mode = 3
		if !display_rendering_enabled {
			return
		}
		let y = ly
		var bg_color = 0
		var window_color = 0
		var spr_color = 0
		for x in 0..<160 {
			if bg_window_priority {
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
				bg_color = bg_palette_index(palette_index)
				screen[x,y] = COLORS[bg_color]
				let c = get_tint(COLORS[bg_color])
				tile_map[nx, ny] = c
			}
			if sprite_display_enable {
				for i in scanline_sprite_ids {
					let spr_x = get_oam_x(index: i)
					let spr_y = get_oam_y(index: i)
					let left = spr_x - 8
					let right = left + 8
					let top = spr_y - 16
					if x >= left && x < right {
						var tile = get_oam_tile(index: i)
						if sprite_large {
							tile &= 0xFE
							if y-top >= 8 { tile += 1 }
						}
						let attr = get_oam_attr(index: i)
						var sprite_row = y - top
						if attr & 0b0100_0000 > 0 {	// vflip
							sprite_row = 7 - sprite_row
							if sprite_large {
								if y-top < 8 {
									tile += 1
								} else {
									sprite_row += 1
								}
							}
						}
						let addr = 0x8000 + (tile*16) + 2*(sprite_row % 8)
						let byte1 = bus.read(addr+1)
						let byte0 = bus.read(addr)
						var shift = ((x-left)%8)
						if attr & 0b0010_0000 == 0 {	// hflip
							shift = 7-shift
						}
						let palette_index = ((byte1 & (1 << shift)) >> (shift-1)) | ((byte0 & (1 << shift)) >> shift)
						spr_color = spr_palette_index(palette_index, palette: (attr & 0b0001_0000) >> 4)
						if palette_index != 0 && (attr & 0b1000_0000 == 0 || (attr & 0b1000_0000 > 0 && bg_color == 0)) {
							screen[x,y] = COLORS[spr_color]
							let c = get_tint(COLORS[spr_color])
							tile_map[(x + scx) % 256, (y + scy) % 256] = c
							break
						}
					}
				}
			}
			if window_display_enable && ly >= wy {
				if x >= wx - 7 {
					let nx = x - (wx - 7)
					let ny = y - wy
					let tilei = (ny/8)*32 + nx/8
					let tile = bus.read(0x9800 + (window_tile_map_display_select * 0x0400) + tilei)
					let addr: Int
					if tile > 127 {
						addr = 0x8800 + ((tile-128)*16) + (2*(ny%8))
					} else {
						addr = 0x8000 + (tile_data_select == 0 ? 0x1000 : 0) + (tile*16) + (2*(ny%8))
					}
					let byte1 = bus.read(addr+1)
					let byte0 = bus.read(addr)
					let shift = 7-(nx%8)
					let palette_index = ((byte1 & (1 << shift)) >> (shift-1)) | ((byte0 & (1 << shift)) >> shift)
					window_color = bg_palette_index(palette_index)
					screen[x,y] = COLORS[window_color]
					let c = get_tint(COLORS[window_color])
					tile_map[(x + scx) % 256, (y + scy) % 256] = c
				}
			}
		}
	}
	
	func get_tint(_ c: UInt32) -> UInt32 {
		let r = c & 0x000000FF
		let g = (c & 0x0000FF00) >> 8
		let b = (c & 0x00FF0000) >> 16
		let rt = r + ((255 - r)/4)
		let gt = g + ((255 - g)/4)
		let bt = b + ((255 - b)/4)
		return 0xFF000000 | (bt << 16) | (gt << 8) | rt
	}
	
	func draw_tilemap() {
		for y in 0..<256 {
			for x in 0..<256 {
				let tilei = (y/8)*32 + x/8
				let tile = bus.read(0x9800 + (bg_tile_map_display_select * 0x0400) + tilei)
				let addr: Int
				if tile > 127 {
					addr = 0x8800 + ((tile-128)*16) + (2*(y%8))
				} else {
					addr = 0x8000 + (tile_data_select == 0 ? 0x1000 : 0) + (tile*16) + (2*(y%8))
				}
				let byte1 = bus.read(addr+1)
				let byte0 = bus.read(addr)
				let shift = 7-(x%8)
				let palette_index = ((byte1 & (1 << shift)) >> (shift-1)) | ((byte0 & (1 << shift)) >> shift)
				let bg_color = bg_palette_index(palette_index)
				tile_map[x,y] = COLORS[bg_color]
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
				do_mode_2()
			case 20:
				mode = 3
				do_mode_3()
			case 62:
				mode = 0
				do_mode_0()
			case 114:
				ly += 1
				dot_count = -1
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
				dot_count = -1
				if ly == 156 {	// setting this to ly == 156 (instead of 153) prevents the top couple of lines from scrolling weird
					ly = 0
				}
			}
		}

		// for debugging
		if tile_map_enable && ly == 0 && dot_count == 2 {
			draw_tilemap()
		}

		dot_count += 1
		clock_count += 1
	}
}
