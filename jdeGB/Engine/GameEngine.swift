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
	
	var show_cpu = false
	var show_code = false
	
	var emulation_run = false
	
	var gb: Bus!
	
	var keyPressed: UInt16?
	
	var mapLigb: [Int:String]?
	var keys:  [Dictionary<Int, String>.Keys.Element]?

	init(file: String) {
		let screenSize = CGSize(width: GameEngine.width, height: GameEngine.height)
		node = SKSpriteNode()
		node.anchorPoint = CGPoint(x: 0, y: 0)
		node.size = screenSize
		
		screenFrame = Sprite(width: GameEngine.width, height: GameEngine.height)

		screenNode = SKSpriteNode()
		screenNode.anchorPoint = CGPoint(x: 0, y: 0)
		screenNode.size = CGSize(width: 512, height: 480)

		super.init(size: screenSize)

		scaleMode = .aspectFit

		addChild(node)
		node.addChild(screenNode)

		if let cart = Cartridge(from: file) {
			gb = Bus()
			gb.insert_cartridge(cart)
			gb.reset()

			mapLigb = gb.cpu.disassemble(start: 0x0000, end: 0xFFFF)
			keys = Array(mapLigb!.keys).sorted()
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func keyDown(with event: NSEvent) {
		keyPressed = event.keyCode
	}
	
	override func keyUp(with event: NSEvent) {
		keyPressed = nil
	}

	override func update(_ currentTime: TimeInterval) {
		node.removeAllChildren()

		if emulation_run {
			repeat {
				gb.clock()
			} while gb.cpu.cycles > 0
		} else {
			if keyPressed == 8 {	// C
				repeat {
					gb.clock()
				} while gb.cpu.cycles > 0
			}
		}
		
		if keyPressed == 15 {	// r
			gb.reset()
		} else if keyPressed == 49 {	// space
			emulation_run = !emulation_run
		} else if keyPressed == 18 {	// 1
			show_cpu = !show_cpu
		} else if keyPressed == 19 {	// 2
			show_code = !show_code
		}
		
		if show_cpu {
			draw_cpu(x: 516, y: 2)
		}
		if show_code {
			draw_code(x: 516, y: 82, lines: 26)
		}
	
		keyPressed = nil
	}
	
	let COLOR_WHITE = 0xFFFFFFFF
	let COLOR_GREEN = 0xFF00FF00
	let COLOR_RED   = 0xFF0000FF
	let COLOR_CYAN  = 0xFFFFFF00
	
	func draw_code(x: Int, y: Int, lines: Int) {
		guard let mapAsm = mapLigb, let keys = keys else {
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

	func draw_cpu(x: Int, y: Int) {
		node.drawString(x: x , y: y , text: "STATUS:", color: self.COLOR_WHITE)
		node.drawString(x: x  + 64, y: y , text: "Z", color: gb.cpu.flag_z ? COLOR_GREEN : COLOR_RED)
		node.drawString(x: x  + 80, y: y , text: "N", color: gb.cpu.flag_n ? COLOR_GREEN : COLOR_RED)
		node.drawString(x: x  + 96, y: y , text: "H", color: gb.cpu.flag_h ? COLOR_GREEN : COLOR_RED)
		node.drawString(x: x  + 112, y: y , text: "C", color: gb.cpu.flag_c ? COLOR_GREEN : COLOR_RED)
		node.drawString(x: x , y: y + 10, text: "PC: $" + hex(gb.cpu.pc, 4))
		node.drawString(x: x , y: y + 20, text: "A : #" +  hex(gb.cpu.a, 2) + "  [" + String(gb.cpu.a) + "]");
		node.drawString(x: x , y: y + 30, text: "BC: #" +  hex(gb.cpu.bc, 4) + "  [" + String(gb.cpu.b) + ", " + String(gb.cpu.c) + "]");
		node.drawString(x: x , y: y + 40, text: "DE: #" +  hex(gb.cpu.de, 4) + "  [" + String(gb.cpu.d) + ", " + String(gb.cpu.e) + "]");
		node.drawString(x: x , y: y + 50, text: "HL: #" +  hex(gb.cpu.hl, 4) + "  [" + String(gb.cpu.h) + ", " + String(gb.cpu.l) + "]");
		node.drawString(x: x , y: y + 60, text: "SP: $" + hex(gb.cpu.sp, 4));
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
