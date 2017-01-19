//
//  UserRequest.swift
//  驴妈妈Swift
//
//  Created by 贺嘉炜 on 2016/12/21.
//  Copyright © 2016年 贺嘉炜. All rights reserved.
//

import Foundation

/** 
 * UserRequest 中有一个未定义初始值的 name 属性，其他的属性都是为了满足协议所定义的
 * 因为请求的参数用户名 name 会通过 URL 进行传递，所以 parameter 是一个空字典就足够了
 * 有了协议定义和一个满足定义的具体请求，现在我们需要发送请求
 */
struct UserRequest: Request {
    typealias Response = User
    
    let name: String
    
    var path: String {
        return "/users/\(name)"
    }
    
    let method: HTTPMethod = .GET
    let parameter: [String: Any] = [:]
    
    
    func parse(data: Data) -> User? {
        return User(data: data)
    }
}

/** 不依赖任何第三方库，也不用url代理或Runtime消息转发等等复杂的技术，就可以进行请求
 *  保持简单的代码和逻辑，对于项目维护和发展是至关重要的。
 */

/** 可扩展性
 * 因为高度解耦，这种基于 POP 的实现为代码的扩展提供了相对宽松的可能性。
 * 不必自行去实现一个完整的 Client，而可以依赖于现有的网络请求框架，实现请求发送的方法即可（也就是说，你也可以很容易地将某个正在使用的请求方式替换为另外的方式，而不会影响到请求的定义和使用）
 * 类似地，在 Response 的处理上，现在我们定义了 Decodable，用自己手写的方式在解析模型。
 * 完全可以使用第三方 JSON 解析库，来迅速构建模型（这仅仅只需要实现一个将 Data 转换为对应模型类型的方法即可）
 */
struct URLSessionClient: Client {
    var host = "https://api.onevcat.com"
    
    func send<T : Request>(_ r: T, handler: @escaping (T.Response?) -> Void) {
        let url = URL(string: host.appending(r.path))!
        var request = URLRequest(url: url)
        request.httpMethod = r.method.rawValue
        
        let task = URLSession.shared.dataTask(with: request) {
            data, _, error in
            if let data = data, let res = T.Response.parse(data: data) {
                DispatchQueue.main.async { handler(res) }
            } else {
                DispatchQueue.main.async { handler(nil) }
            }
        }
        task.resume()
    }
}

/** 接下来，可以创建一个新的类型，让它满足 Client 协议。
 *  但是与 URLSessionClient 不同，这个新类型的 send 方法并不会实际去创建请求，并发送给服务器。
 *  我们在测试时需要验证的是一个请求发出后如果服务器按照文档正确响应，那么我们应该也可以得到正确的模型实例。
 *  所以这个新的 Client 需要做的事情就是从本地文件中加载定义好的结果，然后验证模型实例是否正确
 */
struct LocalFileClient: Client {
    func send<T : Request>(_ r: T, handler: @escaping (T.Response?) -> Void) {
        switch r.path {
        case "/users/onevcat":
            
            guard let fileURL = Bundle.main.url(forResource: "LocalUserRequestData", withExtension: "") else {
                fatalError()
            }
            guard let data = try? Data(contentsOf: fileURL) else {
                fatalError()
            }
            handler(T.Response.parse(data: data))
        default:
            fatalError("Unknown path")
        }
    }
    
    // 为了满足 `Client` 的要求，实际我们不会发送请求
    let host = ""
}

