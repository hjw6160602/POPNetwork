//
//  ViewController.swift
//  POPNetwork
//
//  Created by 贺嘉炜 on 2017/1/19.
//  Copyright © 2017年 贺嘉炜. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        URLSessionClient().send(UserRequest(name: "onevcat")) { user in
            if let user = user {
                print("\(user.message) from \(user.name)")
            }
        }
    }
}

