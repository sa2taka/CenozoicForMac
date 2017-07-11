//
//  LTLSpeaker.swift
//  CenozoicForMac
//
//  Created by 薩田和弘 on 2017/07/09.
//  Copyright © 2017年 Kazuhiro S. All rights reserved.
//

import Foundation

class LTLSpeaker{
  // シングルトンのための記述
  static let sharedInstance = LTLSpeaker()
  
  let waitTime = TimeInterval(10)
  
  var speaker = Speaker(rate: 360)
  var lastID = 0;
  var maxCharacters = 100;
  var isSpeaking = false
  
  var timer = Timer()
  
  private init(){
    addContentToSpeaker()
  }
  
  func startLoop(){
    isSpeaking = true
    speaker.startSpeaking()
    timer = Timer.scheduledTimer(timeInterval: waitTime,
                         target: self,
                         selector: #selector(self.onUpdate(_:)),
                         userInfo: nil,
                         repeats: true)
  }
  
  func stopLoop(){
    isSpeaking = false
    timer.invalidate()
    speaker.stopSpeaking()
  }
  
  
  @objc func onUpdate(_ timer: Timer){
    addContentToSpeaker()
  }
  
  func setRate(rate: Float){
    speaker.changeRate(rate)
  }
  
  func getRate() -> Float {
    return speaker.getRate()
  }
  
  func setMaxCharacters(max: Int){
    maxCharacters = max
  }
  
  func getMaxCharacters() -> Int {
    return maxCharacters
  }
  
  private func addContentToSpeaker() {
    let timelineURL = "https://mstdn-workers.com/api/v1/timelines/public?local=true"
    let url = URL(string: timelineURL + "&since_id=" + String(lastID))!
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
      if let jsonData = data {
        // ここで取得したデータからJSONを抜き出し喋らせる処理を行う
        let json = self.getJSON(jsonData)
        self.addContentToSpeaker(from: json)
      }
    }
    task.resume()
    // Speakerが喋らなくなったときにもう一度喋らせるための処理
    if !speaker.mainSpeaker.isSpeaking {
      speaker.speakOneContent()
    }
  }
  
  // JSONのデータからコンテンツを取得しSpeakerにAddする
  private func addContentToSpeaker(from json: NSArray){
    if json.count != 0 {
      var speakedContents = self.getSpeakedContents(json)
      self.updateLastID(json)
      
      speakedContents = speakedContents.reversed() // 逆順に取得したコンテンツを逆さまにして時系列に変更する
      
      for content in speakedContents{
        self.speaker.addSpeakedContent(content)
      }
    }
  }
  
  // JSONを取得する
  private func getJSON(_ data: Data) -> NSArray{
    var json : NSArray = []
    do{
      // FIXME ここの右側の値を正しくやりたい。多分だが2
      if data.count > 5 {
        json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSArray
      }
      else {
        // JSONの中身がないとエラーを吐いて倒れるため空配列で初期化
        json = NSArray()
      }
    }
    catch{
      print("error: getJSON()")
    }
    return json
  }
  
  // JSONからコンテント(HTMLタグを削除し、URLを省略したもの)を抜き出してArrayとして返す
  private func getSpeakedContents(_ json: NSArray) -> Array<String> {
    var speakedContents = Array<String>()
    for data in json {
      var content = String(describing: (data as! Dictionary<String, Any>)["content"]!)
      content = removeHTMLTag(str: content)
      content = removeURL(str: content)
      content = shortCharacters(str: content, to : maxCharacters)
      speakedContents.append(content)
    }
    return speakedContents
  }
  
  // LastIDを更新する, jsonの最初(最新)のidをLastIDとして登録する
  private func updateLastID(_ json: NSArray){
    self.lastID = (json[0] as! Dictionary<String, Any>)["id"] as! Int
  }
  
  // String中のHTMLタグを削除する
  private func removeHTMLTag(str: String) -> String {
    let removedTagStr = str.pregReplace(pattern: "<br>", with: "\n")
    return removedTagStr.pregReplace(pattern: "<[^>]+>", with: "")
  }
  
  // URLを削除しURL省略という文字列に変更する
  private func removeURL(str: String) -> String{
    var removedURLString = String()
    removedURLString =  str.pregReplace(pattern: "https?:\\/\\/[^\\s^\\n]+", with: "URL省略")
    print(removedURLString)
    return removedURLString
  }
  
  // 特定文字以上のtootsを一部省略する
  private func shortCharacters(str: String, to num: Int) -> String{
    var retVal = str
    if str.characters.count > num {
      retVal = str.substring(to: str.index(str.startIndex, offsetBy: num))
      retVal = retVal + " 以下省略"
    }
    return retVal
  }
}
