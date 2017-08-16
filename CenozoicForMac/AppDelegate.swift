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
class AppDelegate: NSObject, NSApplicationDelegate{
  @IBOutlet weak var menu: NSMenu!
  
  let ltlSpeaker = LTLSpeaker.sharedInstance
  let mstdn = MastodonManager.sharedInstance
  
  // tootするためのWindow
  var tootWindow = NSWindow()
  var isTootWindowActive = false
  var tootTextField : NSTextField?
  
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
    
    // Cmdダブルタップ
    if let keyCombo = KeyCombo(doubledCocoaModifiers: .command) {
      let hotKey = HotKey(identifier: "CommandDoubleTap", keyCombo: keyCombo, target: self, action: #selector(self.tappedDoubleCommandKey))
      hotKey.register() // or HotKeyCenter.shared.register(with: hotKey)
    }
    
    // Cmd+Ctrl+t
    if let keyCombo2 = KeyCombo(keyCode: 17, cocoaModifiers: [.command, .control]){
      let hotKey2 = HotKey(identifier: "CommandControlT", keyCombo: keyCombo2, target: self, action: #selector(self.openTootWindow))
      hotKey2.register()
    }
    
      // Cmd+Enter
    if let keyCombo3 = KeyCombo(keyCode: 36, cocoaModifiers: [.command]){
      let hotKey3 = HotKey(identifier: "CmdEnter", keyCombo: keyCombo3, target: self, action: #selector(self.toot))
      hotKey3.register()
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
  
  func createTootWindow() {
    tootWindow = NSWindow(contentRect: NSMakeRect(0, 0, 720, 160), styleMask: [.titled], backing: .buffered, defer: true)
    tootWindow.title = "Toot Window"
    tootWindow.center()
    tootWindow.isMovableByWindowBackground = true
    tootWindow.isOpaque = true
    tootWindow.backgroundColor = NSColor(calibratedHue: 0, saturation: 0, brightness: 0.6, alpha: 0.8)
    
    // textFieldを追加
    tootTextField = NSTextField(frame: NSMakeRect(20.0, 20.0, 680.0, 120.0))
    tootTextField?.isEditable = true
    tootTextField?.isEnabled = true
    tootTextField?.backgroundColor = NSColor(calibratedHue: 0, saturation: 0, brightness: 0.8, alpha: 0.8)
    tootTextField?.font = NSFont(name: ".Hiragino Kaku Gothic Interface W3", size: CGFloat(24))
    tootTextField?.becomeFirstResponder()
    tootWindow.contentView?.addSubview(tootTextField!)
    tootWindow.makeKey()
    
    // windowをアクティブにする
    // FIXME: windowを作って消して作ってと連続で作るとアクティブ状態にならない
    NSApplication.shared().activate(ignoringOtherApps: true)
    
    // どんな場合も最前面に動かすための処理
    tootWindow.orderFrontRegardless()
  }
  
  func closeTootWindow(){
    tootWindow.orderOut(self)
    NSApplication.shared().deactivate()
  }
  
  func openTootWindow(){
    print("tapped Cmd-Ctrl-t Key")
    if isTootWindowActive{
      closeTootWindow()
      isTootWindowActive = false
    }
    else{
      createTootWindow()
      isTootWindowActive = true
    }
  }
  
  func toot(){
    print("tapped Cmd-Enter")
    if let inputStr = tootTextField?.stringValue{
      if isTootWindowActive && !inputStr.isEmpty{
        mstdn.toot(status: inputStr)
        closeTootWindow()
        isTootWindowActive = false
      }
    }
  }
  
  @IBAction func onPutQuit(_ sender: Any) {
    NSApplication.shared().terminate(self)
  }
}

