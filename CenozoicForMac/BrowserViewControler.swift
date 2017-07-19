//
//  BrowserViewControler.swift
//  CenozoicForMac
//
//  Created by t0p_l1ght on 2017/07/19.
//  Copyright © 2017年 Kazuhiro S. All rights reserved.
//

import Cocoa
import WebKit

class BrowserViewController: NSViewController {
  
  @IBOutlet weak var browser: WKWebView!
  @IBOutlet weak var codeField: NSTextField!
  @IBOutlet weak var codeSendButton: NSButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if(MastodonManager.sharedInstance.isLogin){
      codeSendButton.isEnabled = false
      codeSendButton.title = "ログイン済み"
    }
  }
  
  override func viewDidAppear() {
    super.viewDidAppear()
    
    let url = URL(string: MastodonManager.sharedInstance.authorizationURL)
    let urlRequest = URLRequest(url: url!)
    self.browser.load(urlRequest)
  }
  
  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }
  @IBAction func sendCode(_ sender: Any) {
    MastodonManager.sharedInstance.loginWithAuthorize(code: codeField.stringValue)
    codeSendButton.isEnabled = false
    codeSendButton.title = "送信済み"
  }
}
