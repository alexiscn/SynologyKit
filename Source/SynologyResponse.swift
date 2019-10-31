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
        
        /// Authorized session ID. When the user log in with format=sid,
        /// cookie will not be set and each API request should provide a request parameter _sid=< sid> along with other parameters.
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
        
        /// DSM host name
        public var hostname: String

        /// If the logged-in user can sharing file(s)/folder(s) or not.
        public var supportSharing: Bool
        
        /// If the logged-in user is an administrator.
        public var isManager: Bool
        
        /// Types of virtual file system which the logged user is able to mount on.
        /// DSM 4.3 supports CIFS and ISO of virtual file system.
        /// Different types are separated with a comma, for example: cifs,iso.
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
        
        /// Total number of shared folders.
        public let total: Int
        
        /// Requested offset.
        public let offset: Int
        
        /// Array of <shared folder> objects.
        public let shares: [SharedFolder]?
    }
    
    struct SharedFolder: SynologyKitProtocol {
        public let isdir: Bool
        
        /// Path of a shared folder.
        public let path: String
        
        /// Name of a shared folder.
        public let name: String?
        
        /// Shared-folder additional object.
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
        
        /// Real path of a shared folder in a volume space.
        public let realPath: String?
        
        /// <#Description#>
        public let size: Int?
        
        /// File owner information including user name, group name, UID and GID.
        public let owner: Owner?
        
        /// Time information of file including last access time, last modified time, last change time, and creation time.
        public let time: FileTime?
        
        /// Type of a virtual file system of a mount point
        public let mountPointType: String?
        
        /// Volume status including free space, total space and read-only status.
        public let volumeStatus: VolumeStatus?
        public let type: String?
    }

    struct VolumeStatus: SynologyKitProtocol {
        let freespace: Int
        let totalspace: Int
        let readonly: Bool
    }

    struct Owner: SynologyKitProtocol {
        
        /// User name of file owner.
        public let user: String
        
        /// Group name of file group.
        public let group: String
        
        /// File UID.
        public let uid: Int
        
        /// File GID
        public let gid: Int
    }

    struct FileTime: SynologyKitProtocol {
        
        enum CodingKeys: String, CodingKey {
            case accessTime = "atime"
            case modifiedTime = "mtime"
            case changedTime = "ctime"
            case createTime = "crtime"
        }
        
        /// Linux timestamp of last access in second.
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
