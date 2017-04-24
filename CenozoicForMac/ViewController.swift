//
//  ViewController.swift
//  CenozoicForMac
//
//  Created by t0p_l1ght on 2017/04/23.
//  Copyright © 2017年 Kazuhiro S. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {
  var speaker = NSSpeechSynthesizer()
  var isSpeaking = false
  let timelineURL = "https://mstdn-workers.com/api/v1/timelines/public?local=true"
  var lastID = 0;
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    
    initSpeaker()
    // 初回
    speakNewToots()
    
    Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.onUpdate(_:)), userInfo: nil, repeats: false)
  }
  
  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }
  
  func initSpeaker(){
    speaker.rate *= 3
  }
  
  func onUpdate(_ timer: Timer){
    if(!isSpeaking){
      speakNewToots()
    }
    Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.onUpdate(_:)), userInfo: nil, repeats: false)
  }
  
  func speakNewToots() {
    let timelineURL = "https://mstdn-workers.com/api/v1/timelines/public?local=true"
    let url = URL(string: timelineURL + "&since_id=" + String(lastID))!
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
      self.isSpeaking = true
      if let jsonData = data {
        // ここで取得したデータからJSONを抜き出し喋らせる処理を行う
        let json = self.getJSON(jsonData)
        if(json.count != 0){
          var speakedContents = self.getSpeakedContents(json)
          self.updateLastID(json)
          speakedContents = speakedContents.reversed() // 逆順に取得したコンテンツを逆さまにして時系列に変更する
          for content in speakedContents{
            self.speakContent(content)
          }
        }
      }
      self.isSpeaking = false
    }
    task.resume()
  }
  
  // JSONを取得する
  func getJSON(_ data: Data) -> NSArray{
    var json : NSArray = []
    do{
      // FIXME ここでdataが空のjson受け取るとisEmptyはfalseだがNSArrayでのキャストで落ちる
      if(data.count > 5){
        json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSArray
      }
      else {
        json = NSArray()
      }
    }
    catch{
      print("error: getJSON()")
    }
    return json
  }
  
  // JSONからコンテント(HTMLタグを削除し、URLを省略したもの)を抜き出してArrayとして返す
  func getSpeakedContents(_ json: NSArray) -> Array<String> {
    var speakedContents = Array<String>()
    for data in json {
      var content = String(describing: (data as! Dictionary<String, Any>)["content"]!)
      content = removeHTMLTag(str: content)
      speakedContents.append(content)
    }
    return speakedContents
  }
  
  // LastIDを更新する
  func updateLastID(_ json: NSArray){
    self.lastID = (json[0] as! Dictionary<String, Any>)["id"] as! Int
  }
  
  // 喋る。
  func speakContent(_ content: String){
    speaker.stopSpeaking()
    speaker.startSpeaking(content)
    Thread.sleep(forTimeInterval: 0.5)
    while(speaker.isSpeaking){}
  }
  
  // String中のHTMLタグを削除する
  func removeHTMLTag(str: String) -> String {
    return str.pregReplace(pattern: "<[^>]+>", with: "")
  }
}

