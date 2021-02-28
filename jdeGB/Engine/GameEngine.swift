//
//  GameEngine.swift
//  jdegb
//
//  Created by David Ensminger on 2/9/21.
//

import SpriteKit

class GameEngine: SKScene {
	static let width = 780
	static let height = 480
	static let screenSize = CGSize(width: GameEngine.width, height: GameEngine.height)

	private let node: SKSpriteNode
	private let screenNode: SKSpriteNode
	private let screenFrame: Sprite
	private let tileSets = Array(repeating: Sprite(width: 128, height: 64), count: 3)
	
	var show_cpu = false
	var show_code = false
	var show_tilesets = true
	
	var emulation_run = true
	
	let frame_duration = 1.0/60.0
	let clock_tick = 1.0/(1024.0*1024.0)
	var emulator_speed = 0.008	// 1.0 = fastest, 0.0 = slowest
	
	var gb: Bus!
	
	var keyPressed: UInt16?
	
	var mapLines: [Int:String]?
	var keys:  [Dictionary<Int, String>.Keys.Element]?

	init(file: String) {
		let screenSize = CGSize(width: GameEngine.width, height: GameEngine.height)
		node = SKSpriteNode()
		node.anchorPoint = CGPoint(x: 0, y: 0)
		node.size = screenSize
		
		screenFrame = Sprite(width: GameEngine.width, height: GameEngine.height)

		screenNode = SKSpriteNode()
		let screenWidth = 480
		let screenHeight = 432
		screenNode.anchorPoint = CGPoint(x: 0, y: 0)
		screenNode.position = CGPoint(x: 0, y: GameEngine.height - screenHeight)
		screenNode.size = CGSize(width: screenWidth, height: screenHeight)

		super.init(size: screenSize)

		scaleMode = .aspectFit

		addChild(node)
		node.addChild(screenNode)

		if let cart = Cartridge(from: file) {
			gb = Bus()
			gb.insert_cartridge(cart)
			gb.reset()

			mapLines = gb.cpu.disassemble(start: 0x0000, end: 0xFFFF)
			keys = Array(mapLines!.keys).sorted()
			
			//gb.cpu.mapLines = mapLines
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func keyDown(with event: NSEvent) {
		keyPressed = event.keyCode
		switch (event.keyCode) {
		case 126:	// up
			gb.joypad_directions |= 0b0001_0100
			gb.cpu.interrupt_request |= 0b0001_0000
		case 125:	// down
			gb.joypad_directions |= 0b0001_1000
			gb.cpu.interrupt_request |= 0b0001_0000
		case 123:	// left
			gb.joypad_directions |= 0b0001_0010
			gb.cpu.interrupt_request |= 0b0001_0000
		case 124:	// right
			gb.joypad_directions |= 0b0001_0001
			gb.cpu.interrupt_request |= 0b0001_0000
		case 6:		// z
			gb.joypad_buttons |= 0b0010_0010
			gb.cpu.interrupt_request |= 0b0001_0000
		case 7:		// x
			gb.joypad_buttons |= 0b0010_0001
			gb.cpu.interrupt_request |= 0b0001_0000
		case 36:	// enter
			gb.joypad_buttons |= 0b0010_1000
			//gb.cpu.interrupt_request |= 0b0001_0000
		case 48:	// tab
			gb.joypad_buttons |= 0b0010_0100
			gb.cpu.interrupt_request |= 0b0001_0000
		default:
			break
		}
	}
	
	override func keyUp(with event: NSEvent) {
		keyPressed = nil
		switch (event.keyCode) {
		case 126:	// up
			gb.joypad_directions &= 0b1110_1011
		case 125:	// down
			gb.joypad_directions &= 0b1110_0111
		case 123:	// left
			gb.joypad_directions &= 0b1110_1101
		case 124:	// right
			gb.joypad_directions &= 0b1110_1110
		case 6:		// z
			gb.joypad_buttons &= 0b1101_1101
		case 7:		// x
			gb.joypad_buttons &= 0b1101_1110
		case 36:	// enter
			gb.joypad_buttons &= 0b1101_0111
		case 48:	// tab
			gb.joypad_buttons &= 0b1101_1011
		default:
			break
		}
	}

	override func update(_ currentTime: TimeInterval) {
//		var cpu_time_elapsed = 0.0
		node.removeAllChildren()
		
		if emulation_run {
			update_previous_values()
			
			// The following 2 repeat...while loops will functionally do the same thing.
			// But the first version bases the 60fps on the cpu clocks and the time it should take each clock to tick on a Gameboy CPU,
			// while the second version will run at full speed until the ppu is done rendering a frame and then go to the next frame.

			// Version 1: this version will make sure the game engine runs at 60 fps, based on cpu time
//			repeat {
//				gb.clock()
//				cpu_time_elapsed += clock_tick / emulator_speed
////				if gb.cpu.pc == 0x0100 {
////					while gb.cpu.cycles > 0 {
////						gb.clock()
////					}
////					emulation_run = false
////					break
////				}
//			} while cpu_time_elapsed <= frame_duration
			
			// Version 2: this block will sync up the frames of the game engine with the frame of the emulation
			repeat {
				gb.clock()
//				if gb.cpu.pc == 0x0100 {
//					while gb.cpu.cycles > 0 {
//						gb.clock()
//					}
//					emulation_run = false
//					break
//				}
			} while gb.ppu.ly != 0 || gb.ppu.dot_count != 1
		} else {
			if keyPressed == 8 {	// C
				update_previous_values()
				repeat {
					gb.clock()
				} while gb.cpu.cycles > 0
			}
		}
		
		if keyPressed == 15 {	// r
			gb.reset()
		} else if keyPressed == 49 {	// space
			emulation_run = !emulation_run
			print(emulation_run ? "running!" : "paused")
		} else if keyPressed == 18 {	// 1
			update_previous_values()
			show_cpu = !show_cpu
		} else if keyPressed == 19 {	// 2
			show_code = !show_code
		} else if keyPressed == 20 {	// 3
			show_tilesets = !show_tilesets
		} else if keyPressed == 24 {	// + / =
			emulator_speed += 0.0005
			if emulator_speed > 1 {
				emulator_speed = 1
			}
			print("emulator_speed = \(emulator_speed)")
//			gb.apu.channel3.i += 1
//			print("i = \(gb.apu.channel3.i)")
		} else if keyPressed == 27 {	// -
			emulator_speed -= 0.0005
			if emulator_speed < 0 {
				emulator_speed = 0
			}
			print("emulator_speed = \(emulator_speed)")
//			gb.apu.channel3.i -= 1
//			if gb.apu.channel3.i < 1 { gb.apu.channel3.i = 1 }
//			print("i = \(gb.apu.channel3.i)")
		} else if keyPressed == 30 {	// ]
			emulator_speed = 1
			print("emulator_speed = \(emulator_speed)")
		} else if keyPressed == 33 {	// [
			emulator_speed = 0
			print("emulator_speed = \(emulator_speed)")
		} else if keyPressed == 2 { 	// d
			mapLines = gb.cpu.disassemble(start: 0x0000, end: 0xFFFF)
			keys = Array(mapLines!.keys).sorted()
		} else if keyPressed == 4 {
			gb.ppu.display_rendering_enabled = !gb.ppu.display_rendering_enabled
//		} else if keyPressed != nil {
//			print("\(keyPressed!) down")
		}

		drawPPUScreen()
		if show_cpu {
			draw_cpu(x: 516, y: 2)
		}
		if show_code {
			draw_code(x: 516, y: 82, lines: 26)
		}
		if show_tilesets {
			draw_tilesets(x: 516, y: 0)
		}
	
		keyPressed = nil
	}
	
	func update_previous_values() {
		p_pc = gb.cpu.pc
		p_a = gb.cpu.a
		p_bc = gb.cpu.bc
		p_de = gb.cpu.de
		p_hl = gb.cpu.hl
		p_sp = gb.cpu.sp
	}
	
	let COLOR_WHITE  = 0xFFFFFFFF
	let COLOR_GREEN  = 0xFF00FF00
	let COLOR_RED    = 0xFF0000FF
	let COLOR_CYAN   = 0xFFFFFF00
	let COLOR_YELLOW = 0xFF00FFFF

	func drawPPUScreen() {
		let f = gb.ppu.screen
		let p = Data(bytesNoCopy: f.pixels.baseAddress!, count: f.pixelCount, deallocator: .none)
		let texture = SKTexture(data: p, size: CGSize(width: f.width, height: f.height), flipped: true)
		texture.filteringMode = .nearest
		screenNode.texture = texture
		node.addChild(screenNode)
	}
	
	func draw_code(x: Int, y: Int, lines: Int) {
		guard let mapAsm = mapLines, let keys = keys else {
			return
		}
//		node.drawString(x: x, y: y, text: mapAsm[gb.cpu.pc] ?? "???")
		if let pc_i = keys.firstIndex(of: gb.cpu.pc) {
			for i in pc_i ..< pc_i + lines {
				let keys_i = (pc_i+(i-pc_i-lines/2))
				var s = ""
				if keys_i >= 0 {
					s = mapAsm[keys[keys_i]]!
				} else {
					s = ""
				}
				node.drawString(x: x, y: (i-pc_i)*10 + y, text: s, color: ((i-pc_i)==lines/2) ? COLOR_CYAN : COLOR_WHITE)
			}
		}
	}

	let hex: (Int, Int) -> String = { (n, x) in
		if x == 2 {
			return String(format: "%02X", n)
		} else if x == 4 {
			return String(format: "%04X", n)
		}
		return ""
	}

	var p_pc = 0
	var p_a = 0
	var p_bc = 0
	var p_de = 0
	var p_hl = 0
	var p_sp = 0
	func draw_cpu(x: Int, y: Int) {
		node.drawString(x: x , y: y , text: "STATUS:", color: self.COLOR_WHITE)
		node.drawString(x: x  + 64, y: y , text: "Z", color: gb.cpu.flag_z ? COLOR_GREEN : COLOR_RED)
		node.drawString(x: x  + 80, y: y , text: "N", color: gb.cpu.flag_n ? COLOR_GREEN : COLOR_RED)
		node.drawString(x: x  + 96, y: y , text: "H", color: gb.cpu.flag_h ? COLOR_GREEN : COLOR_RED)
		node.drawString(x: x  + 112, y: y , text: "C", color: gb.cpu.flag_c ? COLOR_GREEN : COLOR_RED)
		node.drawString(x: x , y: y + 10, text: "PC: $" + hex(gb.cpu.pc, 4), color: gb.cpu.pc == p_pc ? COLOR_WHITE : COLOR_YELLOW)
		node.drawString(x: x , y: y + 20, text: "A : #" +  hex(gb.cpu.a, 2) + "  [" + String(gb.cpu.a) + "]", color: gb.cpu.a == p_a ? COLOR_WHITE : COLOR_YELLOW)
		node.drawString(x: x , y: y + 30, text: "BC: #" +  hex(gb.cpu.bc, 4) + "  [" + String(gb.cpu.b) + ", " + String(gb.cpu.c) + "]", color: gb.cpu.bc == p_bc ? COLOR_WHITE : COLOR_YELLOW)
		node.drawString(x: x , y: y + 40, text: "DE: #" +  hex(gb.cpu.de, 4) + "  [" + String(gb.cpu.d) + ", " + String(gb.cpu.e) + "]", color: gb.cpu.de == p_de ? COLOR_WHITE : COLOR_YELLOW)
		node.drawString(x: x , y: y + 50, text: "HL: #" +  hex(gb.cpu.hl, 4) + "  [" + String(gb.cpu.h) + ", " + String(gb.cpu.l) + "]", color: gb.cpu.hl == p_hl ? COLOR_WHITE : COLOR_YELLOW)
		node.drawString(x: x , y: y + 60, text: "SP: $" + hex(gb.cpu.sp, 4), color: gb.cpu.sp == p_sp ? COLOR_WHITE : COLOR_YELLOW)
	}
	
	func draw_tilesets(x: Int, y: Int) {
		for i in 0..<3 {
			gb.ppu.write_tilset(i, to: tileSets[i])
			let f = tileSets[i]
			let pattern = SKSpriteNode()
			pattern.anchorPoint = CGPoint(x: 0, y: 0)
			if i < 2 {
				pattern.position = CGPoint(x: x + f.width*i + (i == 1 ? 10 : 0), y: y + f.height + 10)
			} else {
				pattern.position = CGPoint(x: x, y: y)
			}
			pattern.size = CGSize(width: f.width, height: f.height)
			let p = Data(bytesNoCopy: f.pixels.baseAddress!, count: f.pixelCount, deallocator: .none)
			let texture = SKTexture(data: p, size: CGSize(width: f.width, height: f.height), flipped: true)
			texture.filteringMode = .nearest
			pattern.texture = texture
			node.addChild(pattern)
		}

	}



}

extension SKSpriteNode {
	func drawString(x: Int, y: Int, text: String, color: Int = 0xFFFFFFFF, fontName: String = "Press Start K", fontSize: CGFloat = 8) {
		let textNode = SKLabelNode(text: text)
		textNode.fontName = fontName
		textNode.fontSize = fontSize
		textNode.fontColor = NSColor(red: CGFloat((color & 0x000000FF))/255.0, green: CGFloat((color & 0x0000FF00) >> 8)/255.0, blue: CGFloat((color & 0x00FF0000) >> 16)/255.0, alpha: CGFloat((color & 0xFF000000) >> 24)/255.0)
		textNode.horizontalAlignmentMode = .left
		textNode.position = CGPoint(x: x, y: (Int(size.height) - y - Int(fontSize)))
		addChild(textNode)
	}
}
