//
//  MBC5.swift
//  jdeGB
//
//  Created by David Ensminger on 2/28/21.
//

class MBC5: MBC {
	override func read_addr(addr: Int) -> Int {
		var mapped_addr = addr
		switch addr {
		case 0x0000...0x3FFF:
			mapped_addr = addr
		case 0x4000...0x7FFF:
			mapped_addr = addr + 0x4000 * (rom_bank - 1)
		case 0xA000...0xBFFF where ram_enable:
			// cart ram address - this does NOT point to the cartridge ROM, but to the RAM instead (a separate array in our case, so the address might overlap with the ROM address)
			mapped_addr = addr - 0xA000
		default:
			break
		}
		return mapped_addr
	}
	
	override func write(_ addr: Int, _ data: Int) {
		switch addr {
		case 0x0000...0x1FFF:
			ram_enable = (data == 0x0A)
		case 0x2000...0x2FFF:
			rom_bank = (data & 0xFF)
		case 0x3000...0x3FFF:
			rom_bank += (data & 0x01) << 8
		case 0x4000...0x5FFF:
			secondary_bank = data & 0x0F
		case 0xA000...0xBFFF where ram != nil:
			ram![secondary_bank * ram_bank_size + (addr - 0xA000)] = data & 0xFF
			save_ram()
		default:
			break
		}
	}
}

