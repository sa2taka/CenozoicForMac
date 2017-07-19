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
  let hostInstanceURL = "https://mstdn-workers.com"
  
  let client_filename = "client.dat"
  let access_token_filename = "access.dat"
  var client_info = Dictionary<String, Any>()
  var access_token = String()
  var isLogin = false
  
  var authorizationURL = ""
  
  
  // Mastodonのインスタンスから返ってくるjson格納用
  var responseJson = Dictionary<String, Any>()
  
  let session = URLSession.shared
  
  init(){
    init_clinet()
  }
  
  private func init_clinet(){
    if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
      
      let path_file = dir.appendingPathComponent(client_filename)

      // クライアントに関するファイルがあったら、読み取る
      if FileManager.default.fileExists(atPath: path_file.path) {
        do {
          let text = try String( contentsOf: path_file, encoding: String.Encoding.utf8 )
          client_info["id"] = text.lines[0]
          client_info["redirectURI"] = text.lines[1]
          client_info["clientID"] = text.lines[2]
          client_info["clientSecret"] = text.lines[3]
        }
        catch{
          
        }
        login() // 最後にログイン
      }
        
        // 無かったら、登録してファイルに書き込む
      else{
        // 登録URL
        let registUrl = URL(string: hostInstanceURL + "/api/v1/apps")!
        
        // client_name: アプリ名とかどこからの投稿かわかるための名前
        // redirect_uris: おまじない(公式で"urn:ietf:wg:oauth:2.0:oob"を書く様に記載)
        // scopes: 権限。今回に関してはwriteだけで足りるが、必要に応じてスペース区切りで追加 例→ "write read follow"
        // website: アプリのURLやWebsite。client_nameにこのリンクがつく(省略可能)
        let body: [String: String] = ["client_name": "Cenozoic For Mac", "redirect_uris": "urn:ietf:wg:oauth:2.0:oob", "scopes": "write read"]
        
        // 登録POST
        do {
          try post(url: registUrl, body: body) { data, response, error in
            do {
              self.responseJson = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! Dictionary<String, AnyObject>
              self.client_info["id"] = self.responseJson["id"]
              self.client_info["redirectURI"] = self.responseJson["redirect_uri"]
              self.client_info["clientID"] = self.responseJson["client_id"]
              self.client_info["clientSecret"] = self.responseJson["client_secret"]
            }
            catch {
              // JSON変換メソッドの例外キャッチ
            }
          }
        }
        catch {
          // postメソッドの例外キャッチ
        }
      }
    }
  }
  
  private func login(){
    if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
      
      let path_file = dir.appendingPathComponent(access_token_filename)
      
      // アクセストークンに関するファイルがあったら、読み取る
      if FileManager.default.fileExists(atPath: String(describing: path_file)) {
        do {
          let text = try String( contentsOf: path_file, encoding: String.Encoding.utf8 )
          access_token = text.lines[0]
          isLogin = true
        }
        catch{
          
        }
      }
        // 無かったら、まずはauhorizationのためのURLを作成する
      else{
        create_authorization()
      }
    }
  }
  
  // POST
  private func post(url: URL, body: Dictionary<String, String>, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws {
    var request: URLRequest = URLRequest(url: url)
    
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
    
    session.dataTask(with: request, completionHandler: completionHandler).resume()
  }
  
  private func create_authorization(){
    authorizationURL =  hostInstanceURL + "oauth/authorize?"
      + "client_id=\(String(describing : client_info["clientID"]!))"
      + "&response_type=code"
      + "&redirect_uri=urn:ietf:wg:oauth:2.0:oob"
      + "&scope=read%20write"
  }
}
