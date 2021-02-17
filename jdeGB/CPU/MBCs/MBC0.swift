//
//  MBC0.swift
//  jdeGB
//
//  Created by David Ensminger on 2/16/21.
//

// This is for cartridges with "No MBC"
class MBC0: MBC {
	override func mapped_addr(addr: Int) -> Int {
		return addr
	}
}
