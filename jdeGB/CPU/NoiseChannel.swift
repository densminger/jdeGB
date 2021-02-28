//
//  NoiseChannel.swift
//  jdeGB
//
//  Created by David Ensminger on 2/26/21.
//

class NoiseChannel {
	var lsfr: Int
	var clock_frequency = 0
	var clock_frequency_restart_value = 0
	var lsfr_short = false
	var shift_clock_frequency = 0 {
		didSet {
			calculate_clock_frequency()
		}
	}
	var dividing_ratio = 0 {
		didSet {
			calculate_clock_frequency()
		}
	}
	var clock_count = 0
	
	public var channel_enable = true

	var volume: Int = 15
	public var volume_restart_value = 0

	private var sequencer_timer = 2048
	private var sequencer_clock = 0

	public var volume_envelope_counter = 0
	public var volume_envelope_counter_restart_value = 0
	public var volume_envelope_increase = false

	public var length_counter = 0
	public var length_enable = false
	
	func calculate_clock_frequency() {
		let div = (dividing_ratio == 0) ? 0.5 : Double(dividing_ratio)
		clock_frequency = 44100/(Int(524288.0 / div) >> (shift_clock_frequency+1))
		clock_frequency_restart_value = clock_frequency
	}
	
	func sample() -> Float {
		clock_frequency -= 1
		if clock_frequency <= 0 {
			clock_frequency = clock_frequency_restart_value
			shift_lsfr()
		}
		return (lsfr & 0b0001) > 0 ? 0 : Float(volume)
	}
	
	func incrementTime(delta: Float) {
		
	}
	
	func clock() {
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
		clock_count += 1
	}
	
	func length_clock() {
		if length_enable {
			length_counter -= 1
			if length_counter <= 0 {
				volume = 0
				length_enable = false
			}
		}
	}
	
	func volume_envelope_clock() {
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
	
	func shift_lsfr() {
		let xor = (lsfr & 0b0001) ^ ((lsfr & 0b0010) >> 1)
		lsfr >>= 1
		lsfr |= (xor << 14)
		if lsfr_short {
			lsfr &= 0b0111_1111_1011_1111
			lsfr |= (xor << 6)
		}
	}
	
	init(lsfrSeed: Int = 0x4E0C) {
		lsfr = lsfrSeed
	}
	
}
