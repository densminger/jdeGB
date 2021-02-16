//
//  AppDelegate.swift
//  jdeGB
//
//  Created by David Ensminger on 2/12/21.
//

import SpriteKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet var window: NSWindow!
	@IBOutlet var view: SKView!


	func applicationDidFinishLaunching(_ aNotification: Notification) {
		window.contentAspectRatio = GameEngine.screenSize
		window.contentMinSize = GameEngine.screenSize

		open(path: ProcessInfo.processInfo.environment["file"] ?? "")
	}

	func open(path: String) {
		let scene = GameEngine(file: path)

		view.presentScene(scene)
		view.ignoresSiblingOrder = true
		view.showsFPS = true
	}
}

