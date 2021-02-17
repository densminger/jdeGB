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
	var ram: Array<Int>?

	init?(from filename: String) {
		let url = URL(fileURLWithPath: filename)
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
		case 0x01:
			mbc = MBC1()
		case 0x02:
			mbc = MBC1()
		case 0x03:
			mbc = MBC1()
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
			ram = nil
		case 0x01:
			ram = Array(repeating: 0, count: 2*1024)
		case 0x02:
			ram = Array(repeating: 0, count: 8*1024)
		case 0x03:
			ram = Array(repeating: 0, count: 32*1024)
		case 0x04:
			ram = Array(repeating: 0, count: 128*1024)
		case 0x05:
			ram = Array(repeating: 0, count: 64*1024)
		default:
			print("unknown ram size!")
			return nil
		}
		
	}

	func read(_ addr: Int) -> Int {
		let mapped_addr = mbc.mapped_addr(addr: addr)
		if addr >= 0xA000 && addr <= 0xBFFF {
			if ram != nil {
				return ram![mapped_addr] & 0xFF
			} else {
				return 0x00
			}
		} else {
			return rom[mapped_addr] & 0xFF
		}
	}

	func write(_ addr: Int, _ data: Int) {
		if addr >= 0x0000 && addr <= 0x1FFF {
			mbc.ram_enable = (data == 0x0A)
		} else if addr >= 0x2000 && addr <= 0x3FFF {
			mbc.rom_bank = (data & 0x1F) & (~mbc.banks)
			if mbc.rom_bank == 0 {
				mbc.rom_bank = 1
			}
		} else if addr >= 0x4000 && addr <= 0x5FFF {
			mbc.secondary_bank = data & 0x03
		} else if addr >= 0x6000 && addr <= 0x7FFF {
			mbc.bank_mode = data & 0x01
		} else if addr >= 0xA000 && addr <= 0xBFFF && ram != nil {
			let mapped_addr = mbc.mapped_addr(addr: addr)
			ram![mapped_addr] = data & 0xFF
		}
	}
}
