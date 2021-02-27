//
//  Channel.swift
//  jdeGB
//
//  Created by David Ensminger on 2/27/21.
//

protocol Channel {
	var volume: Int { get set }
	func sample() -> Float
	func incrementTime(delta: Float)
	func clock()
}
