//
//  Channel.swift
//  jdeGB
//
//  Created by David Ensminger on 2/24/21.
//

class Channel {
	public var time: Float = 0
	public var period: Float = 1
	public var frequency = 440 {
		willSet {
			old_frequency = frequency
		}
		didSet {
			if frequency == 0 { frequency = 1 }
			period = 1 / Float(frequency)
		}
	}
	public var old_frequency = 440
	public var freq_lohi = 0
	private var sequencer_timer = 2048
	private var sequencer_clock = 0

	public let sample_rate: Int

	public var length_counter = 0
	public var length_enable = false
	
	public var volume_envelope_counter = 0
	public var volume_envelope_counter_restart_value = 0
	public var volume_envelope_increase = false
	
	public var sweep_timer = 0 {
		didSet {
			sweep_reload = sweep_timer
		}
	}
	private var sweep_reload = 0
	public var sweep_enable = false
	public var sweep_frequency_shadow = 0
	public var sweep_shift = 0
	public var sweep_increase = true
	
	public var duty = 0.5
	
	public var volume = 0
	public var volume_restart_value = 0
	
	public var channel_enable = true
	
	public let signal: Signal
	
	public func clock() {
		if !channel_enable {
			return
		}
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
			if length_counter <= 0 {
				volume = 0
				channel_enable = false
				length_enable = false
			}
		}
	}
	
//	var add = 1
	private func sweep_clock() {
//		duty = 0.5
//		volume = 1
//		frequency += add
//		if frequency > 880 || frequency < 220 { add *= -1 }
//		return
		if !sweep_enable {
			return
		}
		sweep_timer -= 1
		if sweep_timer <= 0 {
			sweep_trigger()
		}
	}
	
	public func sweep_trigger() {
		sweep_timer = sweep_reload
		sweep_enable = sweep_shift != 0
		sweep_frequency_shadow = frequency
		if sweep_increase {
			sweep_frequency_shadow += (frequency >> sweep_shift)
		} else {
			sweep_frequency_shadow -= (frequency >> sweep_shift)
		}
		if sweep_frequency_shadow > 2047 {
			sweep_frequency_shadow -= 2048
			sweep_enable = false
		}
		frequency = sweep_frequency_shadow
	}
	
	private func volume_envelope_clock() {
		if volume_envelope_counter_restart_value == 0 {
			return
		}
		volume_envelope_counter -= 1
		if volume_envelope_counter == 0 {
			volume_envelope_counter = volume_envelope_counter_restart_value
			if volume_envelope_increase {
				volume += 1
			} else {
				volume -= 1
			}
			if volume < 0 || volume > 15 {
				volume = max(min(volume, 15), 0)
				volume_envelope_counter = 0
				volume_envelope_counter_restart_value = 0
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
