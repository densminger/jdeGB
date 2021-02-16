//
//  PPU.swift
//  jdeGB
//
//  Created by David Ensminger on 2/15/21.
//

class PPU {
	var vram = Array(repeating: 0, count: 0x2000)
	var oam = Array(repeating: 0, count: 160)
	
	// LCD Control Register
	var lcdc = 0

	func read(_ addr: Int) -> Int {
		return 0
	}
	
	func write(_ addr: Int, _ data: Int) {
	}
}
