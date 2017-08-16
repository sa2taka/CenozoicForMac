//
//  ExtinctStringClass.swift
//  CenozoicForMac
//
//  Created by t0p_l1ght on 2017/04/23.
//  Copyright © 2017年 Kazuhiro S. All rights reserved.
//

// このソースはhttp://qiita.com/KikurageChan/items/807e84e3fa68bb9c4de6のソースコードより
// 置換部のみをコピーしてきたものです
import Foundation

extension String {
  //絵文字など(2文字分)も含めた文字数を返します
  var count: Int {
    let string_NS = self as NSString
    return string_NS.length
  }
  
  //正規表現の置換をします
  func pregReplace(pattern: String, with: String, options: NSRegularExpression.Options = []) -> String {
    let regex = try! NSRegularExpression(pattern: pattern, options: options)
    return regex.stringByReplacingMatches(in: self, options: [], range: NSMakeRange(0, self.count), withTemplate: with)
  }
  
  // 以下のソースはhttp://qiita.com/codelynx/items/183b29c95110e0dc05dbより
  var lines: [String] {
    var lines = [String]()
    self.enumerateLines { (line, stop) -> () in
      lines.append(line)
    }
    return lines
  }
}
