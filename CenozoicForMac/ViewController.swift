//
//  ViewController.swift
//  CenozoicForMac
//
//  Created by t0p_l1ght on 2017/04/23.
//  Copyright © 2017年 Kazuhiro S. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
  let timelineURL = "https://mstdn-workers.com/api/v1/timelines/public?local=true"
  var lastID = 0;

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    speakNewToots()
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }
  
  func speakNewToots() {
    let timelineURL = "https://mstdn-workers.com/api/v1/timelines/public?local=true"
    let url = URL(string: timelineURL + "&since_id=" + String(lastID))!
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
      if let jsonData = data {
        //
        let json = self.getJSON(jsonData)
        let speakedContents = self.getSpeakedContents(json)
        print(speakedContents)
      }
    }
    task.resume()
  }
  
  // JSONを取得する
  func getJSON(_ data: Data) -> NSArray{
    var json : NSArray = []
    do{
      json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSArray
    }
    catch{
      print("error: getJSON()")
    }
    return json
  }
  
  // JSONからコンテント(HTMLタグを削除した)を抜き出してArrayとして返す
  func getSpeakedContents(_ json: NSArray) -> Array<String> {
    var speakedContents = Array<String>()
    for data in json {
      speakedContents.append(removeHTMLTag(str: String(describing: (data as! Dictionary<String, Any>)["content"]!)))
    }
    return speakedContents
  }
  
  // String中のHTMLタグを削除する
  func removeHTMLTag(str: String) -> String {
    return str.pregReplace(pattern: "<[^>]+>", with: "")
  }
}

