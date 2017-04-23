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
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }
  
  func getJson() -> Data? {
    let url = URL(string: timelineURL + "&since_id=587050")!
    var res : Data?
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
      res = data
    }
    task.resume()
    return res
  }
}

