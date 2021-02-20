//
//  MBC1.swift
//  jdeGB
//
//  Created by David Ensminger on 2/16/21.
//

class MBC1: MBC {
	override func mapped_addr(addr: Int) -> Int {
		var mapped_addr = addr
		if bank_mode == 0 {
			// Mode 0
			switch addr {
			case 0x0000...0x3FFF:
				mapped_addr = addr
			case 0x4000...0x7FFF:
				if banks <= 32 {
					mapped_addr = addr
				} else {
					let bank = (secondary_bank << 5) | (rom_bank)
					mapped_addr = bank*16*1024 + addr
				}
			case 0xA000...0xBFFF:
				// cart ram address - this does NOT point to the cartridge ROM, but to the RAM instead (a separate array in our case, so the address might overlap with the ROM address)
				mapped_addr = addr - 0xA000
			default:
				break
			}
		} else {
			// Mode 1
			switch addr {
			case 0x0000...0x3FFF:
				if banks <= 32 {
					mapped_addr = addr
				} else {
					let rom_bank = (secondary_bank << 5)
					mapped_addr = rom_bank*16*1024 + addr
				}
			case 0x4000...0x7FFF:
				if banks <= 32 {
					mapped_addr = addr
				} else {
					let bank = (secondary_bank << 5) | (rom_bank)
					mapped_addr = bank*16*1024 + addr
				}
			case 0xA000...0xBFFF:
				// cart ram address - this does NOT point to the cartridge ROM, but to the RAM instead (a separate array in our case, so the address might overlap with the ROM address)
				mapped_addr = secondary_bank*8*1024 + addr - 0xA000
			default:
				break
			}
		}
		return mapped_addr
	}
}
