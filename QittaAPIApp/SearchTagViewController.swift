//
//  SearchTagViewController.swift
//  QittaAPIApp
//
//  Created by 森園王 on 2021/11/07.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess

class SearchTagViewController: UIViewController {
    let consts = Constants.shared
    @IBOutlet weak var tagSearchBar: UISearchBar!
    @IBOutlet weak var articleTableView: UITableView!
    var articles: [Article] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
         tagSearchBar.delegate = self
         articleTableView.dataSource = self
         articleTableView.delegate = self
    }
    
    func loadArticles(tag: String) {
        //リクエストのURL生成
        let url = URL(string: consts.baseUrl + "/tags/\(tag)/items")!
        //キーチェーンからアクセストークンを取り出しておく
        let keychain = Keychain(service: consts.service)
        guard let token = keychain["access_token"] else { return }
        //ヘッダにアクセストークンを含ませる
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        //Alamofireでリクエストを発行
        AF.request(url, method: .get, headers: headers).responseJSON { response in
            switch response.result {
             //successの時
            case .success(let value):
               //検索結果の記事の一覧を初期化
                self.articles = []
                 //SwiftyJSONでデコード
                let json = JSON(value).arrayValue
                 //Article型のオブジェクトをつくってarticlesという配列に追加
                for article in json {
                    self.articles.append(Article(title: article["title"].string!, urlString: article["url"].string! ))
                }
               //テーブルビューを更新
                self.articleTableView.reloadData()
           //failureの時
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
}

extension SearchTagViewController: UISearchBarDelegate {
    //SearchBarの検索ボタンがクリックされたときに呼ばれるデリゲートメソッド
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.searchTextField.text else { return print("no text") }
        if searchText == "" {
        } else {
            //検索バーに入力された文字でタグ検索
            loadArticles(tag: searchText)
           //検索後Searchbarを非アクティブにする(keyboardをしまう)
           searchBar.endEditing(true)
        }
    }
}

extension SearchTagViewController: UITableViewDelegate {
    //テーブルビューのRセルがタップされた時に呼ばれるデリゲートメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Web Kit Viewを置いた画面をインスタンス化
        let webVC = self.storyboard?.instantiateViewController(withIdentifier: "WebVC") as! WebViewController
        let article = articles[indexPath.row]

       //記事のURLを渡す
        webVC.url = article.urlString
        webVC.title = article.title
        navigationController?.modalPresentationStyle = .fullScreen
       //Web Kit Viewを置いた画面に遷移
        navigationController?.pushViewController(webVC, animated: true)
    }
}

extension SearchTagViewController: UITableViewDataSource {
     //セクションの中に表示するセルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  articles.count
    }
    //セルを生成(インスタンス化)して、そのLabelに検索結果の記事のタイトルを表示
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = articles[indexPath.row].title
        cell.contentConfiguration = content
        return cell
    }
    //セクションの数を設定
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
