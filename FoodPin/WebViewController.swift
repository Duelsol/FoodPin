//
//  WebViewController.swift
//  FoodPin
//
//  Created by Duelsol on 15/10/12.
//  Copyright © 2015年 Duelsol. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = URL(string: "https://github.com/") {
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
