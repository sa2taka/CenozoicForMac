//
//  AppDelegate.swift
//  CenozoicForMac
//
//  Created by t0p_l1ght on 2017/04/23.
//  Copyright © 2017年 Kazuhiro S. All rights reserved.
//

import Cocoa
import Magnet

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  @IBOutlet weak var menu: NSMenu!
  
  let ltlSpeaker = LTLSpeaker.sharedInstance
  let mstdn = MastodonManager.sharedInstance
  
  // tootするためのWindow
  let tootWindow = NSWindow(contentRect: NSMakeRect(0, 0, NSScreen.main()!.frame.midX, NSScreen.main()!.frame.midY), styleMask: [.closable], backing: .buffered, defer: false)
  
  //メニューバーに表示されるアプリケーションを作成
  let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
    
    // メニューバーに表示されるアプリ。今回は文字列で設定
    statusItem.title = "CenForM"
    //メニューのハイライトモードの設定
    statusItem.highlightMode = true
    //メニューの指定
    statusItem.menu = menu
    
    // コマンドダブルタップ
    if let keyCombo = KeyCombo(doubledCocoaModifiers: .command) {
      let hotKey = HotKey(identifier: "CommandDoubleTap", keyCombo: keyCombo, target: self, action: #selector(self.tappedDoubleCommandKey))
      hotKey.register() // or HotKeyCenter.shared.register(with: hotKey)
    }
    
    // Cmd+Ctrl+t
    if let keyCombo2 = KeyCombo(keyCode: 17, carbonModifiers: 4352){
      let hotKey2 = HotKey(identifier: "CommandControlT", keyCombo: keyCombo2, target: self, action: #selector(self.openTootWindow))
      hotKey2.register()
    }
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func tappedDoubleCommandKey() {
    if ltlSpeaker.isSpeaking {
      ltlSpeaker.stopLoop()
    }
    else{
      ltlSpeaker.startLoop()
    }
    print("tapped Double Command Key")
  }
  
  func createNewWindow() {
    tootWindow.title = "New Window"
    tootWindow.isOpaque = false
    tootWindow.center()
    tootWindow.isMovableByWindowBackground = true
    tootWindow.backgroundColor = NSColor(calibratedHue: 0, saturation: 1.0, brightness: 0, alpha: 0.7)
    tootWindow.makeKeyAndOrderFront(nil)
  }
  
  func openTootWindow(){
    print("tapped Cmd-Ctrl-t Key")
    createNewWindow()
  }
  
  @IBAction func onPutQuit(_ sender: Any) {
    NSApplication.shared().terminate(self)
  }
}

