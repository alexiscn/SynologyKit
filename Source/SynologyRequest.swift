//
//  SynologyRequest.swift
//  SynologyKit
//
//  Created by xu.shuifeng on 20/09/2017.
//

import Foundation

public struct SynologyRequest {
    
    var api: SynologyAPI
    
    var method: Method
    
    var version: Int
    
    var path: String
    
    func urlString() -> String {
        return "webapi/\(path)?api=\(api.rawValue)&version=\(version)&method=\(method)"
    }
    
    public enum Method: String {
        case get
        case query
        case add
        case create
        
        case list_share
        case list
        
        case download
        
        case login
        case logout
    }
}

public struct SynologyFileAdditionalOptions: OptionSet {
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let realPath = SynologyFileAdditionalOptions(rawValue: 1 << 0)
    public static let size = SynologyFileAdditionalOptions(rawValue: 1 << 1)
    public static let owner = SynologyFileAdditionalOptions(rawValue: 1 << 2)
    public static let time = SynologyFileAdditionalOptions(rawValue: 1 << 3)
    public static let perm = SynologyFileAdditionalOptions(rawValue: 1 << 4)
    public static let mountPointType = SynologyFileAdditionalOptions(rawValue: 1 << 5)
    public static let volumeStatus = SynologyFileAdditionalOptions(rawValue: 1 << 6)
    public static let type = SynologyFileAdditionalOptions(rawValue: 1 << 7)
    public static let `default`: SynologyFileAdditionalOptions = [.size, .time, .type]
    
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
