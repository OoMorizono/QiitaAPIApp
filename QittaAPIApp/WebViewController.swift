//
//  WebViewController.swift
//  QittaAPIApp
//
//  Created by 森園王 on 2021/11/07.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    @IBOutlet weak var articleWebView: WKWebView!
    var url: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        let articleUrl = URL(string: url)!
        let request = URLRequest(url: articleUrl)
        articleWebView.load(request)
    }

}
