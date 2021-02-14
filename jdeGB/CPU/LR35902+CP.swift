//
//  LR35902+CP.swift
//  jdeGB
//
//  Created by David Ensminger on 2/13/21.
//

extension LR35902 {
	func rlc(_ x: Int) -> Int {
		flag_c = (x & 0x80) > 0
		let ret = ((x << 1) | (flag_c ? 0x01 : 0x00)) & 0xFF
		flag_z = (ret == 0)
		flag_n = false
		flag_h = false
		return ret
	}
	
	func rrc(_ x: Int) -> Int {
		flag_c = (x & 0x01) > 0
		let ret = ((x >> 1) | (flag_c ? 0x80 : 0x00)) & 0xFF
		flag_z = (ret == 0)
		flag_n = false
		flag_h = false
		return ret
	}
	
	func rl(_ x: Int) -> Int {
		let new_flag_c = (x & 0x80) > 0
		let ret = ((x << 1) | (flag_c ? 0x01 : 0x00)) & 0xFF
		flag_c = new_flag_c
		flag_z = (ret == 0)
		flag_n = false
		flag_h = false
		return ret
	}
	
	func rr(_ x: Int) -> Int {
		let new_flag_c = (x & 0x01) > 0
		let ret = ((x >> 1) | (flag_c ? 0x80 : 0x00)) & 0xFF
		flag_c = new_flag_c
		flag_z = (ret == 0)
		flag_n = false
		flag_h = false
		return ret
	}
	
	func sla(_ x: Int) -> Int {
		flag_c = (x & 0x80) > 0
		let ret = (x << 1) & 0xFF
		flag_z = (x == 0)
		flag_n = false
		flag_h = false
		return ret
	}
	
	func swap(_ x: Int) -> Int {
		let ret = ((x & 0xF0) >> 4 | (x & 0x0F) << 4)  
		flag_z = (ret == 0)
		flag_n = false
		flag_h = false
		flag_c = false
		return ret
	}

	func sra(_ x: Int) -> Int {
		// The chart at https://www.pastraiser.com/cpu/gameboy/gameboy_opcodes.html says this operation clears the carry flag,
		// but both http://www.devrs.com/gb/files/GBCPU_Instr.html#SRA and http://gameboy.mongenel.com/dmg/opcodes.html say
		// the carry bit should be the last bit of the operand.  The latter makes the most sense to me, so I'm going with
		// that until I find out it's wrong
		flag_c = (x & 0x01) > 0
		let ret = ((x >> 1) | ((x & 0x40) << 1)) & 0xFF
		flag_z = (x == 0)
		flag_n = false
		flag_h = false
		return ret
	}

	func performCB(_ cbOp: Int) -> Int {
		var cycles = 0
		switch cbOp {
		case 0x00:	// RLC B
			b = rlc(b)
			cycles = 2
		case 0x01:	// RLC C
			c = rlc(c)
			cycles = 2
		case 0x02:	// RLC D
			d = rlc(d)
			cycles = 2
		case 0x03:	// RLC E
			e = rlc(e)
			cycles = 2
		case 0x04:	// RLC H
			h = rlc(h)
			cycles = 2
		case 0x05:	// RLC L
			l = rlc(l)
			cycles = 2
		case 0x06:	// RLC (HL)
			write8(hl, rlc(read8(hl)))
			cycles = 4
		case 0x07:	// RLC A
			a = rlc(a)
			cycles = 2
		case 0x08:	// RRC B
			b = rrc(b)
			cycles = 2
		case 0x09:	// RRC C
			c = rrc(c)
			cycles = 2
		case 0x0A:	// RRC D
			d = rrc(d)
			cycles = 2
		case 0x0B:	// RRC E
			e = rrc(e)
			cycles = 2
		case 0x0C:	// RRC H
			h = rrc(h)
			cycles = 2
		case 0x0D:	// RRC L
			l = rrc(l)
			cycles = 2
		case 0x0E:	// RRC (HL)
			write8(hl, rrc(read8(hl)))
			cycles = 4
		case 0x0F:	// RRC A
			a = rrc(a)
			cycles = 2
		case 0x10: // RL B
			b = rl(b)
			cycles = 2
		case 0x11: // RL C
			c = rl(c)
			cycles = 2
		case 0x12: // RL D
			d = rl(d)
			cycles = 2
		case 0x13: // RL E
			e = rl(e)
			cycles = 2
		case 0x14: // RL H
			h = rl(h)
			cycles = 2
		case 0x15: // RL L
			l = rl(l)
			cycles = 2
		case 0x16: // RL (HL)
			write8(hl, rl(read8(hl)))
			cycles = 4
		case 0x17: // RL A
			a = rr(a)
			cycles = 2
		case 0x18: // RR B
			b = rr(b)
			cycles = 2
		case 0x19: // RR C
			c = rr(c)
			cycles = 2
		case 0x1A: // RR D
			d = rr(d)
			cycles = 2
		case 0x1B: // RR E
			e = rr(e)
			cycles = 2
		case 0x1C: // RR H
			h = rr(h)
			cycles = 2
		case 0x1D: // RR L
			l = rr(l)
			cycles = 2
		case 0x1E: // RR (HL)
			write8(hl, rr(read8(hl)))
			cycles = 4
		case 0x1F: // RR A
			a = rr(a)
			cycles = 2
		case 0x20:	// SLA B
			b = sla(b)
			cycles = 2
		case 0x21:	// SLA C
			c = sla(c)
			cycles = 2
		case 0x22:	// SLA D
			d = sla(d)
			cycles = 2
		case 0x23:	// SLA E
			e = sla(e)
			cycles = 2
		case 0x24:	// SLA H
			h = sla(h)
			cycles = 2
		case 0x25:	// SLA L
			l = sla(l)
			cycles = 2
		case 0x26:	// SLA (HL)
			write8(hl, sla(read8(hl)))
			cycles = 4
		case 0x27:	// SLA A
			a = sla(a)
			cycles = 2
		case 0x28:	// SRA B
			b = sra(b)
			cycles = 2
		case 0x29:	// SRA C
			c = sra(c)
			cycles = 2
		case 0x2A:	// SRA D
			d = sra(d)
			cycles = 2
		case 0x2B:	// SRA E
			e = sra(e)
			cycles = 2
		case 0x2C:	// SRA H
			h = sra(h)
			cycles = 2
		case 0x2D:	// SRA L
			l = sra(l)
			cycles = 2
		case 0x2E:	// SRA (HL)
			write8(hl, sra(read8(hl)))
			cycles = 4
		case 0x2F:	// SRA A
			a = sra(a)
			cycles = 2
		default:
			break
		}
		return cycles
	}
}
