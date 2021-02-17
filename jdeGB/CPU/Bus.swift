//
//  Gameboy.swift
//  jdeGB
//
//  Created by David Ensminger on 2/14/21.
//

class Bus {
	let cpu = LR35902()
	let ppu = PPU()

	var clock_count = 0
	
	var boot_rom_enabled = true
	let boot_rom: [Int] = [
		0x31, 0xFE, 0xFF, 0xAF, 0x21, 0xFF, 0x9F, 0x32, 0xCB, 0x7C, 0x20, 0xFB, 0x21, 0x26, 0xFF, 0x0E,
		0x11, 0x3E, 0x80, 0x32, 0xE2, 0x0C, 0x3E, 0xF3, 0xE2, 0x32, 0x3E, 0x77, 0x77, 0x3E, 0xFC, 0xE0,
		0x47, 0x11, 0x04, 0x01, 0x21, 0x10, 0x80, 0x1A, 0xCD, 0x95, 0x00, 0xCD, 0x96, 0x00, 0x13, 0x7B,
		0xFE, 0x34, 0x20, 0xF3, 0x11, 0xD8, 0x00, 0x06, 0x08, 0x1A, 0x13, 0x22, 0x23, 0x05, 0x20, 0xF9,
		0x3E, 0x19, 0xEA, 0x10, 0x99, 0x21, 0x2F, 0x99, 0x0E, 0x0C, 0x3D, 0x28, 0x08, 0x32, 0x0D, 0x20,
		0xF9, 0x2E, 0x0F, 0x18, 0xF3, 0x67, 0x3E, 0x64, 0x57, 0xE0, 0x42, 0x3E, 0x91, 0xE0, 0x40, 0x04,
		0x1E, 0x02, 0x0E, 0x0C, 0xF0, 0x44, 0xFE, 0x90, 0x20, 0xFA, 0x0D, 0x20, 0xF7, 0x1D, 0x20, 0xF2,
		0x0E, 0x13, 0x24, 0x7C, 0x1E, 0x83, 0xFE, 0x62, 0x28, 0x06, 0x1E, 0xC1, 0xFE, 0x64, 0x20, 0x06,
		0x7B, 0xE2, 0x0C, 0x3E, 0x87, 0xE2, 0xF0, 0x42, 0x90, 0xE0, 0x42, 0x15, 0x20, 0xD2, 0x05, 0x20,
		0x4F, 0x16, 0x20, 0x18, 0xCB, 0x4F, 0x06, 0x04, 0xC5, 0xCB, 0x11, 0x17, 0xC1, 0xCB, 0x11, 0x17,
		0x05, 0x20, 0xF5, 0x22, 0x23, 0x22, 0x23, 0xC9, 0xCE, 0xED, 0x66, 0x66, 0xCC, 0x0D, 0x00, 0x0B,
		0x03, 0x73, 0x00, 0x83, 0x00, 0x0C, 0x00, 0x0D, 0x00, 0x08, 0x11, 0x1F, 0x88, 0x89, 0x00, 0x0E,
		0xDC, 0xCC, 0x6E, 0xE6, 0xDD, 0xDD, 0xD9, 0x99, 0xBB, 0xBB, 0x67, 0x63, 0x6E, 0x0E, 0xEC, 0xCC,
		0xDD, 0xDC, 0x99, 0x9F, 0xBB, 0xB9, 0x33, 0x3E, 0x3C, 0x42, 0xB9, 0xA5, 0xB9, 0xA5, 0x42, 0x3C,
		0x21, 0x04, 0x01, 0x11, 0xA8, 0x00, 0x1A, 0x13, 0xBE, 0x20, 0xFE, 0x23, 0x7D, 0xFE, 0x34, 0x20,
		0xF5, 0x06, 0x19, 0x78, 0x86, 0x23, 0x05, 0x20, 0xFB, 0x86, 0x20, 0xFE, 0x3E, 0x01, 0xE0, 0x50
	]

	var dma_transfer = false
	var dma_page = 0x00
	var dma_byte = 0x00

	var cart: Cartridge!
	
	init() {
		cpu.connect(bus: self)
	}
		
	func insert_cartridge(_ cart: Cartridge) {
		self.cart = cart
	}

	func read(_ addr: Int) -> Int {
		var data = 0x00

		if addr >= 0x0000 && addr <= 0x00FF {
			if boot_rom_enabled {
				data = boot_rom[addr]
			} else {
				data = cart.read(addr)
			}
		} else if addr >= 0x0100 && addr <= 0x7FFF {			// From the cartridge - let the cartridge/MBC handle this
			data = cart.read(addr)
		} else if addr >= 0x8000 && addr <= 0x9FFF {	// VRAM, request the data from the PPU
			data = ppu.read(addr)
		} else if addr >= 0xA000 && addr <= 0xBFFF {	// 8KB External RAM (on cartridge, if any)
			data = cart.read(addr)
		} else if addr >= 0xC000 && addr <= 0xFDFF {
			// The memory range 0xE000 -> 0xFDFF is a mirror of 0xC000 -> 0xDDFF.
			// In our case, this doesn't matter, since the bank and the bank_addr
			// are only looking at the lower 13 bits anyway.
			let bank = (addr & 0x1000) >> 12
			let bank_addr = (addr & 0x0FFF)
			data = cpu.wram[bank][bank_addr] & 0xFF
		} else if addr >= 0xFE00 && addr <= 0xFE9F {
			data = ppu.oam[addr & 0x00FF] & 0xFF
		} else if addr >= 0xFEA0 && addr <= 0xFEFF {	// Nintendo says this area is unusable, so return 0xFF
			data = 0xFF
		} else if addr >= 0xFF00 && addr <= 0xFF7F {	// I/O Registers
			switch addr {
			case 0xFF00:	// Joypad
				break
			case 0xFF01:	// Serial transfer Data
				break
			case 0xFF02:	// Serial transfer Control
				break
			case 0xFF04:	// Divider register
				break
			case 0xFF05:	// TIMA
				break
			case 0xFF06:	// TMA
				break
			case 0xFF07:	// TAC
				break
			case 0xFF0F:	// Interrupt Request
				data = cpu.interrupt_request
			case 0xFF10:	// Channel 1 Sweep Register
				break
			case 0xFF11:	// Channel 1 Sound Length/Wave pattern duty
				break
			case 0xFF12:	// Channel 1 Volume Envelope
				break
			case 0xFF13:	// Channel 1 Frequency lo
				break
			case 0xFF14:	// Channel 1 Frequency hi
				break
			case 0xFF16:	// Channel 2 Sound Length/Wave pattern duty
				break
			case 0xFF17:	// Channel 2 Volume Envelope
				break
			case 0xFF18:	// Channel 2 Frequency lo
				break
			case 0xFF19:	// Channel 2 Frequency hi
				break
			case 0xFF1A:	// Channel 3 Sound on/off
				break
			case 0xFF1B:	// Channel 3 Sound Length
				break
			case 0xFF1C:	// Channel 3 Select Output Level
				break
			case 0xFF1D:	// Channel 3 Frequency lo
				break
			case 0xFF1E:	// Channel 3 Frequency hi
				break
			case 0xFF20:	// Channel 4 Sound Length
				break
			case 0xFF21:	// Channel 4 Volume Envelope
				break
			case 0xFF22:	// Channel 4 Polynomial Counter
				break
			case 0xFF23:	// Channel 4 Counter/Consecutive; Initial
				break
			case 0xFF24:	// Channel control / ON-OFF / Volume
				break
			case 0xFF25:	// Selection of Sound output terminal
				break
			case 0xFF26:	// Sound on/off
				break
			case let a where a >= 0xFF30 && a <= 0xFF3F:	// Wave Pattern RAM
				break
			case 0xFF40:
				data = ppu.lcdc
			case 0xFF41:	// LCDC Status
				break
			case 0xFF42:	// SCY
				break
			case 0xFF43:	// SCX
				break
			case 0xFF44:	// LY
				data = ppu.ly
			case 0xFF45:	// LYC
				break
			case 0xFF46:	// DMA Transfer and Start Address
				data = (dma_page << 8) | dma_byte
			case 0xFF47:	// BG Palette Data
				break
			case 0xFF48:	// Object Palette 0 Data
				break
			case 0xFF49:	// Object Palette 1 Data
				break
			case 0xFF4A:	// WY
				break
			case 0xFF4B:	// WX - 7
				break
			case 0xFF50:	// enable boot rom
				data = boot_rom_enabled ? 0 : 1
			default:
				break
			}
		} else if addr >= 0xFF80 && addr <= 0xFFFE {	// HRAM
			data = cpu.hram[addr & 0x007F] & 0xFF
		} else if addr == 0xFFFF {
			data = cpu.interrupt_enable
		}
		
		return data
	}
	
	func write(_ addr: Int, _ data: Int) {
		if addr >= 0x0000 && addr <= 0x00FF {
			if boot_rom_enabled {
				// do nothing - writes are ignored
			} else {
				cart.write(addr, data)
			}
		} else if addr >= 0x0100 && addr <= 0x7FFF {
			cart.write(addr, data)
		} else if addr >= 0x8000 && addr <= 0x9FFF {	// VRAM, request the data from the PPU
			ppu.write(addr, data)
		} else if addr >= 0xA000 && addr <= 0xBFFF {	// 8KB External RAM (on cartridge, if any)
			cart.write(addr, data)
		} else if addr >= 0xC000 && addr <= 0xFDFF {
			// The memory range 0xE000 -> 0xFDFF is a mirror of 0xC000 -> 0xDDFF.
			// In our case, this doesn't matter, since the bank and the bank_addr
			// are only looking at the lower 13 bits anyway.
			let bank = (addr & 0x1000) >> 12
			let bank_addr = (addr & 0x0FFF)
			cpu.wram[bank][bank_addr] = data & 0xFF
		} else if addr >= 0xFE00 && addr <= 0xFE9F {
			ppu.oam[addr & 0x00FF] = data & 0xFF
		} else if addr >= 0xFF00 && addr <= 0xFF7F {	// I/O Registers
			switch addr {
			case 0xFF00:	// Joypad
				break
			case 0xFF01:	// Serial transfer Data
				break
			case 0xFF02:	// Serial transfer Control
				break
			case 0xFF04:	// Divider register
				break
			case 0xFF05:	// TIMA
				break
			case 0xFF06:	// TMA
				break
			case 0xFF07:	// TAC
				break
			case 0xFF0F:	// Interrupt Request
				cpu.interrupt_request = data & 0xFF
			case 0xFF10:	// Channel 1 Sweep Register
				break
			case 0xFF11:	// Channel 1 Sound Length/Wave pattern duty
				break
			case 0xFF12:	// Channel 1 Volume Envelope
				break
			case 0xFF13:	// Channel 1 Frequency lo
				break
			case 0xFF14:	// Channel 1 Frequency hi
				break
			case 0xFF16:	// Channel 2 Sound Length/Wave pattern duty
				break
			case 0xFF17:	// Channel 2 Volume Envelope
				break
			case 0xFF18:	// Channel 2 Frequency lo
				break
			case 0xFF19:	// Channel 2 Frequency hi
				break
			case 0xFF1A:	// Channel 3 Sound on/off
				break
			case 0xFF1B:	// Channel 3 Sound Length
				break
			case 0xFF1C:	// Channel 3 Select Output Level
				break
			case 0xFF1D:	// Channel 3 Frequency lo
				break
			case 0xFF1E:	// Channel 3 Frequency hi
				break
			case 0xFF20:	// Channel 4 Sound Length
				break
			case 0xFF21:	// Channel 4 Volume Envelope
				break
			case 0xFF22:	// Channel 4 Polynomial Counter
				break
			case 0xFF23:	// Channel 4 Counter/Consecutive; Initial
				break
			case 0xFF24:	// Channel control / ON-OFF / Volume
				break
			case 0xFF25:	// Selection of Sound output terminal
				break
			case 0xFF26:	// Sound on/off
				break
			case let a where a >= 0xFF30 && a <= 0xFF3F:	// Wave Pattern RAM
				break
			case 0xFF40:
				ppu.lcdc = data
			case 0xFF41:	// LCDC Status
				break
			case 0xFF42:	// SCY
				break
			case 0xFF43:	// SCX
				break
			case 0xFF44:	// LY
				ppu.ly = data
			case 0xFF45:	// LYC
				break
			case 0xFF46:	// DMA Transfer and Start Address
				dma_page = data
				dma_byte = 0x00
				dma_transfer = true
			case 0xFF47:	// BG Palette Data
				break
			case 0xFF48:	// Object Palette 0 Data
				break
			case 0xFF49:	// Object Palette 1 Data
				break
			case 0xFF4A:	// WY
				break
			case 0xFF4B:	// WX - 7
				break
			case 0xFF50:
				boot_rom_enabled = (data == 0)
			default:
				break
			}
		} else if addr >= 0xFF80 && addr <= 0xFFFE {	// HRAM
			cpu.hram[addr & 0x007F] = data & 0xFF
		} else if addr == 0xFFFF {
			cpu.interrupt_enable = data & 0xFF
		}
	}
	
	func clock() {
		if dma_transfer {
			let src_addr = (dma_page << 8) | dma_byte
			let dest_addr = 0xFE00 | dma_byte
			write(dest_addr, read(src_addr))
			dma_byte += 1
			if dma_byte == 160 {
				// we're done
				dma_transfer = false
				dma_byte = 0x00
			}
		} else {
			cpu.clock()
		}
		
		clock_count += 1
	}
	
	func reset() {
		cpu.reset()
		clock_count = 0
	}
}
