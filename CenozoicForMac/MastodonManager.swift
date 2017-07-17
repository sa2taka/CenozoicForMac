//
//  MastodonManager.swift
//  CenozoicForMac
//
//  Created by t0p_l1ght on 2017/07/12.
//  Copyright © 2017年 Kazuhiro S. All rights reserved.
//

import Foundation

class MastodonManager {
  static let sharedInstance = MastodonManager()
  let hostInstanceURL = "https://mstdn-workers.jp"
  let client = Client(baseURL: "https://mstdn-workers.jp")
  
  let client_filename = "client.dat"
  let access_token_filename = "access.dat"
  var client_info = Dictionary<String, Any>()
  var access_token = String()
  
  init(){
    init_clinet()
    login()
  }
  
  private func init_clinet(){
    if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
      
      let path_file = dir.appendingPathComponent(client_filename)
      
      // クライアントに関するファイルがあったら、読み取る
      if FileManager.default.fileExists(atPath: String(describing: path_file)) {
        do {
          let text = try String( contentsOf: path_file, encoding: String.Encoding.utf8 )
          client_info["id"] = text.lines[0]
          client_info["redirectURI"] = text.lines[1]
          client_info["clientID"] = text.lines[2]
          client_info["clientSecret"] = text.lines[3]
        }
        catch{
          
        }
      }
        // 無かったら、登録してファイルに書き込む
      else{
        let request = Clients.register(
          clientName: "Cenozoic For Mac",
          scopes: [.read, .write],
          website: "https://github.com/sa2taka/CenozoicForMac"
        )
        
        client.run(request, completion: { (application:Result<ClientApplication>?) in
          if let application = application, let model = application.value {
            self.client_info["id"] = model.id
            self.client_info["redirectURI"] = model.redirectURI
            self.client_info["clientID"] = model.clientID
            self.client_info["clientSecret"] = model.clientSecret
          }
        })
        do {
          let text = "\(String(describing: client_info["id"]))\n\(String(describing: client_info["redirectURI"]))\n\(String(describing: client_info["clientID"]))\n\(String(describing: client_info["clientSecret"]))"
          try text.write( to: path_file, atomically: false, encoding: String.Encoding.utf8 )
        }
        catch{
          
        }
      }
    }
  }
  
  private func login(){
    if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
      
      let path_file = dir.appendingPathComponent(access_token_filename)
      var access_token = ""
      
      // アクセストークンに関するファイルがあったら、読み取る
      if FileManager.default.fileExists(atPath: String(describing: path_file)) {
        do {
          let text = try String( contentsOf: path_file, encoding: String.Encoding.utf8 )
          access_token = text.lines[0]
        }
        catch{
          
        }
      }
        // 無かったら、登録してファイルに書き込む
      else{
      
      }
    }
  }
  
  private func login_with_authorization() -> String{
    let URLStr = hostInstanceURL + "/oauth/authorize?"
      + "client_id=\(String(describing : ["clientID"]))"
      + "&esponse_type=code"
      + "&redirect_uri=urn:ietf:wg:oauth:2.0:oob"
      + "&scope=read%20write"
    
    print(URLStr)
    
    
  }
}
