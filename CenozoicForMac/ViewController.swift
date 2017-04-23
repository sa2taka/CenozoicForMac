//
//  ViewController.swift
//  CenozoicForMac
//
//  Created by 薩田和弘 on 2017/04/23.
//  Copyright © 2017年 Kazuhiro S. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
  let timelineURL = "https://mstdn-workers.com/api/v1/timelines/public?local=true"
  var lastID = 0;

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    speakNewToot()
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }
  
  func speakNewToot() {
    let timelineURL = "https://mstdn-workers.com/api/v1/timelines/public?local=true"
    let url = URL(string: timelineURL + "&since_id=587050")!
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
      
      if let jsonData = data {
        self.printJSON(jsonData)
      }
    }
    task.resume()
  }
  
  func printJSON(_ data: Data) {
    do {
      let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSArray
      print(json)
    } catch {
      print("parse error!")
    }
  }
}

