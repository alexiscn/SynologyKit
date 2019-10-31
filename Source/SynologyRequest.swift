//
//  SynologyRequest.swift
//  SynologyKit
//
//  Created by xu.shuifeng on 20/09/2017.
//

import Foundation
import Alamofire

protocol SynologyRequest {
    
    var path: String { get }
    
    var params: Parameters? { get set }
    
    var headers: HTTPHeaders? { get set }
    
    func asURLRequest() -> URLRequestConvertible
}

extension SynologyRequest {
    var params: Parameters? { return nil }
    
    var headers: HTTPHeaders? { return nil }
}

struct SynologyBasicRequest: SynologyRequest {
    
    var params: Parameters? = nil
    
    var headers: HTTPHeaders? = nil
    
    /// Name of the API requested
    var api: SynologyAPI
    
    /// Method of the API requested
    var method: SynologyMethod
    
    /// Version of the API requested
    var version: Int
    
    /// path of the API. The path information can be retrieved by requesting SYNO.API.Info
    var path: String
    
    func urlQuery() -> String {
        return "webapi/\(path)?api=\(api.rawValue)&version=\(version)&method=\(method)"
    }
    
    func asURLRequest() -> URLRequestConvertible {
        do {
            let urlString = SynologyKit.requestUrlString(path: urlQuery())
            let request = try URLRequest(url: urlString, method: .post, headers: headers)
            let encodedRequest = try URLEncoding.default.encode(request, with: params)
            return encodedRequest
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

enum SynologyMethod: String {
    case add
    case clear_invalid
    case clear_finished
    case clean
    case create
    case delete
    case download
    case edit
    case get
    case getinfo
    case list
    case list_share
    case login
    case logout
    case query
    case rename
    case start
    case status
    case stop
    case write
}

public struct SynologyAdditionalOptions: OptionSet {
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let realPath = SynologyAdditionalOptions(rawValue: 1 << 0)
    public static let size = SynologyAdditionalOptions(rawValue: 1 << 1)
    public static let owner = SynologyAdditionalOptions(rawValue: 1 << 2)
    public static let time = SynologyAdditionalOptions(rawValue: 1 << 3)
    public static let perm = SynologyAdditionalOptions(rawValue: 1 << 4)
    public static let mountPointType = SynologyAdditionalOptions(rawValue: 1 << 5)
    public static let volumeStatus = SynologyAdditionalOptions(rawValue: 1 << 6)
    public static let type = SynologyAdditionalOptions(rawValue: 1 << 7)
    public static let `default`: SynologyAdditionalOptions = [.size, .time, .type]
    
    func value() -> String {
        
        var result: [String] = []
        if self.contains(.realPath) {
            result.append("real_path")
        }
        if contains(.size) {
            result.append("size")
        }
        if contains(.owner) {
            result.append("owner")
        }
        if contains(.time) {
            result.append("time")
        }
        if contains(.perm) {
            result.append("perm")
        }
        if contains(.mountPointType) {
            result.append("mount_point_type")
        }
        if contains(.volumeStatus) {
            result.append("volume_status")
        }
        if contains(.type) {
            result.append("type")
        }
        return result.description
    }
}
