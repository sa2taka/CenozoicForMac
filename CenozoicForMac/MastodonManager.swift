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
  let client = Client(baseURL: "https://mstdn-workers.jp")
}
