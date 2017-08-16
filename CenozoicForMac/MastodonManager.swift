//
//  MastodonManager.swift
//  CenozoicForMac
//
//  Created by t0p_l1ght on 2017/07/12.
//  Copyright © 2017年 Kazuhiro S. All rights reserved.
//
// 以下のソースコードはhttp://qiita.com/aryzae/items/564a16ebd87322fa70e3や
//                     http://qiita.com/m13o/items/7798f09f16523d5693d5を参考にしました

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
              
              do {
                let text = "\(String(describing: self.client_info["id"]))\n\(String(describing: self.client_info["redirectURI"]))\n\(String(describing: self.client_info["clientID"]))\n\(String(describing: self.client_info["clientSecret"]))"
                
                // スコープが一切違うので新たに作成
                let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first
                let path_file = dir?.appendingPathComponent(self.client_filename)
                try text.write( to: path_file!, atomically: false, encoding: String.Encoding.utf8 )
              }
              catch{
                
              }
              
              self.login()
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
      if FileManager.default.fileExists(atPath: String(describing: path_file.path)) {
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
  
  public func loginWithAuthorize(code: String){
    // 登録URL
    let registUrl = URL(string: hostInstanceURL + "/oauth/token")!
    
    // Authorizationのためのボディ
    let body: [String: String] = ["grant_type": "authorization_code",
                                  "redirect_uri": "urn:ietf:wg:oauth:2.0:oob",
                                  "client_id": client_info["clientID"] as! String,
                                  "client_secret": client_info["clientSecret"] as! String,
                                  "code": code]
    
    do {
      try post(url: registUrl, body: body) { data, response, error in
        do {
          self.responseJson = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! Dictionary<String, AnyObject>
          
          self.access_token = self.responseJson["access_token"] as! String
          
          if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            do{
              let path_file = dir.appendingPathComponent(self.access_token_filename)
              try self.access_token.write( to: path_file, atomically: false, encoding: String.Encoding.utf8 )
            }
            catch{
            }
            
          }
          self.isLogin = true
        }
        catch {
          // JSON変換メソッドの例外キャッチ
          print("json error")
        }
      }
    }
    catch {
      // postメソッドの例外キャッチ
      print("post error")
    }
    
  }
  
  public func toot(status : String){
    let tootURL = URL(string: hostInstanceURL + "/api/v1/statuses")!
    let body: [String: String] = ["access_token": access_token,
                                  "status": status,
                                  "visibility": "public"]
    
    if isLogin {
      do {
        try post(url: tootURL, body: body) { data, response, error in
          // 特に何もしない
        }
      }
      catch {
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
    authorizationURL =  hostInstanceURL + "/oauth/authorize?"
      + "client_id=\(String(describing : client_info["clientID"]!))"
      + "&response_type=code"
      + "&redirect_uri=urn:ietf:wg:oauth:2.0:oob"
      + "&scope=read%20write"
  }
}
