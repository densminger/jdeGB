//
//  Channel.swift
//  jdeGB
//
//  Created by David Ensminger on 2/24/21.
//

class Channel {
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
