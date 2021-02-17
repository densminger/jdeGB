//
//  LR35902+Disassemble.swift
//  jdeGB
//
//  Created by David Ensminger on 2/16/21.
//

extension LR35902 {
	private var hex: (Int, Int) -> String {
		get {
			{ (n, x) in
				if x == 2 {
					return String(format: "%02X", n)
				} else if x == 4 {
					return String(format: "%04X", n)
				}
				return ""
			}
		}
	}

	func disassemble(start: Int, end: Int) -> [Int:String] {
		var mapLines = [Int:String]()
		var addr = start
		
		while addr <= end {
			let line_addr = addr
			var inst = "$" + hex(addr, 4) + ": "
			let opcode = read8(addr)
			addr += 1

			switch opcode {
			case 0x00:
				inst += "NOP"
			case 0x01:
				inst += "LD BC, #\(hex(read16(addr), 4))"
				addr += 2
			case 0x02:
				inst += "LD (BC), A"
			case 0x03:
				inst += "INC BC"
			case 0x04:
				inst += "INC B"
			case 0x05:
				inst += "DEC B"
			case 0x06:
				inst += "LD B, #\(hex(read8(addr), 2))"
				addr += 1
			case 0x07:
				inst += "RLCA"
			case 0x08:
				inst += "LD $\(hex(read16(addr), 4)), SP"
				addr += 2
			case 0x09:
				inst += "ADD HL, BC"
			case 0x0A:
				inst += "LD A, (BC)"
			case 0x0B:
				inst += "DEC BC"
			case 0x0C:
				inst += "INC C"
			case 0x0D:
				inst += "DEC C"
			case 0x0E:
				inst += "LD C, #\(hex(read8(addr), 2))"
				addr += 1
			case 0x0F:
				inst += "RRCA"
			case 0x10:
				inst += "STOP 0"
			case 0x11:
				inst += "LD DE, #\(hex(read16(addr), 4))"
				addr += 2
			case 0x12:
				inst += "LD (DE), A"
			case 0x13:
				inst += "INC DE"
			case 0x14:
				inst += "INC D"
			case 0x15:
				inst += "DEC D"
			case 0x16:
				inst += "LD D, #\(hex(read8(addr), 2))"
				addr += 1
			case 0x17:
				inst += "RLA"
			case 0x18:
				var d = read8(addr)
				addr += 1
				if d & 0x80 > 0 {
					d -= 256
				}
				inst += "JR #\(hex(d & 0xFF, 2)) [$\(hex(addr + d, 4))]"
			case 0x19:
				inst += "ADD HL, DE"
			case 0x1A:
				inst += "LD A, (DE)"
			case 0x1B:
				inst += "DEC DE"
			case 0x1C:
				inst += "INC E"
			case 0x1D:
				inst += "DEC E"
			case 0x1E:
				inst += "LD E, #\(hex(read8(addr), 2))"
				addr += 1
			case 0x1F:
				inst += "RRA"
			case 0x20:
				var d = read8(addr)
				addr += 1
				if d & 0x80 > 0 {
					d -= 256
				}
				inst += "JR NZ, #\(hex(d & 0xFF, 2)) [$\(hex(addr + d, 4))]"
			case 0x21:
				inst += "LD HL, #\(hex(read16(addr), 4))"
				addr += 2
			case 0x22:
				inst += "LD (HL+), A"
			case 0x23:
				inst += "INC HL"
			case 0x24:
				inst += "INC H"
			case 0x25:
				inst += "DEC H"
			case 0x26:
				inst += "LD H, #\(hex(read8(addr), 2))"
				addr += 1
			case 0x27:
				inst += "DAA"
			case 0x28:
				var d = read8(addr)
				addr += 1
				if d & 0x80 > 0 {
					d -= 256
				}
				inst += "JR Z, #\(hex(d & 0xFF, 2)) [$\(hex(addr + d, 4))]"
			case 0x29:
				inst += "ADD HL, HL"
			case 0x2A:
				inst += "LD A, (HL+)"
			case 0x2B:
				inst += "DEC HL"
			case 0x2C:
				inst += "INC L"
			case 0x2D:
				inst += "DEC L"
			case 0x2E:
				inst += "LD L, #\(hex(read8(addr), 2))"
				addr += 1
			case 0x2F:
				inst += "CPL"
			case 0x30:
				var d = read8(addr)
				addr += 1
				if d & 0x80 > 0 {
					d -= 256
				}
				inst += "JR NC, #\(hex(d & 0xFF, 2)) [$\(hex(addr + d, 4))]"
			case 0x31:
				inst += "LD SP, #\(hex(read16(addr), 4))"
				addr += 2
			case 0x32:
				inst += "LD (HL-), A"
			case 0x33:
				inst += "INC SP"
			case 0x34:
				inst += "INC (HL)"
			case 0x35:
				inst += "DEC (HL)"
			case 0x36:
				inst += "LD (HL), #\(hex(read8(addr), 2))"
				addr += 1
			case 0x37:
				inst += "SCF"
			case 0x38:
				var d = read8(addr)
				addr += 1
				if d & 0x80 > 0 {
					d -= 256
				}
				inst += "JR C, #\(hex(d & 0xFF, 2)) [$\(hex(addr + d, 4))]"
			case 0x39:
				inst += "ADD HL, SP"
			case 0x3A:
				inst += "LD A, (HL-)"
			case 0x3B:
				inst += "DEC SP"
			case 0x3C:
				inst += "INC A"
			case 0x3D:
				inst += "DEC A"
			case 0x3E:
				inst += "LD A, #\(hex(read8(addr), 2))"
				addr += 1
			case 0x3F:
				inst += "CCF"
			case 0x40:
				inst += "LD B, B"
			case 0x41:
				inst += "LD B, C"
			case 0x42:
				inst += "LD B, D"
			case 0x43:
				inst += "LD B, E"
			case 0x44:
				inst += "LD B, H"
			case 0x45:
				inst += "LD B, L"
			case 0x46:
				inst += "LD B, (HL)"
			case 0x47:
				inst += "LD B, A"
			case 0x48:
				inst += "LD C, B"
			case 0x49:
				inst += "LD C, C"
			case 0x4A:
				inst += "LD C, D"
			case 0x4B:
				inst += "LD C, E"
			case 0x4C:
				inst += "LD C, H"
			case 0x4D:
				inst += "LD C, L"
			case 0x4E:
				inst += "LD C, (HL)"
			case 0x4F:
				inst += "LD C, A"
			case 0x50:
				inst += "LD D, B"
			case 0x51:
				inst += "LD D, C"
			case 0x52:
				inst += "LD D, D"
			case 0x53:
				inst += "LD D, E"
			case 0x54:
				inst += "LD D, H"
			case 0x55:
				inst += "LD D, L"
			case 0x56:
				inst += "LD D, (HL)"
			case 0x57:
				inst += "LD D, A"
			case 0x58:
				inst += "LD E, B"
			case 0x59:
				inst += "LD E, C"
			case 0x5A:
				inst += "LD E, D"
			case 0x5B:
				inst += "LD E, E"
			case 0x5C:
				inst += "LD E, H"
			case 0x5D:
				inst += "LD E, L"
			case 0x5E:
				inst += "LD E, (HL)"
			case 0x5F:
				inst += "LD E, A"
			case 0x60:
				inst += "LD H, B"
			case 0x61:
				inst += "LD H, C"
			case 0x62:
				inst += "LD H, D"
			case 0x63:
				inst += "LD H, E"
			case 0x64:
				inst += "LD H, H"
			case 0x65:
				inst += "LD H, L"
			case 0x66:
				inst += "LD H, (HL)"
			case 0x67:
				inst += "LD H, A"
			case 0x68:
				inst += "LD L, B"
			case 0x69:
				inst += "LD L, C"
			case 0x6A:
				inst += "LD L, D"
			case 0x6B:
				inst += "LD L, E"
			case 0x6C:
				inst += "LD L, H"
			case 0x6D:
				inst += "LD L, L"
			case 0x6E:
				inst += "LD L, (HL)"
			case 0x6F:
				inst += "LD B, A"
			case 0x70:
				inst += "LD (HL), B"
			case 0x71:
				inst += "LD (HL), C"
			case 0x72:
				inst += "LD (HL), D"
			case 0x73:
				inst += "LD (HL), E"
			case 0x74:
				inst += "LD (HL), H"
			case 0x75:
				inst += "LD (HL), L"
			case 0x76:
				inst += "HALT"
			case 0x77:
				inst += "LD (HL), A"
			case 0x78:
				inst += "LD A, B"
			case 0x79:
				inst += "LD A, C"
			case 0x7A:
				inst += "LD A, D"
			case 0x7B:
				inst += "LD A, E"
			case 0x7C:
				inst += "LD A, H"
			case 0x7D:
				inst += "LD A, L"
			case 0x7E:
				inst += "LD A, (HL)"
			case 0x7F:
				inst += "LD A, A"
			case 0x80:
				inst += "ADD A, B"
			case 0x81:
				inst += "ADD A, C"
			case 0x82:
				inst += "ADD A, D"
			case 0x83:
				inst += "ADD A, E"
			case 0x84:
				inst += "ADD A, H"
			case 0x85:
				inst += "ADD A, L"
			case 0x86:
				inst += "ADD A, (HL)"
			case 0x87:
				inst += "ADD A, A"
			case 0x88:
				inst += "ADC A, B"
			case 0x89:
				inst += "ADC A, C"
			case 0x8A:
				inst += "ADC A, D"
			case 0x8B:
				inst += "ADC A, E"
			case 0x8C:
				inst += "ADC A, H"
			case 0x8D:
				inst += "ADC A, L"
			case 0x8E:
				inst += "ADC A, (HL)"
			case 0x8F:
				inst += "ADC A, A"
			case 0x90:
				inst += "SUB B"
			case 0x91:
				inst += "SUB C"
			case 0x92:
				inst += "SUB D"
			case 0x93:
				inst += "SUB E"
			case 0x94:
				inst += "SUB H"
			case 0x95:
				inst += "SUB L"
			case 0x96:
				inst += "SUB (HL)"
			case 0x97:
				inst += "SUB A"
			case 0x98:
				inst += "SBC A, B"
			case 0x99:
				inst += "SBC A, C"
			case 0x9A:
				inst += "SBC A, D"
			case 0x9B:
				inst += "SBC A, E"
			case 0x9C:
				inst += "SBC A, H"
			case 0x9D:
				inst += "SBC A, L"
			case 0x9E:
				inst += "SBC A, (HL)"
			case 0x9F:
				inst += "SBC A, A"
			case 0xA0:
				inst += "AND B"
			case 0xA1:
				inst += "AND C"
			case 0xA2:
				inst += "AND D"
			case 0xA3:
				inst += "AND E"
			case 0xA4:
				inst += "AND H"
			case 0xA5:
				inst += "AND L"
			case 0xA6:
				inst += "AND (HL)"
			case 0xA7:
				inst += "AND A"
			case 0xA8:
				inst += "XOR B"
			case 0xA9:
				inst += "XOR C"
			case 0xAA:
				inst += "XOR D"
			case 0xAB:
				inst += "XOR E"
			case 0xAC:
				inst += "XOR H"
			case 0xAD:
				inst += "XOR L"
			case 0xAE:
				inst += "XOR (HL)"
			case 0xAF:
				inst += "XOR A"
			case 0xB0:
				inst += "OR B"
			case 0xB1:
				inst += "OR C"
			case 0xB2:
				inst += "OR D"
			case 0xB3:
				inst += "OR E"
			case 0xB4:
				inst += "OR H"
			case 0xB5:
				inst += "OR L"
			case 0xB6:
				inst += "OR (HL)"
			case 0xB7:
				inst += "OR A"
			case 0xB8:
				inst += "CP B"
			case 0xB9:
				inst += "CP C"
			case 0xBA:
				inst += "CP D"
			case 0xBB:
				inst += "CP E"
			case 0xBC:
				inst += "CP H"
			case 0xBD:
				inst += "CP L"
			case 0xBE:
				inst += "CP (HL)"
			case 0xBF:
				inst += "CP A"
			case 0xC0:
				inst += "RET NZ"
			case 0xC1:
				inst += "POP BC"
			case 0xC2:
				inst += "JP NZ, $\(hex(read16(addr), 4))"
				addr += 2
			case 0xC3:
				inst += "JP $\(hex(read16(addr), 4))"
				addr += 2
			case 0xC4:
				inst += "CALL NZ, $\(hex(read16(addr), 4))"
				addr += 2
			case 0xC5:
				inst += "PUSH BC"
			case 0xC6:
				inst += "ADD A, #\(hex(read8(addr), 2))"
				addr += 1
			case 0xC7:
				inst += "RST 00H"
			case 0xC8:
				inst += "RET Z"
			case 0xC9:
				inst += "RET"
			case 0xCA:
				inst += "JP Z, $\(hex(read16(addr), 4))"
				addr += 2
			case 0xCB:
				let cb_opcode = read8(addr)
				addr += 1
				inst += "PREFIX CB [\(disassemble_cb(cb_opcode))]"
			case 0xCC:
				inst += "CALL Z, $\(hex(read16(addr), 4))"
				addr += 2
			case 0xCD:
				inst += "CALL $\(hex(read16(addr), 4))"
				addr += 2
			case 0xCE:
				inst += "ADC A, #\(hex(read8(addr), 2))"
				addr += 1
			case 0xCF:
				inst += "RST 08H"
			case 0xD0:
				inst += "RET NC"
			case 0xD1:
				inst += "POP DE"
			case 0xD2:
				inst += "JP NC, $\(hex(read16(addr), 4))"
				addr += 2
			case 0xD3:
				inst += "??? (D3)"
			case 0xD4:
				inst += "CALL NC, $\(hex(read16(addr), 4))"
				addr += 2
			case 0xD5:
				inst += "PUSH DE"
			case 0xD6:
				inst += "SUB #\(hex(read8(addr), 2))"
				addr += 1
			case 0xD7:
				inst += "RST 10H"
			case 0xD8:
				inst += "RET C"
			case 0xD9:
				inst += "RETI"
			case 0xDA:
				inst += "JP C, $\(hex(read16(addr), 4))"
				addr += 2
			case 0xDB:
				inst += "??? (DB)"
			case 0xDC:
				inst += "CALL C, $\(hex(read16(addr), 4))"
				addr += 2
			case 0xDD:
				inst += "??? (DD)"
			case 0xDE:
				inst += "SBC A, #\(hex(read8(addr), 2))"
				addr += 1
			case 0xDF:
				inst += "RST 18H"
			case 0xE0:
				inst += "LDH $FF\(hex(read8(addr), 2)), A"
				addr += 1
			case 0xE1:
				inst += "POP HL"
			case 0xE2:
				inst += "LD (C), A"
			case 0xE3:
				inst += "??? (E3)"
			case 0xE4:
				inst += "??? (E4)"
			case 0xE5:
				inst += "PUSH HL"
			case 0xE6:
				inst += "AND #\(hex(read8(addr), 2))"
				addr += 1
			case 0xE7:
				inst += "RST 20H"
			case 0xE8:
				inst += "ADD SP, #\(hex(read8(addr), 2))"
				addr += 1
			case 0xE9:
				inst += "JP (HL)"
			case 0xEA:
				inst += "LD $\(hex(read16(addr), 4)), A"
				addr += 2
			case 0xEB:
				inst += "??? (EB)"
			case 0xEC:
				inst += "??? (EC)"
			case 0xED:
				inst += "??? (ED)"
			case 0xEE:
				inst += "XOR #\(hex(read8(addr), 2))"
				addr += 1
			case 0xEF:
				inst += "RST 28H"
			case 0xF0:
				inst += "LDH A, $FF\(hex(read8(addr), 2))"
				addr += 1
			case 0xF1:
				inst += "POP AF"
			case 0xF2:
				inst += "LD A, (C)"
			case 0xF3:
				inst += "DI"
			case 0xF4:
				inst += "??? (F4)"
			case 0xF5:
				inst += "PUSH AF"
			case 0xF6:
				inst += "OR #\(hex(read8(addr), 2))"
				addr += 1
			case 0xF7:
				inst += "RST 30H"
			case 0xF8:
				inst += "LD HL, SP + #\(hex(read8(addr), 2))"
				addr += 1
			case 0xF9:
				inst += "LD SP, HL"
			case 0xFA:
				inst += "LD A, $\(hex(read16(addr), 4))"
				addr += 2
			case 0xFB:
				inst += "EI"
			case 0xFC:
				inst += "??? (FC)"
			case 0xFD:
				inst += "??? (FD)"
			case 0xFE:
				inst += "CP #\(hex(read8(addr), 2))"
				addr += 1
			case 0xFF:
				inst += "RST 38H"
			default:
				inst += "??? (overflow: \(opcode))"
			}
			
			mapLines[line_addr] = inst
		}
		
		return mapLines
	}
	
	private func disassemble_cb(_ cb_opcode: Int) -> String {
		var inst = ""
		switch (cb_opcode) {
		case 0x7C:
			inst += "BIT 7, H"
		default:
			inst += "??? (overflow: \(cb_opcode))"
		}
		return inst
	}
}
