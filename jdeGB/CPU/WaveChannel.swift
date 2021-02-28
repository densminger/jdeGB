//
//  WaveChannel.swift
//  jdeGB
//
//  Created by David Ensminger on 2/27/21.
//

import AVFoundation

class WaveChannel {
	public var channel_enable = true

	var volume: Int = 15
	public var volume_restart_value = 0

	private var sequencer_timer = 2048
	private var sequencer_clock = 0

	public var length_counter = 0
	public var length_enable = false
	
	private var period = 0
	private var period_timer = 0
	public var frequency = 440 {
		didSet {
			if frequency == 0 { frequency = 1 }
			period = 2*(2048-frequency)
			period_timer = period
		}
	}
	public var freq_lohi = 0
	
	private var clock_counter = 0
	
	public var pattern = Array(repeating: 0, count: 16)
	private var pattern_count = 0	// which 4-bit pattern should be output next

	func sample() -> Float {
		var d = pattern[pattern_count / 2]
		if pattern_count % 2 == 0 {
			d = (d & 0xF0) >> 4
		} else {
			d = (d & 0x0F)
		}
		return Float(d) * (Float(volume) / 15.0)
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
			case 0, 2, 4, 6:
				length_clock()
			default:
				break
			}
			sequencer_clock += 1
			if sequencer_clock == 8 {
				sequencer_clock = 0
			}
		}
		
		period_timer -= 1
		if period_timer == 0 {
			period_timer = period
			increase_pattern_count()
		}
		
		clock_counter += 1
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
	
	func increase_pattern_count() {
		pattern_count = (pattern_count + 1) % 32
	}
}
