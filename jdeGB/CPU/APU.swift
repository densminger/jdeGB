//
//  APU.swift
//  jdeGB
//
//  Created by David Ensminger on 2/24/21.
//

import AVFoundation

class APU {
	public let channel1 = SquareChannel()
	public let channel2 = SquareChannel()
	public let channel3 = WaveChannel()
	public let channel4 = NoiseChannel()
	
	public var volume: Float {
		set {
			audioEngine.mainMixerNode.outputVolume = newValue
		}
		get {
			audioEngine.mainMixerNode.outputVolume
		}
	}

	private var audioEngine: AVAudioEngine
	private lazy var sourceNode = AVAudioSourceNode { _, _, frameCount, audioBufferList in
		if !self.sound_enable { return noErr }
		let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)

		for frame in 0..<Int(frameCount) {
			var sampleVal: Float = 0
			sampleVal += self.channel1.sample()
			sampleVal += self.channel2.sample()
			//sampleVal += self.channel3.sample()
			sampleVal += self.channel4.sample()
			self.channel1.incrementTime(delta: self.deltaTime)
			self.channel2.incrementTime(delta: self.deltaTime)
			self.channel3.incrementTime(delta: self.deltaTime)
			self.channel4.incrementTime(delta: self.deltaTime)

			for buffer in ablPointer {
				let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
				buf[frame] = sampleVal
			}
		}

		return noErr
	}
	
	private let sampleRate: Double
	private let deltaTime: Float
	
	public var sound_enable = true

	init() {
		audioEngine = AVAudioEngine()
		
		let mainMixer = audioEngine.mainMixerNode
		let outputNode = audioEngine.outputNode
		let format = outputNode.inputFormat(forBus: 0)
		
		sampleRate = format.sampleRate
		deltaTime = 1 / Float(sampleRate)

		let inputFormat = AVAudioFormat(commonFormat: format.commonFormat,
										sampleRate: format.sampleRate,
										channels: 1,
										interleaved: format.isInterleaved)
		
		audioEngine.attach(sourceNode)
		audioEngine.connect(sourceNode, to: mainMixer, format: inputFormat)
		audioEngine.connect(mainMixer, to: outputNode, format: nil)
		mainMixer.outputVolume = 0.5
		
		self.channel1.duty = 0.0
		self.channel2.duty = 0.0

		do {
			try audioEngine.start()
		} catch {
			print("Could not start engine: \(error.localizedDescription)")
		}
		
	}
	
	public func clock() {
		channel1.clock()
		channel2.clock()
		channel3.clock()
		channel4.clock()
	}
}
