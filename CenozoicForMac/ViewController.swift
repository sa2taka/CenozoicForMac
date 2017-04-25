//
//  ViewController.swift
//  CenozoicForMac
//
//  Created by t0p_l1ght on 2017/04/23.
//  Copyright © 2017年 Kazuhiro S. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
  var speaker = Speaker(rate: 360)
  var isSpeaking = false
  let timelineURL = "https://mstdn-workers.com/api/v1/timelines/public?local=true"
  var lastID = 0;
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    // 初回
    addContentToSpeaker()
    
    speaker.startSpeaking()
    Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.onUpdate(_:)), userInfo: nil, repeats: false)
  }
  
  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }
  
  func onUpdate(_ timer: Timer){
    addContentToSpeaker()
    Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.onUpdate(_:)), userInfo: nil, repeats: false)
  }
  
  func addContentToSpeaker() {
    let timelineURL = "https://mstdn-workers.com/api/v1/timelines/public?local=true"
    let url = URL(string: timelineURL + "&since_id=" + String(lastID))!
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
      self.isSpeaking = true
      if let jsonData = data {
        // ここで取得したデータからJSONを抜き出し喋らせる処理を行う
        let json = self.getJSON(jsonData)
        self.addContentToSpeakerFrom(json: json)
      }
    }
    task.resume()
    // Speakerが喋らなくなったときにもう一度喋らせるための処理
    if(!speaker.mainSpeaker.isSpeaking){
      speaker.speakOneContent()
    }
  }
  
  // JSONのデータからコンテンツを取得しSpeakerにAddする
  func addContentToSpeakerFrom(json: NSArray){
    // ここで取得したデータからJSONを抜き出し喋らせる処理を行う
    if(json.count != 0){
      var speakedContents = self.getSpeakedContents(json)
      self.updateLastID(json)
      
      speakedContents = speakedContents.reversed() // 逆順に取得したコンテンツを逆さまにして時系列に変更する
      
      for content in speakedContents{
        self.speaker.addSpeakedContent(content)
      }
    }
  }
  
  // JSONを取得する
  func getJSON(_ data: Data) -> NSArray{
    var json : NSArray = []
    do{
      // FIXME ここの右側の値を正しくやりたい。多分だが2
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
      content = removeURL(str: content)
      content = shortCharacters(str: content, to: 100)
      speakedContents.append(content)
    }
    return speakedContents
  }
  
  // LastIDを更新する
  func updateLastID(_ json: NSArray){
    self.lastID = (json[0] as! Dictionary<String, Any>)["id"] as! Int
  }
  
  // String中のHTMLタグを削除する
  func removeHTMLTag(str: String) -> String {
    let removedTagStr = str.pregReplace(pattern: "<br>", with: "\n")
    return removedTagStr.pregReplace(pattern: "<[^>]+>", with: "")
  }
  
  func removeURL(str: String) -> String{
    var removedURLString = String()
    removedURLString =  str.pregReplace(pattern: "https?:\\/\\/[^\\s^\\n]+", with: "URL省略")
    print(removedURLString)
    return removedURLString
  }
  
  func shortCharacters(str: String, to: Int) -> String{
    var retVal = str
    if(str.characters.count > to){
      retVal = str.substring(to: str.index(str.startIndex, offsetBy: to))
      retVal = retVal + " 以下省略"
    }
    return retVal
  }
}

