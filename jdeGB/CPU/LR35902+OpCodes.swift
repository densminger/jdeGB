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
			let data = read16(pc)
			pc += 2
			bc = data
			cycles = 3
			break
		case 0x02:	// LD (BC),A
			write8(bc, a)
			cycles = 2
		case 0x03:	// INC BC
			bc += 1
			cycles = 2
		case 0x04:	// INC B
			flag_h = half_carry(b, 1)
			b += 1
			flag_z = (b == 0)
			flag_n = false
			cycles = 1
		case 0x05:	// DEC B
			flag_h = half_carry(b, -1)
			b -= 1
			flag_z = (b == 0)
			flag_n = true
			cycles = 1
		case 0x06:	// LD B,d8
			let data = read8(pc)
			pc += 1
			b = data
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
			let data = read16(pc)
			pc += 2
			write16(data, sp)
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
			bc -= 1
			cycles = 2
		case 0x0C:	// INC C
			flag_h = half_carry(c, 1)
			c += 1
			flag_z = (c == 0)
			flag_n = false
			cycles = 1
		case 0x0D:	// DEC C
			flag_h = half_carry(c, -1)
			c -= 1
			flag_z = (c == 0)
			flag_n = true
			cycles = 1
		case 0x0E:	// LD C,d8
			let data = read8(pc)
			pc += 1
			c = data
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
			cycles = 2
		case 0x11:	// LD DE,d16
			let data = read16(pc)
			pc += 2
			de = data
			cycles = 4
		case 0x12:	// LD (DE),A
			write8(de, a)
			cycles = 2
		case 0x13:	// INC DE
			de += 1
			cycles = 2
		case 0x14:	// INC D
			flag_h = half_carry(d, 1)
			d += 1
			flag_z = (d == 0)
			flag_n = false
			cycles = 1
		case 0x15:	// DEC D
			flag_h = half_carry(d, -1)
			d -= 1
			flag_z = (d == 0)
			flag_n = true
			cycles = 1
		case 0x16:	// LD D,d8
			let data = read8(pc)
			pc += 1
			d += data
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
			cycles = 2
		case 0x18:	// JR r8
			let data = read8(pc)
			pc += 1
			if data & 0x80 > 0 {
				data = data - 256
			}
			pc += data
			cycles = 3
		case 0x19:	// ADD HL,DE
			flag_h = half_carry(hl, de)
			flag_c = carry(hl, de)
			hl += de
			flag_n = false
			cycles = 2
		case 0x1A:	// LD A,(DE)
			let data = read8(de)
			a = data
			cycles = 2
		default:
			break
		}
		return cycles
	}
}
