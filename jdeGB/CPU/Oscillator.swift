//
//  Oscillator.swift
//  Swift Synth
//
//  Created by Grant Emerson on 7/21/19.
//  Copyright © 2019 Grant Emerson. All rights reserved.
//

import Foundation

typealias Signal = (_ frequency: Float, _ time: Float) -> Float

enum Waveform: Int {
    case sine, triangle, sawtooth, square, whiteNoise
}

struct Oscillator {
    
    static var amplitude: Float = 1
	static var duty: Double = 0.5
    
    static let sine: Signal = { frequency, time in
        return Oscillator.amplitude * sin(2.0 * Float.pi * frequency * time)
    }
    
    static let triangle: Signal = { frequency, time in
        let period = 1.0 / Double(frequency)
        let currentTime = fmod(Double(time), period)
        
        let value = currentTime / period
        
        var result = 0.0
        if value < 0.25 {
            result = value * 4
        } else if value < 0.75 {
            result = 2.0 - (value * 4.0)
        } else {
            result = value * 4 - 4.0
        }
        
        return Oscillator.amplitude * Float(result)
    }

    static let sawtooth: Signal = { frequency, time in
        let period = 1.0 / frequency
        let currentTime = fmod(Double(time), Double(period))
        return Oscillator.amplitude * ((Float(currentTime) / period) * 2 - 1.0)
    }
    
    static let square_sin: Signal = { frequency, time in
		let harmonics = 20
		var a: Float = 0
		var b: Float = 0
		let p: Float = Float(duty) * 2.0 * 3.14159265358979;
		
		func approxsin(_ t: Float) -> Float {
			var j = t * 0.15915
			j = j - j.rounded(.down)
			return 20.785 * j * (j-0.5) * (j-1.0)
		}
		
		for n in 1..<harmonics {
			let c = Float(n) * frequency * 2.0 * 3.14159265358979 * time
			a += -approxsin(c) / Float(n)
			b += -approxsin(c - p * Float(n)) / Float(n)
		}
		
		return Float((2.0 / 3.14159265358979) * (a - b))
	}
    
	static let square: Signal = { frequency, time in
		let period = 1.0 / Double(frequency)
		let currentTime = fmod(Double(time), period)
		return ((currentTime / period) < 0.5) ? Oscillator.amplitude : -1.0 * Oscillator.amplitude
	}
	
    static let whiteNoise: Signal = { frequency, time in
        return Oscillator.amplitude * Float.random(in: -1...1)
    }
}
