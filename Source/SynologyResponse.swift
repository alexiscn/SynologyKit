//
//  SynologyResponse.swift
//  SynologyKit
//
//  Created by xu.shuifeng on 20/09/2017.
//

import Foundation

public protocol SynologyKitProtocol: Codable {}

public struct SynologyKitError: Codable {
    public let code: Int
}

public struct SynologyKitResponse<T>: Codable where T: SynologyKitProtocol {
    public var success: Bool
    public var data: T?
    public var error: SynologyKitError?
}

public extension SynologyKit {
    
    struct AuthResponse: SynologyKitProtocol {
        public let sid: String
    }
    
    struct QuickIDResponse: Codable {
        public let command: String
        public let version: Int
        public let errno: Int
        public let service: QuickIDService?
    }
    
    struct FileStationInfo: Codable {
        
        enum CodingKeys: String, CodingKey {
            case hostname
            case isManager = "is_manager"
            case supportSharing = "support_sharing"
            case supportVirtualProtocol = "support_virtual_protocol"
        }
        
        public var hostname: String
        public var supportSharing: Bool
        public var isManager: Bool
        public var supportVirtualProtocol: Bool
    }
    
    struct QuickIDService: Codable {
        
        enum CodingKeys: String, CodingKey {
            case relayIP = "relay_ip"
            case relayPort = "relay_port"
            case env
        }
        
        public let relayIP: String?
        public let relayPort: Int?
        public let env: QuickIDEnv?
    }
    
    struct QuickIDEnv: Codable {
        
        enum CodingKeys: String, CodingKey {
            case relayRegion = "relay_region"
            case controlHost = "control_host"
        }
        
        let relayRegion: String
        let controlHost: String
    }

    struct SharedFolders: SynologyKitProtocol {
        public let total: Int
        public let offset: Int
        public let shares: [SharedFolder]?
    }
    
    struct SharedFolder: SynologyKitProtocol {
        public let isdir: Bool
        public let path: String
        public let name: String?
        public let additional: Addition?
        
        public func toFile() -> File {
            return File(path: path, name: name, isdir: isdir, children: nil, additional: additional)
        }
    }
    struct Files: SynologyKitProtocol {
        public let total: Int
        public let offset: Int
        public let files: [File]?
    }

    struct File: SynologyKitProtocol {
        public let path: String
        public let name: String?
        public let isdir: Bool
        public let children: FileChildren?
        public let additional: Addition?
    }

    struct FileChildren: SynologyKitProtocol {
        public let total: Int
        public let offset: Int
        public let files: [File]?
    }

    struct Addition: SynologyKitProtocol {
        
        enum CodingKeys: String, CodingKey {
            case realPath = "real_path"
            case size
            case owner
            case time
            case mountPointType = "mount_point_type"
            case volumeStatus = "volume_status"
            case type
        }
        
        public let realPath: String?
        public let size: Int?
        public let owner: Owner?
        public let time: FileTime?
        public let mountPointType: String?
        public let volumeStatus: VolumeStatus?
        public let type: String?
    }

    struct VolumeStatus: SynologyKitProtocol {
        let freespace: Int
        let totalspace: Int
        let readonly: Bool
    }

    struct Owner: SynologyKitProtocol {
        public let user: String
        public let group: String
        public let uid: Int
        public let gid: Int
    }

    struct FileTime: SynologyKitProtocol {
        
        enum CodingKeys: String, CodingKey {
            case accessTime = "atime"
            case modifiedTime = "mtime"
            case changedTime = "ctime"
            case createTime = "crtime"
        }
        
        let accessTime: TimeInterval?
        public var accessDate: Date? {
            return Date(timeIntervalSince1970: accessTime ?? 0)
        }
        
        let modifiedTime: TimeInterval?
        public var modifiedDate: Date? {
            return Date(timeIntervalSince1970: modifiedTime ?? 0)
        }
        
        let changedTime: TimeInterval?
        public var changedDate: Date? {
            return Date()
        }
        
        let createTime: TimeInterval?
        public var createDate: Date? {
            return Date()
        }
    }

}
