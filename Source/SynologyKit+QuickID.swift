//
//  SynologyKit+QuickID.swift
//  SynologyKit
//
//  Created by xu.shuifeng on 2019/10/31.
//

import Foundation
import Alamofire

extension SynologyKit {
    
    public class func getServerInfo(quickID: String, completion: @escaping (QuickIDResponse) -> Void) {
        let url = "https://global.QuickConnect.to/Serv.php"
        var params: [String: Any] = [:]
        params["id"] = "audio_http"
        params["serverID"] = quickID
        params["command"] = "get_server_info"
        params["version"] = 1
        
        let headers = ["User-Agent": userAgent]
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).response { (dataResponse) in
            if let error = dataResponse.error {
                print("QuickID login error:\(error)")
            } else if let data = dataResponse.data {
                if let response = try? JSONDecoder().decode(QuickIDResponse.self, from: data) {
                    completion(response)
                } else {
                    print("can not parse json")
                    if let txt = String(data: data, encoding: .utf8) {
                        print("response text:\(txt)")
                    }
                }
            }
        }
    }
    
    public class func getServerInfo(quickID: String, platform: String, completion: @escaping (QuickIDResponse) -> Void) {
        let url = "https://cnc.quickconnect.to/Serv.php"
        var params: [String: Any] = [:]
        params["location"] = "en_CN"
        params["id"] = "audio_http"
        params["platform"] = platform
        params["serverID"] = quickID
        params["command"] = "request_tunnel"
        params["version"] = 1

        let headers = ["User-Agent": userAgent]

        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).response { (dataResponse) in
            if let error = dataResponse.error {
                print("QuickID login error:\(error)")
            } else if let data = dataResponse.data {
                if let response = try? JSONDecoder().decode(QuickIDResponse.self, from: data) {
                    completion(response)
                }
            }
        }
    }
}
