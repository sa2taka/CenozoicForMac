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
      hotKey.register() // or HotKeyCenterß.shared.register(with: hotKey)
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
  
  @IBAction func onPutQuit(_ sender: Any) {
    NSApplication.shared().terminate(self)
  }
}

