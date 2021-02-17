//
//  MBC.swift
//  jdeGB
//
//  Created by David Ensminger on 2/16/21.
//

class MBC {
	var rom_bank = 1
	var secondary_bank = 0
	var ram_enable = false
	var bank_mode = 0
	var banks = 0

	func mapped_addr(addr: Int) -> Int {
		return addr
	}
}
