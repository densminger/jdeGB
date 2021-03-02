//
//  Cartridge.swift
//  jdeGB
//
//  Created by David Ensminger on 2/15/21.
//

import Foundation

class Cartridge {
	var rom: Array<Int>!
	var mbc: MBC!
	
	let filename: String
	let ram_filename: String

	init?(from filename: String) {
		self.filename = filename
		self.ram_filename = "\(self.filename).ram"
		
		let url = URL(fileURLWithPath: self.filename)
		let data: Data
		do {
				data = try Data(contentsOf: url)
		} catch {
			print(error)
			return nil
		}
		
		// MBC type
		switch Int(data[0x0147]) {
		case 0x00:
			mbc = MBC0()
		case 0x01...0x03:
			mbc = MBC1()
		case 0x19...0x1E:
			mbc = MBC5()
		default:
			print("MBC unknown or not supported")
			return nil
		}

		// each bank is 16Kb
		rom = Array(data).map {Int($0)}
		
		// rom size
		switch Int(data[0x0148]) {
		case 0x00:
			mbc.banks = 2
		case 0x01:
			mbc.banks = 4
		case 0x02:
			mbc.banks = 8
		case 0x03:
			mbc.banks = 16
		case 0x04:
			mbc.banks = 32
		case 0x05:
			mbc.banks = 64
		case 0x06:
			mbc.banks = 128
		case 0x07:
			mbc.banks = 256
		case 0x08:
			mbc.banks = 512
		case 0x52:
			mbc.banks = 72
		case 0x53:
			mbc.banks = 80
		case 0x54:
			mbc.banks = 96
		default:
			print("unknown rom size!")
			return nil
		}
		
		// just do a quick size check
		if rom.count != mbc.banks*16*1024 {
			print("rom size doesn't match number of banks in header")
			return nil
		}
		
		// ram size
		switch (Int(data[0x0149])) {
		case 0x00:
			mbc.ram = nil
			mbc.ram_enable = false
		case 0x01:
			mbc.ram = Array(repeating: 0, count: 2*1024)
			mbc.ram_bank_size = 2*1024
			mbc.ram_enable = true
		case 0x02:
			mbc.ram = Array(repeating: 0, count: 8*1024)
			mbc.ram_bank_size = 8*1024
			mbc.ram_enable = true
		case 0x03:
			mbc.ram = Array(repeating: 0, count: 32*1024)
			mbc.ram_bank_size = 8*1024
			mbc.ram_enable = true
		case 0x04:
			mbc.ram = Array(repeating: 0, count: 128*1024)
			mbc.ram_bank_size = 8*1024
			mbc.ram_enable = true
		case 0x05:
			mbc.ram = Array(repeating: 0, count: 64*1024)
			mbc.ram_bank_size = 8*1024
			mbc.ram_enable = true
		default:
			print("unknown ram size!")
			return nil
		}
		
		mbc.ram_filename = self.ram_filename

		let ram_url = URL(fileURLWithPath: self.ram_filename)
		if let ram_data = try? Data(contentsOf: ram_url) {
			mbc.ram = Array(ram_data).map {Int($0)}
		}
		
	}

	func read(_ addr: Int) -> Int {
		let mapped_addr = mbc.read_addr(addr: addr)
		switch addr {
		case 0xA000...0xBFFF:
			if mbc.ram != nil {
				return mbc.ram![mapped_addr] & 0xFF
			} else {
				return 0x00
			}
		default:
			return rom[mapped_addr] & 0xFF
		}
	}

	func write(_ addr: Int, _ data: Int) {
		mbc.write(addr, data)
	}
}
