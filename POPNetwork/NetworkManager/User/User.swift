//
//  User.swift
//  驴妈妈Swift
//
//  Created by 贺嘉炜 on 2016/12/21.
//  Copyright © 2016年 贺嘉炜. All rights reserved.
//

import Foundation

//{"name":"onevcat","message":"Welcome to MDCC 16!"}

struct User {
    let name: String
    let message: String
    
    init?(data: Data) {
    /**
     *  1. 使用传入的data来序列化为json是一层，因为data不一定能序列化为json所以返回的json对象是一个可选类型
     *  2. 返回josn对象之后其是否为 [String: Any] 的格式又是一层，所以这种格式的字典也是可选类型
     *  3. 在最外层使用guard是描述的字典类型的json对象，无论是否序列化成功或者是格式正确，只要两个环节有一个有问题，那么返回nil
     *  4. 序列化的options参数可以有：.mutableContainers、.mutableLeaves、.allowFragments
     */
        guard let obj = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        else{
            return nil
        }
        
        guard let name = obj?["name"] as? String else{
            return nil
        }
        
        guard let message = obj?["message"] as? String else{
            return nil
        }
        
        self.name = name
        self.message = message
    }
}

extension User: Decodable {
    static func parse(data: Data) -> User? {
        return User(data: data)
    }
}



















