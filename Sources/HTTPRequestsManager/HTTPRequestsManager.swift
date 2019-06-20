//
//  RequestManager.swift
//  HttpRequest
//
//  Created by Shahar Melamed on 1/16/19.
//  Copyright © 2019 Shahar Melamed. All rights reserved.
//

import Foundation

public class HRMRequest {
    
    /// All the params of the request
    private var params = [HRMRequestParam]()
    /// All the URLTask to execute when the requests sends
    private var tasks = [URLSessionDataTask]()
    /// Counter of all the request
    private static var idCount = 0
    
    /// create new request
    public init() {}
    
    /// set the request
    /// params: the url as String, the method (get, post or none [get without params]) and the compluition handler
    /// returns: the id of the request
    public func addRequest(url: String, method: HRMRequestMethod, completionHandler: @escaping (_ data: [String:String], _ id: Int) -> Void) -> Int {
        if method == .post {
            let url = NSURL(string: url)
            let session = URLSession.shared
            let request = NSMutableURLRequest(url: url! as URL)
            
            request.httpMethod = "POST"
            let paramString = HRMRequestParam.arrayToString(params: params)
            request.httpBody = paramString.data(using: String.Encoding.utf8)
            request.timeoutInterval = 10000000000
            
            HRMRequest.idCount += 1
            let id = HRMRequest.idCount
            
            let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
                guard let data = data else { return }
                
                completionHandler(HRMRequest.dataToDictionary(data: data), id)
            }
            tasks.append(task)
            return id
        } else {
            let Url = URL(string: url+"?\(HRMRequestParam.arrayToString(params: params))")
            
            let urlSession = URLSession.shared
            
            var getRequest = URLRequest(url: Url!)
            
            HRMRequest.idCount += 1
            let id = HRMRequest.idCount
            
            let task = urlSession.dataTask(with: getRequest) { (data, response, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
                guard let data = data else { return }
                
                completionHandler(HRMRequest.dataToDictionary(data: data), id)
            }
            getRequest.timeoutInterval = 10000000000
            tasks.append(task)
            return id
        }
    }
    
    /// add parameter to the request
    /// params: the name of the parameter and it's value
    public func addParam(name: Any, value: Any) {
        params.append(param(name: name, value: value))
    }
    
    public func removeParam(withName name: String) {
        var i = 0
        
        for param in params {
            if param.name == name {
                params.remove(at: i)
            } else {
                i+=1
            }
        }
    }
    
    /// remove all the parameters
    public func removeAllParams() {
        params.removeAll()
    }
    
    /// creates a new RequestParam
    /// params: the name of the parameter and it's value
    /// returns: the RequestParam
    private func param(name: Any, value: Any) -> HRMRequestParam {
        return HRMRequestParam(name: name, value: value)
    }
    
    /// send all the requests
    /// params: clean - if true, all the tasks will be removed
    public func send(clean: Bool = false) {
        for task in tasks {
            DispatchQueue.global().async {
                task.resume()
            }
        }
        
        if clean {
            tasks.removeAll()
        }
    }
    
    /// converts a Data object to dictionary of type [String:String]
    private static func dataToDictionary(data: Data) -> [String:String] {
        do {
            let decoder = JSONDecoder()
            let beer = try decoder.decode([String:String].self, from: data)
            
            return beer
        }
        catch {
            // Nothing
        }
        
        if let dataString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
            return ["dataString" : dataString as String]
        }
        return [:]
    }
    
    /// converts a JSON string to dictionary of type [String:String]
    private func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    /// converts a "bad" JSON to array of dictionaries of type [String:String]
    static func convertErrorJSONToJson(jsonString str: String) -> [[String:String]] {
        if str.count > 5 {
            var dst = str
            dst.removeLast()
            dst.removeFirst()
            dst.removeLast()
            dst.removeFirst()
            var jsons = [[String:String]]()
            for var obj in dst.components(separatedBy: "},{") {
                obj.append("}")
                obj = "{\(obj)"
                jsons.append(dataToDictionary(data: obj.data(using: .utf8)!))
            }
            return jsons
        } else {
            return []
        }
    }
}

public class HRMRequestParam {
    
    public var name: String
    public var value: String
    
    public init(name: Any, value: Any) {
        self.name = "\(name)"
        self.value = "\(value)"
    }
    
    func string() -> String {
        return "\(name)=\(value)"
    }
    
    public static func arrayToString(params: [HRMRequestParam]) -> String {
        var st = ""
        
        for param in params {
            st += "\(param.string())&"
        }
        
        if st.count > 0 {
            st.removeLast()
        }
        
        return st
    }
}

public enum HRMRequestMethod {
    case get
    case post
    case none
}

