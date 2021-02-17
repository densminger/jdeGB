//
//  LR35902+OpCodes.swift
//  jdeGB
//
//  Created by David Ensminger on 2/12/21.
//

extension LR35902 {
	func half_carry(_ x: Int, _ y: Int) -> Bool {
		return (((x & 0x0f) + (y & 0x0f)) & 0x10) == 0x10
	}
	
	func carry(_ x: Int, _ y: Int) -> Bool {
		return x + y > 255
	}

	// Perform the operation indicated by opcode.
	// Return the number of machine cycles the operation requires
	func perform_operation(opcode: Int) -> Int {
		var cycles = 1
		switch opcode {
		case 0x00:	// NOP
			cycles = 1
			break
		case 0x01:	// LD BC,d16
			bc = read16(pc)
			pc += 2
			cycles = 3
			break
		case 0x02:	// LD (BC),A
			write8(bc, a)
			cycles = 2
		case 0x03:	// INC BC
			bc = (bc + 1) & 0xFFFF
			cycles = 2
		case 0x04:	// INC B
			flag_h = half_carry(b, 1)
			b = (b + 1) & 0xFF
			flag_z = (b == 0)
			flag_n = false
			cycles = 1
		case 0x05:	// DEC B
			flag_h = half_carry(b, -1)
			b = (b - 1) & 0xFF
			flag_z = (b == 0)
			flag_n = true
			cycles = 1
		case 0x06:	// LD B,d8
			b = read8(pc)
			pc += 1
			cycles = 2
		case 0x07:	// RLCA
			a = rlc(a)
			flag_z = false
			cycles = 1
		case 0x08:	// LD (a16),SP
			write16(read16(pc), sp)
			pc += 2
			cycles = 5
		case 0x09:	// ADD HL,BC
			flag_h = half_carry(hl, bc)
			flag_c = carry(hl, bc)
			hl = (hl + bc) & 0xFFFF
			flag_n = false
			cycles = 2
		case 0x0A:	// LD A,(BC)
			a = read16(bc)
			cycles = 2
		case 0x0B:	// DEC BC
			bc = (bc - 1) & 0xFFFF
			cycles = 2
		case 0x0C:	// INC C
			flag_h = half_carry(c, 1)
			c = (c + 1) & 0xFF
			flag_z = (c == 0)
			flag_n = false
			cycles = 1
		case 0x0D:	// DEC C
			flag_h = half_carry(c, -1)
			c = (c - 1) & 0xFF
			flag_z = (c == 0)
			flag_n = true
			cycles = 1
		case 0x0E:	// LD C,d8
			c = read8(pc)
			pc += 1
			cycles = 2
		case 0x0F:	// RRCA
			a = rrc(a)
			flag_z = false
			cycles = 1
		case 0x10:	// STOP 0
			stop = true
			pc += 1
			cycles = 1
		case 0x11:	// LD DE,d16
			de = read16(pc)
			pc += 2
			cycles = 3
		case 0x12:	// LD (DE),A
			write8(de, a)
			cycles = 2
		case 0x13:	// INC DE
			de = (de + 1) & 0xFFFF
			cycles = 2
		case 0x14:	// INC D
			flag_h = half_carry(d, 1)
			d = (d + 1) & 0xFF
			flag_z = (d == 0)
			flag_n = false
			cycles = 1
		case 0x15:	// DEC D
			flag_h = half_carry(d, -1)
			d = (d - 1) & 0xFF
			flag_z = (d == 0)
			flag_n = true
			cycles = 1
		case 0x16:	// LD D,d8
			d = (d + read8(pc)) & 0xFF
			pc += 1
			cycles = 2
		case 0x17:	// RLA
			a = rl(a)
			flag_z = false
			cycles = 1
		case 0x18:	// JR r8
			var data = read8(pc)
			pc += 1
			if data & 0x80 > 0 {
				data = data - 256
			}
			pc = (pc + data) & 0xFFFF
			cycles = 3
		case 0x19:	// ADD HL,DE
			flag_h = half_carry(hl, de)
			flag_c = carry(hl, de)
			hl = (hl + de) & 0xFFFF
			flag_n = false
			cycles = 2
		case 0x1A:	// LD A,(DE)
			a = read8(de)
			cycles = 2
		case 0x1B:	// DEC DE
			de = (de - 1) & 0xFFFF
			cycles = 2
		case 0x1C:	// INC E
			flag_h = half_carry(e, 1)
			e = (e + 1) & 0xFF
			flag_z = (e == 0)
			flag_n = false
			cycles = 1
		case 0x1D:	// DEC E
			flag_h = half_carry(e, -1)
			e = (e - 1) & 0xFF
			flag_z = (e == 0)
			flag_n = true
			cycles = 1
		case 0x1E:	// LD e,d8
			e = read8(pc)
			pc += 1
			cycles = 2
		case 0x1F:	// RRA
			a = rr(a)
			flag_z = false
			cycles = 1
		case 0x20:	// JR NZ,r8
			var data = read8(pc)
			pc += 1
			if data & 0x80 > 0 {
				data -= 256
			}
			if !flag_z {
				pc = (pc + data) & 0xFFFF
				cycles = 3
			} else {
				cycles = 2
			}
		case 0x21:	// LD HL,d16
			hl = read16(pc)
			pc += 2
			cycles = 3
		case 0x22:	// LD (HL+),A
			write8(hl, a)
			hl = (hl + 1) & 0xFFFF
			cycles = 2
		case 0x23:	// INC HL
			hl = (hl + 1) & 0xFFFF
			cycles = 2
		case 0x24:	// INC H
			flag_h = half_carry(h, 1)
			h = (h + 1) & 0xFF
			flag_z = (h == 0)
			flag_n = false
			cycles = 1
		case 0x25:	// DEC H
			flag_h = half_carry(h, -1)
			h = (h - 1) & 0xFF
			flag_z = (h == 0)
			flag_n = true
			cycles = 1
		case 0x26:	// LD H,d8
			h = read8(pc)
			pc += 1
			cycles = 2
		case 0x27:	// DAA
			var add = 0
			
			// if the previous operation resulted in a half-carry,
			// or the low nibble of A is > 9,
			// then we need to either add or subtract 0x06, depending on
			// whether the previous operation was addition or subtraction
			if flag_h || (a & 0x0F) > 0x09 {
				if flag_n {
					add -= 0x06
				} else {
					add += 0x06
				}
			}
			
			// same thing but for the high nibble
			if flag_c || (a & 0xF0) > 0x90 {
				if flag_n {
					add -= 0x60
				} else {
					add += 0x60
				}
			}

			flag_c = carry(a, add)
			a = (a + add) & 0xFF
			flag_h = false
			flag_z = (a == 0)
			cycles = 1
		case 0x28:	// JR Z,r8
			var data = read8(pc)
			pc += 1
			if data & 0x80 > 0 {
				data -= 256
			}
			if flag_z {
				pc = (pc + data) & 0xFFFF
				cycles = 3
			} else {
				cycles = 2
			}
		case 0x29:	// ADD HL,HL
			flag_h = half_carry(hl, hl)
			flag_c = carry(hl, hl)
			hl = (hl + hl) & 0xFFFF
			flag_n = false
			cycles = 2
		case 0x2A:	// LD A,(HL+)
			a = read16(hl)
			pc += 2
			hl = (hl + 1) & 0xFFFF
			cycles = 2
		case 0x2B:	// DEC HL
			hl = (hl - 1) & 0xFFFF
			cycles = 2
		case 0x2C:	// INC L
			flag_h = half_carry(l, 1)
			l = (l + 1) & 0xFF
			flag_z = (l == 0)
			flag_n = false
			cycles = 1
		case 0x2D:	// DEC L
			flag_h = half_carry(l, -1)
			l = (l - 1) & 0xFF
			flag_z = (l == 0)
			flag_n = true
			cycles = 1
		case 0x2E:	// LD L,d8
			l = read8(pc)
			pc += 1
			cycles = 2
		case 0x2F:	// CPL
			a = (~a & 0xFF)
			flag_n = true
			flag_h = true
			cycles = 1
		case 0x30:	// JR NC,r8
			var data = read8(pc)
			pc += 1
			if data & 0x80 > 0 {
				data -= 256
			}
			if !flag_c {
				pc = (pc + data) & 0xFFFF
				cycles = 3
			} else {
				cycles = 2
			}
		case 0x31:	// LD SP,d16
			sp = read16(pc)
			pc += 2
			cycles = 3
		case 0x32:	// LD (HL-),A
			write8(hl, a)
			hl = (hl - 1) & 0xFFFF
			cycles = 2
		case 0x33:	// INC SP
			sp = (sp + 1) & 0xFFFF
			cycles = 2
		case 0x34:	// INC (HL)
			var data = read8(hl)
			flag_h = half_carry(data, 1)
			data = (data + 1) & 0xFF
			write8(hl, data)
			flag_z = (data == 0)
			flag_n = false
			cycles = 3
		case 0x35:	// DEC (HL)
			var data = read8(hl)
			flag_h = half_carry(data, -1)
			data = (data - 1) & 0xFF
			write8(hl, data)
			flag_z = (data == 0)
			flag_n = true
			cycles = 3
		case 0x36:	// LD (HL),d8
			write8(hl, read8(pc))
			pc += 1
			cycles = 3
		case 0x37:	// SCF
			flag_c = true
			flag_n = false
			flag_h = false
			cycles = 1
		case 0x38:	// JR C,r8
			var data = read8(pc)
			pc += 1
			if data & 0x80 > 0 {
				data -= 256
			}
			if flag_c {
				pc = (pc + data) & 0xFFFF
				cycles = 3
			} else {
				cycles = 2
			}
		case 0x39:	// ADD HL,SP
			flag_h = half_carry(hl, sp)
			flag_c = carry(hl, sp)
			hl = (hl + sp) & 0xFFFF
			flag_n = false
			cycles = 2
		case 0x3A:	// LD A,(HL-)
			a = read16(hl)
			pc += 2
			hl = (hl - 1) & 0xFFFF
			cycles = 2
		case 0x3B:	// DEC SP
			sp = (sp - 1) & 0xFFFF
			cycles = 2
		case 0x3C:	// INC A
			flag_h = half_carry(a, 1)
			a = (a + 1) & 0xFF
			flag_z = (a == 0)
			flag_n = false
			cycles = 1
		case 0x3D:	// DEC A
			flag_h = half_carry(a, -1)
			a = (a - 1) & 0xFF
			flag_z = (a == 0)
			flag_n = true
			cycles = 1
		case 0x3E:	// LD A,d8
			a = read8(pc)
			pc += 1
			cycles = 2
		case 0x3F:	// CCF
			flag_c = !flag_c
			flag_n = false
			flag_h = false
			cycles = 1
		case 0x40:	// LD B,B
			// this does nothing!
			cycles = 1
		case 0x41:	// LD B,C
			b = c
			cycles = 1
		case 0x42:	// LD B,D
			b = d
			cycles = 1
		case 0x43:	// LD B,E
			b = e
			cycles = 1
		case 0x44:	// LD B,H
			b = h
			cycles = 1
		case 0x45:	// LD B,L
			b = l
			cycles = 1
		case 0x46:	// LD B,(HL)
			b = read8(hl)
			cycles = 2
		case 0x47:	// LD B,A
			b = a
			cycles = 1
		case 0x48:	// LD C,B
			c = b
			cycles = 1
		case 0x49:	// LD C,C
			// this does nothing!
			cycles = 1
		case 0x4A:	// LD C,D
			c = d
			cycles = 1
		case 0x4B:	// LD C,E
			c = e
			cycles = 1
		case 0x4C:	// LD C,H
			c = h
			cycles = 1
		case 0x4D:	// LD C,L
			c = l
			cycles = 1
		case 0x4E:	// LD C,(HL)
			c = read8(hl)
			cycles = 2
		case 0x4F:	// LD C,A
			c = a
			cycles = 1
		case 0x50:	// LD D,B
			d = b
			cycles = 1
		case 0x51:	// LD D,C
			d = c
			cycles = 1
		case 0x52:	// LD D,D
			// this does nothing!
			cycles = 1
		case 0x53:	// LD D,E
			d = e
			cycles = 1
		case 0x54:	// LD D,H
			d = h
			cycles = 1
		case 0x55:	// LD D,L
			d = l
			cycles = 1
		case 0x56:	// LD D,(HL)
			d = read8(hl)
			cycles = 2
		case 0x57:	// LD D,A
			d = a
			cycles = 1
		case 0x58:	// LD E,B
			e = b
			cycles = 1
		case 0x59:	// LD E,C
			e = c
			cycles = 1
		case 0x5A:	// LD E,D
			e = d
			cycles = 1
		case 0x5B:	// LD E,E
			// this does nothing!
			cycles = 1
		case 0x5C:	// LD E,H
			e = h
			cycles = 1
		case 0x5D:	// LD E,L
			e = l
			cycles = 1
		case 0x5E:	// LD E,(HL)
			e = read8(hl)
			cycles = 2
		case 0x5F:	// LD E,A
			e = a
			cycles = 1
		case 0x60:	// LD H,B
			h = b
			cycles = 1
		case 0x61:	// LD H,C
			h = c
			cycles = 1
		case 0x62:	// LD H,D
			h = d
			cycles = 1
		case 0x63:	// LD H,E
			h = e
			cycles = 1
		case 0x64:	// LD H,H
			// this does nothing!
			cycles = 1
		case 0x65:	// LD H,L
			h = l
			cycles = 1
		case 0x66:	// LD H,(HL)
			h = read8(hl)
			cycles = 2
		case 0x67:	// LD H,A
			h = a
			cycles = 1
		case 0x68:	// LD L,B
			l = b
			cycles = 1
		case 0x69:	// LD L,C
			l = c
			cycles = 1
		case 0x6A:	// LD L,D
			l = d
			cycles = 1
		case 0x6B:	// LD L,E
			l = e
			cycles = 1
		case 0x6C:	// LD L,H
			l = h
			cycles = 1
		case 0x6D:	// LD L,L
			// this does nothing!
			cycles = 1
		case 0x6E:	// LD L,(HL)
			l = read8(hl)
			cycles = 2
		case 0x6F:	// LD L,A
			l = a
			cycles = 1
		case 0x70:	// LD (HL),B
			write8(hl, b)
			cycles = 2
		case 0x71:	// LD (HL),C
			write8(hl, c)
			cycles = 2
		case 0x72:	// LD (HL),D
			write8(hl, d)
			cycles = 2
		case 0x73:	// LD (HL),E
			write8(hl, e)
			cycles = 2
		case 0x74:	// LD (HL),H
			write8(hl, h)
			cycles = 2
		case 0x75:	// LD (HL),L
			write8(hl, l)
			cycles = 2
		case 0x76:	// HALT
			halt = true
			cycles = 1
		case 0x77:	// LD (HL),A
			write8(hl, a)
			cycles = 2
		case 0x78:	// LD A,B
			a = b
			cycles = 1
		case 0x79:	// LD A,C
			a = c
			cycles = 1
		case 0x7A:	// LD A,D
			a = d
			cycles = 1
		case 0x7B:	// LD A,E
			a = e
			cycles = 1
		case 0x7C:	// LD A,H
			a = h
			cycles = 1
		case 0x7D:	// LD A,L
			a = l
			cycles = 1
		case 0x7E:	// LD A,(HL)
			a = read8(hl)
			cycles = 2
		case 0x7F:	// LD A,A
			// this does nothing!
			cycles = 1
		case 0x80:	// ADD A,B
			flag_h = half_carry(a, b)
			flag_c = carry(a, b)
			a = (a + b) & 0xFF
			flag_z = (a == 0)
			flag_n = false
			cycles = 1
		case 0x81:	// ADD A,C
			flag_h = half_carry(a, c)
			flag_c = carry(a, c)
			a = (a + c) & 0xFF
			flag_z = (a == 0)
			flag_n = false
			cycles = 1
		case 0x82:	// ADD A,D
			flag_h = half_carry(a, d)
			flag_c = carry(a, d)
			a = (a + d) & 0xFF
			flag_z = (a == 0)
			flag_n = false
			cycles = 1
		case 0x83:	// ADD A,E
			flag_h = half_carry(a, e)
			flag_c = carry(a, e)
			a = (a + e) & 0xFF
			flag_z = (a == 0)
			flag_n = false
			cycles = 1
		case 0x84:	// ADD A,H
			flag_h = half_carry(a, h)
			flag_c = carry(a, h)
			a = (a + h) & 0xFF
			flag_z = (a == 0)
			flag_n = false
			cycles = 1
		case 0x85:	// ADD A,L
			flag_h = half_carry(a, l)
			flag_c = carry(a, l)
			a = (a + l) & 0xFF
			flag_z = (a == 0)
			flag_n = false
			cycles = 1
		case 0x86:	// ADD A,(HL)
			let data = read8(hl)
			flag_h = half_carry(a, data)
			flag_c = carry(a, data)
			a = (a + data) & 0xFF
			flag_z = (a == 0)
			flag_n = false
			cycles = 2
		case 0x87:	// ADD A,A
			flag_h = half_carry(a, a)
			flag_c = carry(a, a)
			a = (a + a) & 0xFF
			flag_z = (a == 0)
			flag_n = false
			cycles = 1
		case 0x88:	// ADC A,B
			let cy = b + (flag_c ? 1 : 0)
			flag_h = half_carry(a, cy)
			flag_c = carry(a, cy)
			a = (a + cy) & 0xFF
			flag_z = (a == 0)
			flag_n = false
			cycles = 1
		case 0x89:	// ADC A,C
			let cy = c + (flag_c ? 1 : 0)
			flag_h = half_carry(a, cy)
			flag_c = carry(a, cy)
			a = (a + cy) & 0xFF
			flag_z = (a == 0)
			flag_n = false
			cycles = 1
		case 0x8A:	// ADC A,D
			let cy = d + (flag_c ? 1 : 0)
			flag_h = half_carry(a, cy)
			flag_c = carry(a, cy)
			a = (a + cy) & 0xFF
			flag_z = (a == 0)
			flag_n = false
			cycles = 1
		case 0x8B:	// ADC A,E
			let cy = e + (flag_c ? 1 : 0)
			flag_h = half_carry(a, cy)
			flag_c = carry(a, cy)
			a = (a + cy) & 0xFF
			flag_z = (a == 0)
			flag_n = false
			cycles = 1
		case 0x8C:	// ADC A,H
			let cy = h + (flag_c ? 1 : 0)
			flag_h = half_carry(a, cy)
			flag_c = carry(a, cy)
			a = (a + cy) & 0xFF
			flag_z = (a == 0)
			flag_n = false
			cycles = 1
		case 0x8D:	// ADC A,L
			let cy = l + (flag_c ? 1 : 0)
			flag_h = half_carry(a, cy)
			flag_c = carry(a, cy)
			a = (a + cy) & 0xFF
			flag_z = (a == 0)
			flag_n = false
			cycles = 1
		case 0x8E:	// ADC A,(HL)
			let data = read8(hl) + (flag_c ? 1 : 0)
			flag_h = half_carry(a, data)
			flag_c = carry(a, data)
			a = (a + data) & 0xFF
			flag_z = (a == 0)
			flag_n = false
			cycles = 2
		case 0x8F:	// ADC A,A
			let cy = a + (flag_c ? 1 : 0)
			flag_h = half_carry(a, cy)
			flag_c = carry(a, cy)
			a = (a + cy) & 0xFF
			flag_z = (a == 0)
			flag_n = false
			cycles = 1
		case 0x90:	// SUB B
			flag_h = half_carry(a, -b)
			flag_c = carry(a, -b)
			a = (a - b) & 0xFF
			flag_z = (a == 0)
			flag_n = true
			cycles = 1
		case 0x91:	// SUB C
			flag_h = half_carry(a, -c)
			flag_c = carry(a, -c)
			a = (a - c) & 0xFF
			flag_z = (a == 0)
			flag_n = true
			cycles = 1
		case 0x92:	// SUB D
			flag_h = half_carry(a, -d)
			flag_c = carry(a, -d)
			a = (a - d) & 0xFF
			flag_z = (a == 0)
			flag_n = true
			cycles = 1
		case 0x93:	// SUB E
			flag_h = half_carry(a, -e)
			flag_c = carry(a, -e)
			a = (a - e) & 0xFF
			flag_z = (a == 0)
			flag_n = true
			cycles = 1
		case 0x94:	// SUB H
			flag_h = half_carry(a, -h)
			flag_c = carry(a, -h)
			a = (a - h) & 0xFF
			flag_z = (a == 0)
			flag_n = true
			cycles = 1
		case 0x95:	// SUB L
			flag_h = half_carry(a, -l)
			flag_c = carry(a, -l)
			a = (a - l) & 0xFF
			flag_z = (a == 0)
			flag_n = true
			cycles = 1
		case 0x96:	// SUB (HL)
			let data = read8(hl)
			flag_h = half_carry(a, -data)
			flag_c = carry(a, -data)
			a = (a - data) & 0xFF
			flag_z = (a == 0)
			flag_n = true
			cycles = 2
		case 0x97:	// SUB A
			flag_h = half_carry(a, -a)
			flag_c = carry(a, -a)
			a = (a - a) & 0xFF
			flag_z = (a == 0)
			flag_n = true
			cycles = 1
		case 0x98:	// SBC A,B
			let cy = b + (flag_c ? 1 : 0)
			flag_h = half_carry(a, -cy)
			flag_c = carry(a, -cy)
			a = (a - cy) & 0xFF
			flag_z = (a == 0)
			flag_n = true
			cycles = 1
		case 0x99:	// SBC A,C
			let cy = c + (flag_c ? 1 : 0)
			flag_h = half_carry(a, -cy)
			flag_c = carry(a, -cy)
			a = (a - cy) & 0xFF
			flag_z = (a == 0)
			flag_n = true
			cycles = 1
		case 0x9A:	// SBC A,D
			let cy = d + (flag_c ? 1 : 0)
			flag_h = half_carry(a, -cy)
			flag_c = carry(a, -cy)
			a = (a - cy) & 0xFF
			flag_z = (a == 0)
			flag_n = true
			cycles = 1
		case 0x9B:	// SBC A,E
			let cy = e + (flag_c ? 1 : 0)
			flag_h = half_carry(a, -cy)
			flag_c = carry(a, -cy)
			a = (a - cy) & 0xFF
			flag_z = (a == 0)
			flag_n = true
			cycles = 1
		case 0x9C:	// SBC A,H
			let cy = h + (flag_c ? 1 : 0)
			flag_h = half_carry(a, -cy)
			flag_c = carry(a, -cy)
			a = (a - cy) & 0xFF
			flag_z = (a == 0)
			flag_n = true
			cycles = 1
		case 0x9D:	// SBC A,L
			let cy = l + (flag_c ? 1 : 0)
			flag_h = half_carry(a, -cy)
			flag_c = carry(a, -cy)
			a = (a - cy) & 0xFF
			flag_z = (a == 0)
			flag_n = true
			cycles = 1
		case 0x9E:	// SBC A,(HL)
			let data = read8(hl) + (flag_c ? 1 : 0)
			flag_h = half_carry(a, -data)
			flag_c = carry(a, -data)
			a = (a - data) & 0xFF
			flag_z = (a == 0)
			flag_n = true
			cycles = 2
		case 0x9F:	// SBC A,A
			let cy = a + (flag_c ? 1 : 0)
			flag_h = half_carry(a, -cy)
			flag_c = carry(a, -cy)
			a = (a - cy) & 0xFF
			flag_z = (a == 0)
			flag_n = true
			cycles = 1
		case 0xA0:	// AND B
			a = a & b
			flag_z = (a == 0)
			flag_n = false
			flag_h = true
			flag_c = false
			cycles = 1
		case 0xA1:	// AND C
			a = a & c
			flag_z = (a == 0)
			flag_n = false
			flag_h = true
			flag_c = false
			cycles = 1
		case 0xA2:	// AND D
			a = a & d
			flag_z = (a == 0)
			flag_n = false
			flag_h = true
			flag_c = false
			cycles = 1
		case 0xA3:	// AND E
			a = a & e
			flag_z = (a == 0)
			flag_n = false
			flag_h = true
			flag_c = false
			cycles = 1
		case 0xA4:	// AND H
			a = a & h
			flag_z = (a == 0)
			flag_n = false
			flag_h = true
			flag_c = false
			cycles = 1
		case 0xA5:	// AND L
			a = a & l
			flag_z = (a == 0)
			flag_n = false
			flag_h = true
			flag_c = false
			cycles = 1
		case 0xA6:	// AND (HL)
			a = a & read8(hl)
			flag_z = (a == 0)
			flag_n = false
			flag_h = true
			flag_c = false
			cycles = 2
		case 0xA7:	// AND A
			a = a & a
			flag_z = (a == 0)
			flag_n = false
			flag_h = true
			flag_c = false
			cycles = 1
		case 0xA8:	// XOR B
			a = a ^ b
			flag_z = (a == 0)
			flag_n = false
			flag_h = false
			flag_c = false
			cycles = 1
		case 0xA9:	// XOR C
			a = a ^ c
			flag_z = (a == 0)
			flag_n = false
			flag_h = false
			flag_c = false
			cycles = 1
		case 0xAA:	// XOR D
			a = a ^ d
			flag_z = (a == 0)
			flag_n = false
			flag_h = false
			flag_c = false
			cycles = 1
		case 0xAB:	// XOR E
			a = a ^ e
			flag_z = (a == 0)
			flag_n = false
			flag_h = false
			flag_c = false
			cycles = 1
		case 0xAC:	// XOR H
			a = a ^ h
			flag_z = (a == 0)
			flag_n = false
			flag_h = false
			flag_c = false
			cycles = 1
		case 0xAD:	// XOR L
			a = a ^ l
			flag_z = (a == 0)
			flag_n = false
			flag_h = false
			flag_c = false
			cycles = 1
		case 0xAE:	// XOR (HL)
			a = a ^ read8(hl)
			flag_z = (a == 0)
			flag_n = false
			flag_h = false
			flag_c = false
			cycles = 2
		case 0xAF:	// XOR A
			a = a ^ a
			flag_z = (a == 0)
			flag_n = false
			flag_h = false
			flag_c = false
			cycles = 1
		case 0xB0:	// OR B
			a = a | b
			flag_z = (a == 0)
			flag_n = false
			flag_h = false
			flag_c = false
			cycles = 1
		case 0xB1:	// OR C
			a = a | c
			flag_z = (a == 0)
			flag_n = false
			flag_h = false
			flag_c = false
			cycles = 1
		case 0xB2:	// OR D
			a = a | d
			flag_z = (a == 0)
			flag_n = false
			flag_h = false
			flag_c = false
			cycles = 1
		case 0xB3:	// OR E
			a = a | e
			flag_z = (a == 0)
			flag_n = false
			flag_h = false
			flag_c = false
			cycles = 1
		case 0xB4:	// OR H
			a = a | h
			flag_z = (a == 0)
			flag_n = false
			flag_h = false
			flag_c = false
			cycles = 1
		case 0xB5:	// OR L
			a = a | l
			flag_z = (a == 0)
			flag_n = false
			flag_h = false
			flag_c = false
			cycles = 1
		case 0xB6:	// OR (HL)
			a = a | read8(hl)
			flag_z = (a == 0)
			flag_n = false
			flag_h = false
			flag_c = false
			cycles = 2
		case 0xB7:	// OR A
			a = a | a
			flag_z = (a == 0)
			flag_n = false
			flag_h = false
			flag_c = false
			cycles = 1
		case 0xB8:	// CP B
			flag_h = half_carry(a, -b)
			flag_c = carry(a, -b)
			flag_z = (a == b)
			flag_n = true
			cycles = 1
		case 0xB9:	// CP C
			flag_h = half_carry(a, -c)
			flag_c = carry(a, -c)
			flag_z = (a == c)
			flag_n = true
			cycles = 1
		case 0xBA:	// CP D
			flag_h = half_carry(a, -d)
			flag_c = carry(a, -d)
			flag_z = (a == d)
			flag_n = true
			cycles = 1
		case 0xBB:	// CP E
			flag_h = half_carry(a, -e)
			flag_c = carry(a, -e)
			flag_z = (a == e)
			flag_n = true
			cycles = 1
		case 0xBC:	// CP H
			flag_h = half_carry(a, -h)
			flag_c = carry(a, -h)
			flag_z = (a == h)
			flag_n = true
			cycles = 1
		case 0xBD:	// CP L
			flag_h = half_carry(a, -l)
			flag_c = carry(a, -l)
			flag_z = (a == l)
			flag_n = true
			cycles = 1
		case 0xBE:	// CP (HL)
			let data = read8(hl)
			flag_h = half_carry(a, -data)
			flag_c = carry(a, -data)
			flag_z = (a == data)
			flag_n = true
			cycles = 2
		case 0xBF:	// CP A
			flag_h = half_carry(a, -a)
			flag_c = carry(a, -a)
			flag_z = true
			flag_n = true
			cycles = 1
		case 0xC0:	// RET NZ
			if !flag_z {
				pc = read16(sp)
				sp += 2
				cycles = 5
			} else {
				cycles = 2
			}
		case 0xC1:	// POP BC
			bc = read16(sp)
			sp += 2
			cycles = 3
		case 0xC2:	// JP NZ,a16
			let data = read16(pc)
			pc += 2
			if !flag_z {
				pc = data
				cycles = 4
			} else {
				cycles = 3
			}
		case 0xC3:	// JP a16
			pc = read16(pc)
			cycles = 4
		case 0xC4:	// CALL NZ,a16
			let data = read16(pc)
			pc += 2
			if !flag_z {
				sp -= 2
				write16(sp, pc)
				pc = data
				cycles = 6
			} else {
				cycles = 3
			}
		case 0xC5:	// PUSH BC
			sp -= 2
			write16(sp, bc)
			cycles = 4
		case 0xC6:	// ADD A,d8
			let data = read8(pc)
			pc += 1
			flag_h = half_carry(a, data)
			flag_c = carry(a, data)
			a = (a + data) & 0xFF
			flag_z = (a == 0)
			flag_n = false
			cycles = 2
		case 0xC7:	// RST 00H
			sp -= 2
			write16(sp, pc)
			pc = 0x0000
			cycles = 4
		case 0xC8:	// RET Z
			if flag_z {
				pc = read16(sp)
				sp += 2
				cycles = 5
			} else {
				cycles = 2
			}
		case 0xC9:	// RET
			pc = read16(sp)
			sp += 2
			cycles = 4
		case 0xCA:	// JP Z,a16
			if flag_z {
				pc = read16(pc)
				cycles = 4
			} else {
				cycles = 3
			}
		case 0xCB:	// PREFIX CB
			let operation = read8(pc)
			pc += 1
			cycles = perform_cb(operation)
			cycles += 1
		case 0xCC:	// CALL Z,a16
			let data = read16(pc)
			pc += 2
			if flag_z {
				sp -= 2
				write16(sp, pc)
				pc = data
				cycles = 6
			} else {
				cycles = 3
			}
		case 0xCD:	// CALL a16
			let data = read16(pc)
			pc += 2
			sp -= 2
			write16(sp, pc)
			pc = data
			cycles = 6
		case 0xCE:	// ADC A,d8
			let cy = read8(pc) + (flag_c ? 1 : 0)
			pc += 1
			flag_h = half_carry(a, cy)
			flag_c = carry(a, cy)
			a = (a + cy) & 0xFF
			flag_z = (a == 0)
			flag_n = false
			cycles = 2
		case 0xCF:	// RST 08H
			sp -= 2
			write16(sp, pc)
			pc = 0x0008
			cycles = 4
		case 0xD0:	// RET NC
			if !flag_c {
				pc = read16(sp)
				sp += 2
				cycles = 5
			} else {
				cycles = 2
			}
		case 0xD1:	// POP DE
			de = read16(sp)
			sp += 2
			cycles = 3
		case 0xD2:	// JP NC,a16
			let data = read16(pc)
			pc += 2
			if !flag_c {
				pc = data
				cycles = 4
			} else {
				cycles = 3
			}
		case 0xD3:	// Illegal opcode
			cycles = 1
		case 0xD4:	// CALL NC,a16
			let data = read16(pc)
			pc += 2
			if !flag_c {
				sp -= 2
				write16(sp, pc)
				pc = data
				cycles = 6
			} else {
				cycles = 3
			}
		case 0xD5:	// PUSH DE
			sp -= 2
			write16(sp, de)
			cycles = 4
		case 0xD6:	// SUB d8
			a = (a - read8(pc)) & 0xFF
			pc += 1
			cycles = 2
		case 0xD7:	// RST 10H
			sp -= 2
			write16(sp, pc)
			pc = 0x0010
			cycles = 4
		case 0xD8:	// RET C
			if flag_c {
				pc = read16(sp)
				sp += 2
				cycles = 5
			} else {
				cycles = 2
			}
		case 0xD9:	// RETI
			pc = read16(sp)
			sp += 2
			ime = true
			cycles = 4
		case 0xDA:	// JP C,a16
			if flag_c {
				pc = read16(pc)
				cycles = 4
			} else {
				cycles = 3
			}
		case 0xDB:	// Illegal opcode
			cycles = 1
		case 0xDC:	// CALL C,a16
			let data = read16(pc)
			pc += 2
			if flag_c {
				sp -= 2
				write16(sp, pc)
				pc = data
				cycles = 6
			} else {
				cycles = 3
			}
		case 0xDD:	// Illegal opcode
			cycles = 1
		case 0xDE:	// SBC A,d8
			let cy = read8(pc) + (flag_c ? 1 : 0)
			pc += 1
			flag_h = half_carry(a, -cy)
			flag_c = carry(a, -cy)
			a = (a - cy) & 0xFF
			flag_z = (a == 0)
			flag_n = true
			cycles = 2
		case 0xDF:	// RST 18H
			sp -= 2
			write16(sp, pc)
			pc = 0x0018
			cycles = 4
		case 0xE0:	// LDH (a8),A
			let addr = 0xFF00 | read8(pc)
			pc += 1
			write8(addr, a)
			cycles = 3
		case 0xE1:	// POP HL
			hl = read16(sp)
			sp += 2
			cycles = 3
		case 0xE2:	// LD (C),A
			let addr = 0xFF00 | c
			write8(addr, a)
			cycles = 2
		case 0xE3:	// Illegal opcode
			cycles = 1
		case 0xE4:	// Illegal opcode
			cycles = 1
		case 0xE5:	// PUSH HL
			sp -= 2
			write16(sp, hl)
			cycles = 4
		case 0xE6:	// AND d8
			a &= read8(pc)
			pc += 1
			flag_z = (a == 0)
			flag_n = false
			flag_h = true
			flag_c = false
			cycles = 2
		case 0xE7:	// RST 20H
			sp -= 2
			write16(sp, pc)
			pc = 0x0020
			cycles = 4
		case 0xE8:	// ADD SP,r8
			let data = read8(pc)
			pc += 1
			flag_h = half_carry(sp, data)
			flag_c = carry(sp, data)
			sp = (sp + data) & 0xFFFF
			flag_z = false
			flag_n = false
			cycles = 4
		case 0xE9:	// JP (HL)
			pc = read16(hl)
			cycles = 1
		case 0xEA:	// LD (a16),A
			write8(read16(pc), a)
			pc += 2
			cycles = 4
		case 0xEB:	// Illegal opcode
			cycles = 1
		case 0xEC:	// Illegal opcode
			cycles = 1
		case 0xED:	// Illegal opcode
			cycles = 1
		case 0xEE:	// XOR d8
			a = a ^ read8(pc)
			pc += 1
			flag_z = (a == 0)
			flag_n = false
			flag_h = false
			flag_c = false
			cycles = 2
		case 0xEF:	// RST 28H
			sp -= 2
			write16(sp, pc)
			pc = 0x0028
			cycles = 4
		case 0xF0:	// LDH A,(a8)
			a = read8(0xFF00 | read8(pc))
			pc += 1
			cycles = 3
		case 0xF1:	// POP AF
			af = read16(sp)
			sp += 2
			cycles = 3
		case 0xF2:	// LD A,(C)
			a = read8(c)
			cycles = 2
		case 0xF3:	// DI
			ime = false
			cycles = 1
		case 0xF4:	// Illegal opcode
			cycles = 1
		case 0xF5:	// PUSH AF
			sp -= 2
			write16(sp, af)
			cycles = 4
		case 0xF6:	// OR d8
			a |= read8(pc)
			pc += 1
			flag_z = (a == 0)
			flag_n = false
			flag_h = false
			flag_c = false
			cycles = 2
		case 0xF7:	// RST 30H
			sp -= 2
			write16(sp, pc)
			pc = 0x0030
			cycles = 4
		case 0xF8:	// LD HL,SP+r8
			let data = read8(pc)
			pc += 1
			flag_h = half_carry(sp, data)
			flag_c = carry(sp, data)
			hl = (sp + data) & 0xFFFF
			flag_z = false
			flag_n = false
			cycles = 3
		case 0xF9:	// LD SP,HL
			sp = hl
			cycles = 2
		case 0xFA:	// LD A,(a16)
			a = read8(read16(pc))
			pc += 2
			cycles = 4
		case 0xFB:	// EI
			ime = true
			cycles = 1
		case 0xFC:	// Illegal operation
			cycles = 1
		case 0xFD:	// Illegal operation
			cycles = 1
		case 0xFE:	// CP d8
			let data = read8(pc)
			pc += 1
			flag_h = half_carry(a, -data)
			flag_c = carry(a, -data)
			flag_z = (a == data)
			flag_n = true
			cycles = 2
		case 0xFF:	// RST 38H
			sp -= 2
			write16(sp, pc)
			pc = 0x0038
			cycles = 4
		default:
			break
		}
		return cycles
	}
}
