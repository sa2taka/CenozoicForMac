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

class Speaker : NSObject, NSSpeechSynthesizerDelegate{
  var mainSpeaker = NSSpeechSynthesizer()
  var speakContents = Array<String>()
  var isStartingSpeak = false
  
  init(rate: Float){
    super.init()
    mainSpeaker.delegate = self
    mainSpeaker.rate = rate
  }
  
  func startSpeaking(){
    isStartingSpeak = true
    Thread.sleep(forTimeInterval: 0.5)
    speakOneContent()
  }
  
  func stopSpeaking(){
    isStartingSpeak = false
    mainSpeaker.stopSpeaking()
  }
  
  // キュー的にコンテンツを取り出し再生する
  func speakOneContent(){
    if speakContents.count != 0 && isStartingSpeak {
      let speakedContent = String(speakContents[0])!
      speakContents = Array(speakContents.dropFirst())
      speakContent(speakedContent)
    }
  }
  
  func addSpeakedContent(_ content: String){
    speakContents.append(content)
  }
  
  // 喋る。
  private func speakContent(_ content: String){
    mainSpeaker.startSpeaking(content)
  }
  
  func changeRate(_ rate: Float){
    mainSpeaker.rate = 200 * rate
  }
  
  func getRate() -> Float {
    return mainSpeaker.rate / 200
  }
  
  // 音声読み上げ終了時のコールバック(?)
  func speechSynthesizer(_ sender: NSSpeechSynthesizer,
                         didFinishSpeaking finishedSpeaking: Bool) {
    speakOneContent()
  }
  
  // 以下プロトコル実装
  func speechSynthesizer(_ sender: NSSpeechSynthesizer,
                         didEncounterErrorAt characterIndex: Int,
                         of string: String,
                         message: String) {}
  
  func speechSynthesizer(_ sender: NSSpeechSynthesizer,
                         willSpeakWord characterRange: NSRange,
                         of string: String) {}
  
  func speechSynthesizer(_ sender: NSSpeechSynthesizer,
                         didEncounterSyncMessage message: String) {}
  
  func speechSynthesizer(_ sender: NSSpeechSynthesizer,
                         willSpeakPhoneme phonemeOpcode: Int16) {}
}
