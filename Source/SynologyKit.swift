//
//  SynologyKit.swift
//  SynologyKit
//
//  Created by xu.shuifeng on 19/09/2017.
//

import Foundation
import Alamofire

// https://global.download.synology.com/download/Document/DeveloperGuide/Synology_File_Station_API_Guide.pdf

public typealias SynologyCompletion<T> = (Swift.Result<T, Error>) -> Void

public typealias SynologyKitCompletion<T> = (SynologyKitResponse<T>) -> Void where T: SynologyKitProtocol

/// SynologyKit for File Station
public class SynologyKit {
    
    static let EntryCGI = "entry.cgi"
    
    public static var userAgent = "DS audio 5.13.2 rv:323 (iPhone; iOS 11.0; en_CN)"
    
    public static var host: String?
    
    public static var port: Int?
    
    public static var sessionid: String?
    
    public static var enableHTTPS = false
    
    class func baseURLString() -> String {
        
        guard let host = host else {
            return ""
        }
        
        let scheme = enableHTTPS ? "https": "http"
        
        if let port = port {
            return "\(scheme)://\(host):\(port)/"
        }
        return "\(scheme)://\(host)/"
    }
    
    private class func requestUrlString(path: String) -> String {
        return baseURLString().appending(path)
    }
    
    class func getJSON<T>(path: String, parameters: Parameters?, completion: @escaping SynologyKitCompletion<T>) {
        let urlString = requestUrlString(path: path)
        print(urlString)
        Alamofire.request(urlString, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).response { (dataResponse) in
            if let error = dataResponse.error {
                print("error:\(error)")
            } else {
                if let data = dataResponse.data {
                    if let json = try? JSONDecoder().decode(SynologyKitResponse<T>.self, from: data) {
                        completion(json)
                    } else if let responseString = String(data: data, encoding: String.Encoding.utf8) {
                        print("JSONDecoder failed, and response string: " + responseString)
                    }
                } else {
                    print("response data is nil")
                }
            }
        }
    }
    
    private class func handleResponse<T>(_ response: DefaultDataResponse, completion: @escaping SynologyKitCompletion<T>) {
        
    }
    
    class func download(path: String, parameters: Parameters, to destination: DownloadRequest.DownloadFileDestination?) -> DownloadRequest {
        let urlString = baseURLString().appending("\(path)")
        print(urlString)
        return Alamofire.download(urlString, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil, to: destination)
    }
}
