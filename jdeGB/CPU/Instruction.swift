//
//  Instruction.swift
//  jdeNES
//
//  Created by David Ensminger on 2/10/21.
//

struct Instruction {
	var name: String
	var operate: () -> Int
	var modeName: String
	var addrMode: () -> ()
	var cycles: Int
	
	init(_ name: String, _ operate: @escaping () -> Int, _ modeName: String, _ addrMode: @escaping () -> (), _ cycles: Int) {
		self.name = name
		self.operate = operate
		self.modeName = modeName
		self.addrMode = addrMode
		self.cycles = cycles
	}
}
