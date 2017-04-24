//
//  Speaker.swift
//  CenozoicForMac
//
//  Created by t0p_l1ght on 2017/04/24.
//  Copyright © 2017年 Kazuhiro S. All rights reserved.
//

import Foundation
import AVFoundation
import Cocoa

class Speaker {
  var mainSpeaker = NSSpeechSynthesizer()
  var speakContents = Array<String>()
  
  init(rate: Float){
    mainSpeaker.rate = rate
  }
  
  func addSpeakedContent(_ content: String){
    print(speakContents)
    speakContents.append(content)
  }
  
  // 喋る。
  func speakContent(_ content: String){
    mainSpeaker.stopSpeaking()
    mainSpeaker.startSpeaking(content)
    Thread.sleep(forTimeInterval: 0.5)
    while(mainSpeaker.isSpeaking){}
  }
  
  func changeRate(_ rate: Float){
    mainSpeaker.rate = rate
  }
}
