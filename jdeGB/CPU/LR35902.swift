//
//  LR35902.swift
//  jdeGB
//
//  Created by David Ensminger on 2/12/21.
//

class LR35902 {
	var bus: Bus!

	// Registers
	var a = 0
	var f = 0
	var bc = 0
	var de = 0
	var hl = 0
	var sp = 0
	var pc = 0
	var af: Int {
		get {
			return (a << 8) | f
		}
		set(v) {
			precondition(v & 0xFFFF == v)
			a = v << 8
			f = v & 0xFF
		}
	}
	var b: Int {
		get {
			return bc >> 8
		}
		set(v) {
			precondition(v & 0xFF == v)
			bc = (v << 8) | (bc & 0x00FF)
		}
	}
	var c: Int {
		get {
			return bc & 0x00FF
		}
		set(v) {
			precondition(v & 0xFF == v)
			bc = (bc & 0xFF00) | v
		}
	}
	var d: Int {
		get {
			return de >> 8
		}
		set(v) {
			precondition(v & 0xFF == v)
			de = (v << 8) | (de & 0x00FF)
		}
	}
	var e: Int {
		get {
			return de & 0x00FF
		}
		set(v) {
			precondition(v & 0xFF == v)
			de = (de & 0xFF00) | v
		}
	}
	var h: Int {
		get {
			return hl >> 8
		}
		set(v) {
			precondition(v & 0xFF == v)
			hl = (v << 8) | (hl & 0x00FF)
		}
	}
	var l: Int {
		get {
			return hl & 0x00FF
		}
		set(v) {
			precondition(v & 0xFF == v)
			hl = (hl & 0xFF00) | v
		}
	}
	
	// Flags
	var flag_z: Bool {
		get {
			return (f & 0b1000_0000) > 0
		}
		set(v) {
			if v {
				f |= 0b1000_0000
			} else {
				f &= 0b0111_1111
			}
		}
	}
	var flag_n: Bool {
		get {
			return (f & 0b0100_0000) > 0
		}
		set(v) {
			if v {
				f |= 0b0100_0000
			} else {
				f &= 0b1011_1111
			}
		}
	}
	var flag_h: Bool {
		get {
			return (f & 0b0010_0000) > 0
		}
		set(v) {
			if v {
				f |= 0b0010_0000
			} else {
				f &= 0b1101_1111
			}
		}
	}
	var flag_c: Bool {
		get {
			return (f & 0b0001_0000) > 0
		}
		set(v) {
			if v {
				f |= 0b0001_0000
			} else {
				f &= 0b1110_1111
			}
		}
	}
	
	var stop = false
	var halt = false
	
	// Interrupt Master Enable flag
	var ime = true
	// Interrupt Enable / Interrupt Request flag
	// Bit 0: V-Blank  Interrupt Enable  (INT 40h)  (1=Enable)
	// Bit 1: LCD STAT Interrupt Enable  (INT 48h)  (1=Enable)
	// Bit 2: Timer    Interrupt Enable  (INT 50h)  (1=Enable)
	// Bit 3: Serial   Interrupt Enable  (INT 58h)  (1=Enable)
	// Bit 4: Joypad   Interrupt Enable  (INT 60h)  (1=Enable)
	//
	// If an interrupt is requested, the appropriate flag is set in interrupt_request.
	// This only causes an interrupt to occur if BOTH the Interrupt Master Enable flag
	// is true, AND the corresponding bit in interrupt_enable is set.
	var interrupt_enable = 0x1F	// enable all interrupts at start
	var interrupt_request = 0x00
	
	// This is the number of cycles to wait until the next operation can occur.
	// This is to simulate the amount of time it takes for operations to run on the CPU.
	var cycles = 0
	
	// 2 banks of 8 KB working ram
	var wram = Array(repeating: Array(repeating: 0, count: 0x1000), count: 2)
	
	// 127 bytes of HRAM
	var hram = Array(repeating: 0, count: 127)
	
	func connect(bus: Bus) {
		self.bus = bus
	}

	func read8(_ addr: Int) -> Int {
		return bus.read(addr)
	}
	
	func read16(_ addr: Int) -> Int {
		let lo = read8(addr)
		let hi = read8(addr + 1)
		
		return ((hi << 8) | lo) & 0xFFFF
	}
	
	func write8(_ addr: Int, _ data: Int) {
		bus.write(addr, data)
	}
	
	func write16(_ addr: Int, _ data: Int) {
		write8(addr, ((data & 0xFF00) >> 8))
		write8(addr + 1, (data & 0x00FF))
	}
	
	func reset() {
		// these values are set according to the Pan Docs section "Power Up Sequene"
		af = 0x01B0
		bc = 0x0013
		de = 0x00D8
		hl = 0x014D
		sp = 0xFFFE
		write8(0xFF05, 0x00)	// TIMA
		write8(0xFF06, 0x00)	// TMA
		write8(0xFF07, 0x00)	// TAC
		write8(0xFF10, 0x80)	// NR10
		write8(0xFF11, 0xBF)	// NR11
		write8(0xFF12, 0xF3)	// NR12
		write8(0xFF14, 0xBF)	// NR14
		write8(0xFF16, 0x3F)	// NR21
		write8(0xFF17, 0x00)	// NR22
		write8(0xFF19, 0xBF)	// NR24
		write8(0xFF1A, 0x7F)	// NR30
		write8(0xFF1B, 0xFF)	// NR31
		write8(0xFF1C, 0x9F)	// NR32
		write8(0xFF1E, 0xBF)	// NR34
		write8(0xFF20, 0xFF)	// NR41
		write8(0xFF21, 0x00)	// NR42
		write8(0xFF22, 0x00)	// NR43
		write8(0xFF23, 0xBF)	// NR44
		write8(0xFF24, 0x77)	// NR50
		write8(0xFF25, 0xF3)	// NR51
		write8(0xFF26, 0xF1)	// NR52
		write8(0xFF40, 0x91)	// LCDC
		write8(0xFF42, 0x00)	// SCY
		write8(0xFF43, 0x00)	// SCX
		write8(0xFF45, 0x00)	// LYC
		write8(0xFF47, 0xFC)	// BGP
		write8(0xFF48, 0xFF)	// OBP0
		write8(0xFF49, 0xFF)	// OBP1
		write8(0xFF4A, 0x00)	// WY
		write8(0xFF4B, 0x00)	// WX
		write8(0xFFFF, 0x00)	// IE
		
		pc = 0x00					// start at internal rom address 0x00
		write8(0xFF50, 0)		// enable boot rom (0 = enable, 1 = disable)
	}
	
	func clock() {
		if cycles > 0 {
			cycles -= 1
			return
		}

		// if the CPU is stopped, we sleep forever
		if stop {
			return
		}

		// run an interrupt, if indicated
		if ime && (interrupt_request & interrupt_enable) > 0 {
			irq()
		} else {
			// if we're currently halted, don't do anything
			if halt {
				return
			}
			// run the next instruction
			let opcode = read8(pc)
			pc += 1
			cycles = perform_operation(opcode: opcode)
		}
		
		cycles -= 1
	}
	
	func irq() {
		if !ime {
			return
		}

		// CPU will resume operation upon interrupt if a halt instruction was issued
		halt = false
		
		// push the PC to the stack
		sp -= 2
		write16(sp, pc)

		// jump to the interrupt handler
		if (interrupt_request & 0b00001) & interrupt_enable > 0 {
			// vblank
			pc = 0x0040
			interrupt_request &= 0b11110
			ime = false
		} else if (interrupt_request & 0b00010) & interrupt_enable > 0 {
			// LCD stat
			pc = 0x0048
			interrupt_request &= 0b11101
			ime = false
		} else if (interrupt_request & 0b00100) & interrupt_enable > 0 {
			// timer
			pc = 0x0050
			interrupt_request &= 0b11011
			ime = false
		} else if (interrupt_request & 0b01000) & interrupt_enable > 0 {
			// serial
			pc = 0x0058
			interrupt_request &= 0b10111
			ime = false
		} else if (interrupt_request & 0b10000) & interrupt_enable > 0 {
			// joypad
			pc = 0x0060
			interrupt_request &= 0b01111
			ime = false
		} else {
			// huh??  unexpected interrupt.
			// just take the pc off the stack and continue
			sp += 2
			return
		}
		
		// this interupt request takes 5 cycles to complete
		cycles = 5
	}
}
