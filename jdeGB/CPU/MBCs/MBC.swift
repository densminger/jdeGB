//
//  MBC.swift
//  jdeGB
//
//  Created by David Ensminger on 2/16/21.
//

protocol MBCProtocol {
	func read_addr(addr: Int) -> Int
	func write_addr(addr: Int) -> Int
}

class MBC: MBCProtocol {
	var rom_bank = 1
	var secondary_bank = 0
	var ram_enable = false
	var bank_mode = 0
	var banks = 0
	var ram: Array<Int>?
	var ram_bank_size = 0

	func read_addr(addr: Int) -> Int {
		return addr
	}
	
	func write_addr(addr: Int) -> Int {
		return addr
	}
	
	func write(_ addr: Int, _ data: Int) {
	}
}
