//
//  Request.swift
//  驴妈妈Swift
//
//  Created by 贺嘉炜 on 2016/12/21.
//  Copyright © 2016年 贺嘉炜. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case GET
    case POST
}

protocol Request {
/** 协议总是用 var 关键字来声明变量属性，在类型声明后加上 { set get } 来表示属性是可读可写的，
 *  可读属性则用 { get } 来表示：
 */
//    var host: String { get }
    var path: String { get }
    
    var method: HTTPMethod { get }
    var parameter: [String: Any] { get }
/** associatedtype只用于protocol中
 *  associatedtype类型是在protocol中代指一个确定类型并要求该类型实现指定方法
 */
    associatedtype Response:Decodable
    
/* Decodable协议 定义了一个静态的 parse 方法，这里的 parse 声明移除
 *  func parse(data: Data) -> Response?
 */
}

protocol Client {
    
    /** func send(_ r: Request, handler: @escaping (Request.Response?) -> Void)
     *  从上面的声明从语义上来说是挺明确的，但是因为 Request 是含有关联类型associatedtype的协议
     *  所以它并不能作为独立的类型来使用，我们只能够将它作为类型约束，来限制输入参数 request
     *  正确的声明方式应当是：
     */
    func send<T: Request>(_ r: T, handler: @escaping (T.Response?) -> Void)
    
    //  将 host 从 Request 移动到了 Client 里，这是更适合它的地方
    var host: String { get }
}

protocol Decodable {
    static func parse(data: Data) -> Self?
}


//为了任意请求都可以通过同样的方法发送，我们将发送的方法定义在 Request 协议扩展上
extension Request {
    /* 在 send(handler:) 的参数中，我们定义了可逃逸的 (User?) -> Void，在请求完成后，我们调用这个 handler 方法来通知调用者请求是否完成，如果一切正常，则将一个 User 实例传回，否则传回 nil。
     */
    
    /* 把含有 send 的 Request 协议扩展删除，重新创建了一个类型来满足 Client 了。
    func send(handler: @escaping (Response?) -> Void) {
        let url = URL(string: host.appending(path))!
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // 在示例中我们不需要 `httpBody`，实践中可能需要将 parameter 转为 data
        // request.httpBody = ...
        
        let task = URLSession.shared.dataTask(with: request) {
            data, _, error in
            if let data = data, let res = self.parse(data: data) {
                
                DispatchQueue.main.async { handler(res) }
            } else {
                DispatchQueue.main.async { handler(nil) }
            }
        }
        task.resume()
    }
    */
}
