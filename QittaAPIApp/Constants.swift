//
//  Constants.swift
//  QittaAPIApp
//
//  Created by 森園王 on 2021/11/07.
//

import Foundation

struct Constants {
    static let shared = Constants()
    private init(){}
    
    let clientID = "83d5cb8e6fb4bd1d763a1eb429e068f5c430cbc8"
    let clientSecret = "c38d8be3b28a25ff7453e27b84fac593f14e22ff"
    
    let baseUrl = "https://qiita.com/api/v2" //QiitaAPIへのリクエストに使用します。

       //QiitaAPIのアクセストークンと交換するcode発行に利用します。
       let oAuthUrl = "https://qiita.com/api/v2/oauth/authorize"

       let scopes = "read_qiita+write_qiita" //このアプリにほしいQiitaAPIの権限を書いています。
       let callbackUrlScheme = "qiita-api-oauth"
}
