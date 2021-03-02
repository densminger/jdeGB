//
//  MBC.swift
//  jdeGB
//
//  Created by David Ensminger on 2/16/21.
//

import Foundation

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
	var ram_filename: String?

	func read_addr(addr: Int) -> Int {
		return addr
	}
	
	func write_addr(addr: Int) -> Int {
		return addr
	}
	
	func write(_ addr: Int, _ data: Int) {
	}
	
	func save_ram() {
//		let a = Data(buffer: ram.unsa)
		if let ram_filename = self.ram_filename, let ram = self.ram {
			let d = ram.map {UInt8($0)}
			d.withUnsafeBytes({ (p) -> Void in
				let a = Data(p)
				try? a.write(to: URL(fileURLWithPath: ram_filename))
			})
		}
	}
}
