//
//  GameEngine.swift
//  jdeNES
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
	
	var emulation_run = true
	
	var gb: Bus!
	
	var keyPressed: UInt16?

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
		}
	
		keyPressed = nil
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
