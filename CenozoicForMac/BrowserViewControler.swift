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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let url = URL(string: MastodonManager.sharedInstance.authorizationURL)
    let urlRequest = URLRequest(url: url!)
    self.browser.load(urlRequest)
  }
  
  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }
}
