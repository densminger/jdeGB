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
	
	func srl(_ x: Int) -> Int {
		flag_c = (x & 0x01) > 0
		let ret = (x >> 1) & 0xFF
		flag_z = (ret == 0)
		flag_n = false
		flag_h = false
		return ret
	}
	
	func swap(_ x: Int) -> Int {
		let ret = ((x & 0xF0) >> 4 | (x & 0x0F) << 4) & 0xFF
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
	
	func bit(_ x: Int, _ bit: Int) {
		flag_z = (x & (1 << bit)) == 0
		flag_n = false
		flag_h = true
	}
	
	func res(_ x: Int, _ bit: Int) -> Int {
		return (x & ~(1 << bit)) & 0xFF
	}
	
	func set(_ x: Int, _ bit: Int) -> Int {
		return (x | (1 << bit)) & 0xFF
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
		case 0x30:	// SWAP B
			b = swap(b)
			cycles = 2
		case 0x31:	// SWAP C
			c = swap(c)
			cycles = 2
		case 0x32:	// SWAP D
			d = swap(d)
			cycles = 2
		case 0x33:	// SWAP E
			e = swap(e)
			cycles = 2
		case 0x34:	// SWAP H
			h = swap(h)
			cycles = 2
		case 0x35:	// SWAP L
			l = swap(l)
			cycles = 2
		case 0x36:	// SWAP (HL)
			write8(hl, swap(read8(hl)))
			cycles = 4
		case 0x37:	// SWAP A
			a = swap(a)
			cycles = 2
		case 0x38:	// SRL B
			b = srl(b)
			cycles = 2
		case 0x39:	// SRL C
			c = srl(c)
			cycles = 2
		case 0x3A:	// SRL D
			d = srl(d)
			cycles = 2
		case 0x3B:	// SRL E
			e = srl(e)
			cycles = 2
		case 0x3C:	// SRL H
			h = srl(h)
			cycles = 2
		case 0x3D:	// SRL L
			l = srl(l)
			cycles = 2
		case 0x3E:	// SRL (HL)
			write8(hl, srl(read8(hl)))
			cycles = 4
		case 0x3F:	// SRL A
			a = srl(a)
			cycles = 2
		case 0x40:	// BIT 0,B
			bit(b, 0)
			cycles = 2
		case 0x41:	// BIT 0,C
			bit(c, 0)
			cycles = 2
		case 0x42:	// BIT 0,D
			bit(d, 0)
			cycles = 2
		case 0x43:	// BIT 0,E
			bit(e, 0)
			cycles = 2
		case 0x44:	// BIT 0,H
			bit(h, 0)
			cycles = 2
		case 0x45:	// BIT 0,L
			bit(l, 0)
			cycles = 2
		case 0x46:	// BIT 0,(HL)
			bit(read8(hl), 0)
			cycles = 4
		case 0x47:	// BIT 0,A
			bit(a, 0)
			cycles = 2
		case 0x48:	// BIT 1,B
			bit(b, 1)
			cycles = 2
		case 0x49:	// BIT 1,C
			bit(c, 1)
			cycles = 2
		case 0x4A:	// BIT 1,D
			bit(d, 1)
			cycles = 2
		case 0x4B:	// BIT 1,E
			bit(e, 1)
			cycles = 2
		case 0x4C:	// BIT 1,H
			bit(h, 1)
			cycles = 2
		case 0x4D:	// BIT 1,L
			bit(l, 1)
			cycles = 2
		case 0x4E:	// BIT 1,(HL)
			bit(read8(hl), 1)
			cycles = 4
		case 0x4F:	// BIT 1,A
			bit(a, 1)
			cycles = 2
		case 0x50:	// BIT 2,B
			bit(b, 2)
			cycles = 2
		case 0x51:	// BIT 2,C
			bit(c, 2)
			cycles = 2
		case 0x52:	// BIT 2,D
			bit(d, 2)
			cycles = 2
		case 0x53:	// BIT 2,E
			bit(e, 2)
			cycles = 2
		case 0x54:	// BIT 2,H
			bit(h, 2)
			cycles = 2
		case 0x55:	// BIT 2,L
			bit(l, 2)
			cycles = 2
		case 0x56:	// BIT 2,(HL)
			bit(read8(hl), 2)
			cycles = 4
		case 0x57:	// BIT 2,A
			bit(a, 2)
			cycles = 2
		case 0x58:	// BIT 3,B
			bit(b, 3)
			cycles = 2
		case 0x59:	// BIT 3,C
			bit(c, 3)
			cycles = 2
		case 0x5A:	// BIT 3,D
			bit(d, 3)
			cycles = 2
		case 0x5B:	// BIT 3,E
			bit(e, 3)
			cycles = 2
		case 0x5C:	// BIT 3,H
			bit(h, 3)
			cycles = 2
		case 0x5D:	// BIT 3,L
			bit(l, 3)
			cycles = 2
		case 0x5E:	// BIT 3,(HL)
			bit(read8(hl), 3)
			cycles = 4
		case 0x5F:	// BIT 3,A
			bit(a, 3)
			cycles = 2
		case 0x60:	// BIT 4,B
			bit(b, 4)
			cycles = 2
		case 0x61:	// BIT 4,C
			bit(c, 4)
			cycles = 2
		case 0x62:	// BIT 4,D
			bit(d, 4)
			cycles = 2
		case 0x63:	// BIT 4,E
			bit(e, 4)
			cycles = 2
		case 0x64:	// BIT 4,H
			bit(h, 4)
			cycles = 2
		case 0x65:	// BIT 4,L
			bit(l, 4)
			cycles = 2
		case 0x66:	// BIT 4,(HL)
			bit(read8(hl), 4)
			cycles = 4
		case 0x67:	// BIT 4,A
			bit(a, 4)
			cycles = 2
		case 0x68:	// BIT 5,B
			bit(b, 5)
			cycles = 2
		case 0x69:	// BIT 5,C
			bit(c, 5)
			cycles = 2
		case 0x6A:	// BIT 5,D
			bit(d, 5)
			cycles = 2
		case 0x6B:	// BIT 5,E
			bit(e, 5)
			cycles = 2
		case 0x6C:	// BIT 5,H
			bit(h, 5)
			cycles = 2
		case 0x6D:	// BIT 5,L
			bit(l, 5)
			cycles = 2
		case 0x6E:	// BIT 5,(HL)
			bit(read8(hl), 5)
			cycles = 4
		case 0x6F:	// BIT 5,A
			bit(a, 5)
			cycles = 2
		case 0x70:	// BIT 6,B
			bit(b, 6)
			cycles = 2
		case 0x71:	// BIT 6,C
			bit(c, 6)
			cycles = 2
		case 0x72:	// BIT 6,D
			bit(d, 6)
			cycles = 2
		case 0x73:	// BIT 6,E
			bit(e, 6)
			cycles = 2
		case 0x74:	// BIT 6,H
			bit(h, 6)
			cycles = 2
		case 0x75:	// BIT 6,L
			bit(l, 6)
			cycles = 2
		case 0x76:	// BIT 6,(HL)
			bit(read8(hl), 6)
			cycles = 4
		case 0x77:	// BIT 6,A
			bit(a, 6)
			cycles = 2
		case 0x78:	// BIT 7,B
			bit(b, 7)
			cycles = 2
		case 0x79:	// BIT 7,C
			bit(c, 7)
			cycles = 2
		case 0x7A:	// BIT 7,D
			bit(d, 7)
			cycles = 2
		case 0x7B:	// BIT 7,E
			bit(e, 7)
			cycles = 2
		case 0x7C:	// BIT 7,H
			bit(h, 7)
			cycles = 2
		case 0x7D:	// BIT 7,L
			bit(l, 7)
			cycles = 2
		case 0x7E:	// BIT 7,(HL)
			bit(read8(hl), 7)
			cycles = 4
		case 0x7F:	// BIT 7,A
			bit(a, 7)
			cycles = 2
		case 0x80:	// RES 0,B
			b = res(b, 0)
			cycles = 2
		case 0x81:	// RES 0,C
			c = res(c, 0)
			cycles = 2
		case 0x82:	// RES 0,D
			d = res(d, 0)
			cycles = 2
		case 0x83:	// RES 0,E
			e = res(e, 0)
			cycles = 2
		case 0x84:	// RES 0,H
			h = res(h, 0)
			cycles = 2
		case 0x85:	// RES 0,L
			l = res(l, 0)
			cycles = 2
		case 0x86:	// RES 0,(HL)
			write8(hl, res(read8(hl), 0))
			cycles = 4
		case 0x87:	// RES 0,A
			a = res(a, 0)
			cycles = 2
		case 0x88:	// RES 1,B
			b = res(b, 1)
			cycles = 2
		case 0x89:	// RES 1,C
			c = res(c, 1)
			cycles = 2
		case 0x8A:	// RES 1,D
			d = res(d, 1)
			cycles = 2
		case 0x8B:	// RES 1,E
			e = res(e, 1)
			cycles = 2
		case 0x8C:	// RES 1,H
			h = res(h, 1)
			cycles = 2
		case 0x8D:	// RES 1,L
			l = res(l, 1)
			cycles = 2
		case 0x8E:	// RES 1,(HL)
			write8(hl, res(read8(hl), 1))
			cycles = 4
		case 0x8F:	// RES 1,A
			a = res(a, 1)
			cycles = 2
		case 0x90:	// RES 2,B
			b = res(b, 2)
			cycles = 2
		case 0x91:	// RES 2,C
			c = res(c, 2)
			cycles = 2
		case 0x92:	// RES 2,D
			d = res(d, 2)
			cycles = 2
		case 0x93:	// RES 2,E
			e = res(e, 2)
			cycles = 2
		case 0x94:	// RES 2,H
			h = res(h, 2)
			cycles = 2
		case 0x95:	// RES 2,L
			l = res(l, 2)
			cycles = 2
		case 0x96:	// RES 2,(HL)
			write8(hl, res(read8(hl), 2))
			cycles = 4
		case 0x97:	// RES 2,A
			a = res(a, 2)
			cycles = 2
		case 0x98:	// RES 3,B
			b = res(b, 3)
			cycles = 2
		case 0x99:	// RES 3,C
			c = res(c, 3)
			cycles = 2
		case 0x9A:	// RES 3,D
			d = res(d, 3)
			cycles = 2
		case 0x9B:	// RES 3,E
			e = res(e, 3)
			cycles = 2
		case 0x9C:	// RES 3,H
			h = res(h, 3)
			cycles = 2
		case 0x9D:	// RES 3,L
			l = res(l, 3)
			cycles = 2
		case 0x9E:	// RES 3,(HL)
			write8(hl, res(read8(hl), 3))
			cycles = 4
		case 0x9F:	// RES 3,A
			a = res(a, 3)
			cycles = 2
		case 0xA0:	// RES 4,B
			b = res(b, 4)
			cycles = 2
		case 0xA1:	// RES 4,C
			c = res(c, 4)
			cycles = 2
		case 0xA2:	// RES 4,D
			d = res(d, 4)
			cycles = 2
		case 0xA3:	// RES 4,E
			e = res(e, 4)
			cycles = 2
		case 0xA4:	// RES 4,H
			h = res(h, 4)
			cycles = 2
		case 0xA5:	// RES 4,L
			l = res(l, 4)
			cycles = 2
		case 0xA6:	// RES 4,(HL)
			write8(hl, res(read8(hl), 4))
			cycles = 4
		case 0xA7:	// RES 4,A
			a = res(a, 4)
			cycles = 2
		case 0xA8:	// RES 5,B
			b = res(b, 5)
			cycles = 2
		case 0xA9:	// RES 5,C
			c = res(c, 5)
			cycles = 2
		case 0xAA:	// RES 5,D
			d = res(d, 5)
			cycles = 2
		case 0xAB:	// RES 5,E
			e = res(e, 5)
			cycles = 2
		case 0xAC:	// RES 5,H
			h = res(h, 5)
			cycles = 2
		case 0xAD:	// RES 5,L
			l = res(l, 5)
			cycles = 2
		case 0xAE:	// RES 5,(HL)
			write8(hl, res(read8(hl), 5))
			cycles = 4
		case 0xAF:	// RES 5,A
			a = res(a, 5)
			cycles = 2
		case 0xB0:	// RES 6,B
			b = res(b, 6)
			cycles = 2
		case 0xB1:	// RES 6,C
			c = res(c, 6)
			cycles = 2
		case 0xB2:	// RES 6,D
			d = res(d, 6)
			cycles = 2
		case 0xB3:	// RES 6,E
			e = res(e, 6)
			cycles = 2
		case 0xB4:	// RES 6,H
			h = res(h, 6)
			cycles = 2
		case 0xB5:	// RES 6,L
			l = res(l, 6)
			cycles = 2
		case 0xB6:	// RES 6,(HL)
			write8(hl, res(read8(hl), 6))
			cycles = 4
		case 0xB7:	// RES 6,A
			a = res(a, 6)
			cycles = 2
		case 0xB8:	// RES 7,B
			b = res(b, 7)
			cycles = 2
		case 0xB9:	// RES 7,C
			c = res(c, 7)
			cycles = 2
		case 0xBA:	// RES 7,D
			d = res(d, 7)
			cycles = 2
		case 0xBB:	// RES 7,E
			e = res(e, 7)
			cycles = 2
		case 0xBC:	// RES 7,H
			h = res(h, 7)
			cycles = 2
		case 0xBD:	// RES 7,L
			l = res(l, 7)
			cycles = 2
		case 0xBE:	// RES 7,(HL)
			write8(hl, res(read8(hl), 7))
			cycles = 4
		case 0xBF:	// RES 7,A
			a = res(a, 7)
			cycles = 2
		case 0xC0:	// SET 0,B
			b = set(b, 0)
			cycles = 2
		case 0xC1:	// SET 0,C
			c = set(c, 0)
			cycles = 2
		case 0xC2:	// SET 0,D
			d = set(d, 0)
			cycles = 2
		case 0xC3:	// SET 0,E
			e = set(e, 0)
			cycles = 2
		case 0xC4:	// SET 0,H
			h = set(h, 0)
			cycles = 2
		case 0xC5:	// SET 0,L
			l = set(l, 0)
			cycles = 2
		case 0xC6:	// SET 0,(HL)
			write8(hl, set(read8(hl), 0))
			cycles = 4
		case 0xC7:	// SET 0,A
			a = set(a, 0)
			cycles = 2
		case 0xC8:	// SET 1,B
			b = set(b, 1)
			cycles = 2
		case 0xC9:	// SET 1,C
			c = set(c, 1)
			cycles = 2
		case 0xCA:	// SET 1,D
			d = set(d, 1)
			cycles = 2
		case 0xCB:	// SET 1,E
			e = set(e, 1)
			cycles = 2
		case 0xCC:	// SET 1,H
			h = set(h, 1)
			cycles = 2
		case 0xCD:	// SET 1,L
			l = set(l, 1)
			cycles = 2
		case 0xCE:	// SET 1,(HL)
			write8(hl, set(read8(hl), 1))
			cycles = 4
		case 0xCF:	// SET 1,A
			a = set(a, 1)
			cycles = 2
		case 0xD0:	// SET 2,B
			b = set(b, 2)
			cycles = 2
		case 0xD1:	// SET 2,C
			c = set(c, 2)
			cycles = 2
		case 0xD2:	// SET 2,D
			d = set(d, 2)
			cycles = 2
		case 0xD3:	// SET 2,E
			e = set(e, 2)
			cycles = 2
		case 0xD4:	// SET 2,H
			h = set(h, 2)
			cycles = 2
		case 0xD5:	// SET 2,L
			l = set(l, 2)
			cycles = 2
		case 0xD6:	// SET 2,(HL)
			write8(hl, set(read8(hl), 2))
			cycles = 4
		case 0xD7:	// SET 2,A
			a = set(a, 2)
			cycles = 2
		case 0xD8:	// SET 3,B
			b = set(b, 3)
			cycles = 2
		case 0xD9:	// SET 3,C
			c = set(c, 3)
			cycles = 2
		case 0xDA:	// SET 3,D
			d = set(d, 3)
			cycles = 2
		case 0xDB:	// SET 3,E
			e = set(e, 3)
			cycles = 2
		case 0xDC:	// SET 3,H
			h = set(h, 3)
			cycles = 2
		case 0xDD:	// SET 3,L
			l = set(l, 3)
			cycles = 2
		case 0xDE:	// SET 3,(HL)
			write8(hl, set(read8(hl), 3))
			cycles = 4
		case 0xDF:	// SET 3,A
			a = set(a, 3)
			cycles = 2
		case 0xE0:	// SET 4,B
			b = set(b, 4)
			cycles = 2
		case 0xE1:	// SET 4,C
			c = set(c, 4)
			cycles = 2
		case 0xE2:	// SET 4,D
			d = set(d, 4)
			cycles = 2
		case 0xE3:	// SET 4,E
			e = set(e, 4)
			cycles = 2
		case 0xE4:	// SET 4,H
			h = set(h, 4)
			cycles = 2
		case 0xE5:	// SET 4,L
			l = set(l, 4)
			cycles = 2
		case 0xE6:	// SET 4,(HL)
			write8(hl, set(read8(hl), 4))
			cycles = 4
		case 0xE7:	// SET 4,A
			a = set(a, 4)
			cycles = 2
		case 0xE8:	// SET 5,B
			b = set(b, 5)
			cycles = 2
		case 0xE9:	// SET 5,C
			c = set(c, 5)
			cycles = 2
		case 0xEA:	// SET 5,D
			d = set(d, 5)
			cycles = 2
		case 0xEB:	// SET 5,E
			e = set(e, 5)
			cycles = 2
		case 0xEC:	// SET 5,H
			h = set(h, 5)
			cycles = 2
		case 0xED:	// SET 5,L
			l = set(l, 5)
			cycles = 2
		case 0xEE:	// SET 5,(HL)
			write8(hl, set(read8(hl), 5))
			cycles = 4
		case 0xEF:	// SET 5,A
			a = set(a, 5)
			cycles = 2
		case 0xF0:	// SET 6,B
			b = set(b, 6)
			cycles = 2
		case 0xF1:	// SET 6,C
			c = set(c, 6)
			cycles = 2
		case 0xF2:	// SET 6,D
			d = set(d, 6)
			cycles = 2
		case 0xF3:	// SET 6,E
			e = set(e, 6)
			cycles = 2
		case 0xF4:	// SET 6,H
			h = set(h, 6)
			cycles = 2
		case 0xF5:	// SET 6,L
			l = set(l, 6)
			cycles = 2
		case 0xF6:	// SET 6,(HL)
			write8(hl, set(read8(hl), 6))
			cycles = 4
		case 0xF7:	// SET 6,A
			a = set(a, 6)
			cycles = 2
		case 0xF8:	// SET 7,B
			b = set(b, 7)
			cycles = 2
		case 0xF9:	// SET 7,C
			c = set(c, 7)
			cycles = 2
		case 0xFA:	// SET 7,D
			d = set(d, 7)
			cycles = 2
		case 0xFB:	// SET 7,E
			e = set(e, 7)
			cycles = 2
		case 0xFC:	// SET 7,H
			h = set(h, 7)
			cycles = 2
		case 0xFD:	// SET 7,L
			l = set(l, 7)
			cycles = 2
		case 0xFE:	// SET 7,(HL)
			write8(hl, set(read8(hl), 7))
			cycles = 4
		case 0xFF:	// SET 7,A
			a = set(a, 7)
			cycles = 2
		default:
			break
		}
		return cycles
	}
}
