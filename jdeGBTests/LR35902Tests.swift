//
//  LR35902Tests.swift
//  jdeGBTests
//
//  Created by David Ensminger on 2/17/21.
//

import XCTest
@testable import jdeGB

class LR35902Tests: XCTestCase {

	var gb: Bus!
	var sut: LR35902!
	
    override func setUpWithError() throws {
		gb = Bus()
		sut = gb.cpu
		sut.reset()
		sut.pc = 0xFF80
    }

    override func tearDownWithError() throws {
    }

	func testCE() {	// ADC A,d8
		sut.hram[0] = 0xFD	// -3
		sut.a = 0x01		//  1
		sut.flag_c = false
		
		let cycles = sut.perform_operation(opcode: 0xCE)
		
		XCTAssert(cycles == 2)
		XCTAssert(sut.a == 0xFE)
		XCTAssert(sut.flag_n == false)
		XCTAssert(sut.flag_c == false)
		XCTAssert(sut.flag_h == false)
		XCTAssert(sut.flag_z == false)		
	}
	
	func testE8() {	// ADD SP,d8
		sut.hram[0] = 0x01
		sut.pc = 0xFF80
		sut.sp = 0x000F
		
		let _ = sut.perform_operation(opcode: 0xE8)
		XCTAssert(sut.sp == 0x0010)
		XCTAssert(sut.flag_h == true)
		XCTAssert(sut.flag_c == false)
		
		
		sut.hram[0] = 0x10
		sut.pc = 0xFF80
		sut.sp = 0x00F0
		
		let _ = sut.perform_operation(opcode: 0xE8)
		XCTAssert(sut.sp == 0x0100)
		XCTAssert(sut.flag_h == false)
		XCTAssert(sut.flag_c == false)


		sut.hram[0] = 0x10
		sut.pc = 0xFF80
		sut.sp = 0x0FF0
		
		let _ = sut.perform_operation(opcode: 0xE8)
		XCTAssert(sut.sp == 0x1000)
		XCTAssert(sut.flag_h == false)
		XCTAssert(sut.flag_c == false)
	}

}
