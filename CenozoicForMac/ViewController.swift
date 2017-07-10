//
//  ViewController.swift
//  CenozoicForMac
//
//  Created by t0p_l1ght on 2017/04/23.
//  Copyright © 2017年 Kazuhiro S. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
  let ltlSpeaker = LTLSpeaker.sharedInstance
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }
  
  // 再生スピード変更時のメソッド
  @IBAction func onSlidechangeSpeedSlider(_ sender: Any) {
    let rate = (sender as! NSSlider).floatValue
    ltlSpeaker.setRate(rate: rate)
  }
  
  @IBAction func onSlidechangeMaxCharactersSlider(_ sender: Any) {
    let maxCharacters = (sender as! NSSlider).intValue
    changeMaxCharacters(Int(maxCharacters))
  }
  
  func changeMaxCharacters(_ maxCharacters: Int){
    ltlSpeaker.setMaxCharacters(max: maxCharacters)
  }
}

