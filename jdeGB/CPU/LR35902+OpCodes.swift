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
	func operate(opcode: Int) -> Int {
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
			b = (bc - 1) & 0xFFFF
			flag_z = (b == 0)
			flag_n = true
			cycles = 1
		case 0x06:	// LD B,d8
			b = read8(pc)
			pc += 1
			cycles = 2
		case 0x07:	// RLCA
			flag_c = (a & 0x80) > 0
			a <<= 1
			if flag_c {
				a |= 0x01
			}
			flag_z = false
			flag_n = false
			flag_h = false
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
			flag_c = (a & 0x01) > 0
			a >>= 1
			if flag_c {
				a |= 0x08
			}
			flag_z = false
			flag_n = false
			flag_h = false
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
			flag_c = (a & 0x80) > 0
			a <<= 1
			if flag_c {
				a |= 0x01
			}
			flag_z = false
			flag_n = false
			flag_h = false
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
			flag_c = (a & 0x01) > 0
			a >>= 1
			if flag_c {
				a |= 0x80
			}
			flag_z = false
			flag_n = false
			flag_h = false
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
		default:
			break
		}
		return cycles
	}
}
