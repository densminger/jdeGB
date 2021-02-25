//
//  Channel.swift
//  jdeGB
//
//  Created by David Ensminger on 2/24/21.
//

class Channel {
	public let sample_rate: Int
	public var frequency: Int = 440 {
		didSet {
			period = 1 / Float(frequency)
		}
	}
	public var NR13_14: Int = 0
	
	public var time: Float = 0
	public var period = Float(1.0/440.0)
	public var volume: Float = 0

	public var sweep_time = 0
	public var sweep_increase = true
	public var sweep_shift = 0
	
	public var sound_length = 0
	public var sound_length_active = false
	
	public var signal: Signal
	
	public var duty: Double {
		get {
			return Oscillator.duty
		}
		set(v) {
			Oscillator.duty = v
		}
	}
	
	private var clock_count = 0
	
	public func update() {
		if sweep_time > 0 {
			var sweep_clock = 0
			sweep_clock = sweep_time * sample_rate / 128
			if clock_count % sweep_clock == 0 {
				if frequency > 0 {
					if sweep_increase {
					frequency += frequency/(1<<sweep_shift)
					} else {
						frequency -= frequency/(1<<sweep_shift)
					}
				}
			}
		}
		if sound_length_active {
			sound_length -= 1
			if sound_length == 0 {
				volume = 0
				sound_length_active = false
			}
		}
		clock_count += 1
	}
	
	init(signal: @escaping Signal, sample_rate: Int = 44100) {
		self.signal = signal
		self.sample_rate = sample_rate
	}

}
