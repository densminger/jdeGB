//
//  Cartridge.swift
//  jdeGB
//
//  Created by David Ensminger on 2/15/21.
//

class Cartridge {
	init?(from filename: String) {
	}
	
	func read(_ addr: Int) -> Int {
		return 0x76	// for now always return HALT instruction
	}

	func write(_ addr: Int, _ data: Int) {
	}
}
