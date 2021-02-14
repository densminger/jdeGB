//
//  LR35902.swift
//  jdeGB
//
//  Created by David Ensminger on 2/12/21.
//

class LR35902 {
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
			f = v & 0x0F
		}
	}
	var b: Int {
		get {
			return bc >> 8
		}
		set(v) {
			precondition(v & 0xFF == v)
			bc = (v << 8) | (bc & 0x0F)
		}
	}
	var c: Int {
		get {
			return bc & 0x0F
		}
		set(v) {
			precondition(v & 0xFF == v)
			bc = (bc & 0xF0) | v
		}
	}
	var d: Int {
		get {
			return de >> 8
		}
		set(v) {
			precondition(v & 0xFF == v)
			de = (v << 8) | (de & 0x0F)
		}
	}
	var e: Int {
		get {
			return de & 0x0F
		}
		set(v) {
			precondition(v & 0xFF == v)
			de = (de & 0xF0) | v
		}
	}
	var h: Int {
		get {
			return hl >> 8
		}
		set(v) {
			precondition(v & 0xFF == v)
			hl = (v << 8) | (hl & 0x0F)
		}
	}
	var l: Int {
		get {
			return hl & 0x0F
		}
		set(v) {
			precondition(v & 0xFF == v)
			hl = (hl & 0xF0) | v
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

	// TEMPORARY MEMORY - eventually the bus will take care of this
	var cpuRam = Array(repeating: 0, count: 0xFFFF)

	func read8(_ addr: Int) -> Int {
		return cpuRam[addr] & 0xFF
	}
	
	func read16(_ addr: Int) -> Int {
		let lo = read8(addr)
		let hi = read8(addr + 1)
		
		return ((hi << 8) | lo) & 0xFFFF
	}
	
	func write8(_ addr: Int, _ data: Int) {
		cpuRam[addr] = data & 0xFF
	}
	
	func write16(_ addr: Int, _ data: Int) {
		cpuRam[addr] = ((data & 0xFF00) >> 8)
		cpuRam[addr + 1] = (data & 0x00FF)
	}
	
	func clock() {
		if cycles > 0 {
			cycles -= 1
			return
		}
		
		if stop {
			return
		}

		// run an interrupt, if indicated
		if ime && (interrupt_request & interrupt_enable) > 0 {
			irq()
		} else {
			// run the next instruction
			let opcode = read8(pc)
			pc += 1
			cycles = perform_operation(opcode: opcode)
		}
	}
	
	func irq() {
		// CPU will resume operation upon interrupt if a halt instruction was issued
		halt = false
		
		// push the PC to the stack
		sp -= 2
		write16(sp, pc)

		// jump to the interrupt handler
		if (interrupt_request & 0b00001) & interrupt_enable > 0 {
			// vblank
			pc = 0x0040
		} else if (interrupt_request & 0b00010) & interrupt_enable > 0 {
			// LCD stat
			pc = 0x0048
		} else if (interrupt_request & 0b00100) & interrupt_enable > 0 {
			// timer
			pc = 0x0050
		} else if (interrupt_request & 0b01000) & interrupt_enable > 0 {
			// serial
			pc = 0x0058
		} else if (interrupt_request & 0b10000) & interrupt_enable > 0 {
			// joypad
			pc = 0x0060
		}
		
		// this interupt request takes 5 cycles to complete
		cycles = 5
	}
}
