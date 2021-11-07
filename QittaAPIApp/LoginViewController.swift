//
//  LoginViewController.swift
//  
//
//  Created by 森園王 on 2021/11/07.
//

import UIKit
import AuthenticationServices
import Alamofire
import SwiftyJSON
import KeychainAccess

class LoginViewController: UIViewController {
    let consts = Constants.shared
    //Constantsに格納した定数を使う準備
    var token = ""
    var session: ASWebAuthenticationSession?
    //Webの認証セッションを入れておく

    override func viewDidLoad() {
        super.viewDidLoad()
        let keychain = Keychain(service: consts.service)
        if keychain["access_token"] != nil {
            keychain["access_token"] = nil //keychainに保存されたtokenを削除
               }

    }
    
    //取得したcodeを使ってアクセストークンを発行
    func getAccessToken(code: String!) {
        let url = URL(string: consts.baseUrl + "/access_tokens")!
        guard let code = code else { return }
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "ACCEPT": "application/json"
        ]
        let parameters: Parameters = [
            "client_id": consts.clientID,
            "client_secret": consts.clientSecret,
            "code": code
        ]
        print("CODE: \n\(code)")

        //Alamofireでリクエスト
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let token: String? = json["token"].string
                guard let accessToken = token else { return }
                self.token = accessToken
              let keychain = Keychain(service: self.consts.service) //このアプリ用のキーチェーンを生成
              keychain["access_token"] = accessToken //キーを設定して保存
                self.transitionToTabBar() //画面遷移
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    @IBAction func loginQiita(_ sender: Any) {
            let keychain = Keychain(service: consts.service)
            if keychain["access_token"] != nil {
                token = keychain["access_token"]!
                transitionToTabBar() //画面遷移
            } else {
                let url = URL(string: consts.oAuthUrl + "?client_id=\(consts.clientID)&scope=\(consts.scopes)")!
                session = ASWebAuthenticationSession(url: url, callbackURLScheme: consts.callbackUrlScheme) {(callback, error) in
                    guard error == nil, let successURL = callback else { return }
                    let queryItems = URLComponents(string: successURL.absoluteString)?.queryItems
                    guard let code = queryItems?.filter({ $0.name == "code" }).first?.value else { return }
                    self.getAccessToken(code: code) // アクセストークンを発行するメソッドを実行
                }
            }
            session?.presentationContextProvider = self
            session?.prefersEphemeralWebBrowserSession = true
            session?.start()
        }
        
        func transitionToTabBar() {
            let tabBarContorller = self.storyboard?.instantiateViewController(withIdentifier: "TabBarC") as! UITabBarController
            tabBarContorller.modalPresentationStyle = .fullScreen
            present(tabBarContorller, animated: true, completion: nil)
        }
    }

extension LoginViewController:ASWebAuthenticationPresentationContextProviding {
   func presentationAnchor(for session:ASWebAuthenticationSession) -> ASPresentationAnchor {
       return self.view.window!
   }
}

