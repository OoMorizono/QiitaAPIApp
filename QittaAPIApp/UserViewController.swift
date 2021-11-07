//
//  UserViewController.swift
//  QittaAPIApp
//
//  Created by 森園王 on 2021/11/07.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess
import Kingfisher

class UserViewController: UIViewController {
    let sectionTitles = ["自分の投稿:"] //セクションのタイトルとして使用
    let consts = Constants.shared
    var myArticles: [MyArticle] = []
    
    @IBOutlet weak var userImageView: UIImageView! //①プロフィール画像のImageView
    @IBOutlet weak var displayNameLabel: UILabel!  //②名前(Qiitaでの表示名)のLabel
    @IBOutlet weak var accountNameLabel: UILabel!  //③Qiitaのアカウント名のLabel
    @IBOutlet weak var otherNumLabel: UILabel!     //④投稿数、フォロー数、フォロワー数を表示するLabel
    @IBOutlet weak var descriptionLabel: UILabel!  //⑤プロフィールの紹介文を表示するLabel
    @IBOutlet weak var userTableView: UITableView! //⑥自分の投稿一覧を表示するTableView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userTableView.dataSource = self
        userImageView.layer.cornerRadius = userImageView.layer.frame.width / 2.0
        userImageView.layer.borderWidth = 2.0
        userImageView.layer.borderColor = UIColor.green.cgColor
        userImageView.layer.masksToBounds = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserInfoFromQiita()
    }
    
    //認証ユーザーの情報を取得するためのメソッド
    func getUserInfoFromQiita() {
        //キーチェーンからアクセストークンを取り出す
        let keychain = Keychain(service: consts.service)
        guard let accessToken = keychain["access_token"] else { return print("no token") }
        
        //リクエストのURLの生成
        let url = URL(string: consts.baseUrl + "/authenticated_user")!
        //ヘッダにアクセストークンを含める
        let headers: HTTPHeaders = [.authorization(bearerToken: accessToken)]
        //Alamofireでリクエストする
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
                //successの時
            case .success(let value):
                //SwiftyJSONでDecode
                let json = JSON(value)
                //レスポンスで受け取った値から、User型のオブジェクトを作成
                let user = User(
                    description: json["description"].string!,
                    foloweesCount: json["followees_count"].int!,
                    folowersCount: json["followers_count"].int!,
                    id: json["id"].string!,
                    itemsCount: json["items_count"].int!,
                    name: json["name"].string!,
                    profileImageUrl: json["profile_image_url"].string!)
                //プロフィール画面にUser型のオブジェクトの中身を反映
                self.setUser(user: user)
                //failureの時
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
        //認証ユーザーの記事取得のURL生成
    let itemUrl = URL(string: consts.baseUrl + "/authenticated_user/items")!
    //Alamofireでリクエスト
    AF.request(itemUrl, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
        switch response.result {
        //successのとき
        case .success(let value):
            self.myArticles = []
            let json = JSON(value).arrayValue //SwiftyJSONでデコード
            //jsonから記事1件ずつの情報を取り出してMyarticle型のオブジェクトをつくり、配列に追加
            for myArticle in json {
                let article = MyArticle(
                title: myArticle["title"].string!,
                url: myArticle["url"].string!,
                articleId: myArticle["id"].string!,
                isPrivate: myArticle["private"].bool!
                )
                self.myArticles.append(article)
            }
            //自分の投稿記事一覧のテーブルビューを更新
            self.userTableView.reloadData()
        case .failure(let err):
            print(err.localizedDescription)
        }
    }
        
    }
    func setUser(user: User) {
        //プロフィール画像のURLを生成
        let imageUrl = URL(string: user.profileImageUrl)!
        //KingfisherでURLの画像を取得してImageViewのImageに表示
        userImageView.kf.setImage(with: imageUrl)
        //それぞれのLabelに表示
        displayNameLabel.text = user.name
        accountNameLabel.text = "@" + user.id
        otherNumLabel.text = "投稿: \(user.itemsCount)  フォロー: \(user.foloweesCount)  フォロワー: \(user.folowersCount)"
        descriptionLabel.text = user.description
    }
    
}

extension UserViewController: UITableViewDataSource {
    //セクション中のセルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myArticles.count
    }
    //セルのLabelに記事のタイトルを表示(限定共有のものには[限定共有]と先頭につけるよう場合分け)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Storyboardで設定したセルのIdentifierを指定。
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyArticleCell")!
        var content = cell.defaultContentConfiguration()
        if myArticles[indexPath.row].isPrivate {
            content.text = "[限定共有]" + myArticles[indexPath.row].title
        } else {
            content.text = myArticles[indexPath.row].title
        }
        cell.contentConfiguration = content
        return cell
    }
   //セクションの数はセクションのタイトルの数
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    //セクションのタイトルを設定
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
}

