//
//  LR35902+AddressingModes.swift
//  jdeGB
//
//  Created by David Ensminger on 2/12/21.
//

extension LR35902 {
	func IMP() {
		return
	}
	
	func IMPA() {
		fetched = a
		return
	}
	
	func IMPB() {
		fetched = b
		return
	}
	
	func IMPC() {
		fetched = c
		return
	}
	
	func IMPD() {
		fetched = d
		return
	}
	
	func IMPE() {
		fetched = e
		return
	}
	
	func IMPH() {
		fetched = h
		return
	}
	
	func IMPL() {
		fetched = l
		return
	}
	
	func IMPBC() {
		fetched = bc
		return
	}
	
	func IMPDE() {
		fetched = de
		return
	}
	
	func IMPHL() {
		fetched = hl
		return
	}
	
	func IMM8() {
		fetched = read8(pc)
		pc += 1
	}
	
	func IMM16() {
		fetched = read16(pc)
		pc += 2
	}
}
