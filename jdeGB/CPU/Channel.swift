//
//  Channel.swift
//  jdeGB
//
//  Created by David Ensminger on 2/24/21.
//

class Channelnew {
	public var timer = 0
	public var period: Float = 0
	public var frequency = 440 {
		didSet {
			period = Float(1048576 / frequency)
		}
	}
	public var freq_lohi = 0
	private var sequencer_timer = 2048
	private var sequencer_clock = 0

	public var time: Float = 0
	public let sample_rate: Int

	public var length_counter = 0
	public var length_enable = false
	
	public var volume_envelope_counter = 0
	public var volume_envelope_increase = false
	
	public var sweep_timer = 0
	public var sweep_enable = false
	public var sweep_frequency_shadow = 0
	
	public var duty = 0.5
	
	private var internal_volume = 0
	public var volume: Float {
		get {
			return Float(internal_volume)/15.0
		}
		set(v) {
			internal_volume = Int(15.0 * v)
		}
	}
	
	public var channel_enable = false
	
	public let signal: Signal
	
	public func clock() {
		if timer == 0 {
			timer = Int(period)
			output_clock()
		}
		timer -= 1
		
		sequencer_timer -= 1
		if sequencer_timer == 0 {
			sequencer_timer = 2048
			switch sequencer_clock {
			case 0, 4:
				length_clock()
			case 2, 6:
				length_clock()
				sweep_clock()
			case 7:
				volume_envelope_clock()
			default:
				break
			}
			sequencer_clock += 1
			if sequencer_clock == 8 {
				sequencer_clock = 0
			}
		}
	}
	
	private func length_clock() {
		if length_enable {
			length_counter -= 1
			if length_counter == 0 {
				internal_volume = 0
				channel_enable = false
				length_enable = false
			}
		}
	}
	
	private func sweep_clock() {
//		sweep_frequency_shadow = frequency
//		sweep_timer = 255	// ?
	}
	
	private func volume_envelope_clock() {
		if volume_envelope_counter != 0 {
			if volume_envelope_increase {
				if internal_volume + 1 <= 15 {
					internal_volume += 1
				} else {
					volume_envelope_counter = 0
				}
			} else {
				if internal_volume - 1 >= 0 {
					internal_volume -= 1
				} else {
					volume_envelope_counter = 0
				}
			}
		}
	}
	
	private func output_clock() {
	}

	init(signal: @escaping Signal, sample_rate: Int = 44100) {
		self.signal = signal
		self.sample_rate = sample_rate
	}
}

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

	public var sweep_clock_cycles = 0
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
		if sweep_clock_cycles > 0 {
			sweep_clock_cycles -= 1
			if sweep_clock_cycles == 0 && frequency > 0 {
				if sweep_increase {
					frequency += frequency/(1<<sweep_shift)
				} else {
					frequency -= frequency/(1<<sweep_shift)
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
