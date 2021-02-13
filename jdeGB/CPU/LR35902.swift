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

	// TEMPORARY MEMORY - eventually the bus will take care of this
	var cpuRam = Array(repeating: 0, count: 0xFFFF)

	private var lookup: [Instruction] = []
	private var cbLookup: [Instruction] = []
	func setupLookupTables() {
		lookup = [
			Instruction("NOP", NOP, "IMP", IMP, 1), Instruction("LD", LDBC, "IMM", IMM16, 3), Instruction("LD", LDiBC, "IMP", IMPA, 2), Instruction("INC", INCBC, "IMP", IMP, 2), Instruction("INC", INCB, "IMP", IMP, 1), Instruction("DEC", DECB, "IMP", IMP, 1), Instruction("LD", LDB, "IMM", IMM8, 2), Instruction("RLCA", RLCA, "IMP", IMP, 4)
		]
		
		cbLookup = [
		]
	}
	
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
		if stop || halt {
			return
		}
	}
	
	func irq() {
		halt = false
	}
	
	func nmi() {
		halt = false
	}
}
