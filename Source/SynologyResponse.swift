//
//  SynologyResponse.swift
//  SynologyKit
//
//  Created by xu.shuifeng on 20/09/2017.
//

import Foundation
import Alamofire

public struct SynologyResponse<T>: Codable where T: Codable {
    public var success: Bool
    public var data: T?
    public var error: Int?
}

public enum SynologyError: Error {
    case invalidResponse(DefaultDataResponse)
    case decodeDataError(DefaultDataResponse, String?)
    case serverError(ErrorCode, DefaultDataResponse)
    
    public enum ErrorCode: Int, CustomStringConvertible {
        case unknown = 100
        case invalid = 101
        case noneExistAPI = 102
        case noneExistMethod = 103
        case notSupported = 104
        case permission = 105
        case sessionTimeout = 106
        case sessionInterupted = 107
        
        case invalidParameterOfFileOperation = 400
        case unknownErrorOfFileOperation = 401
        case systemTooBusy = 402
        case fileExist = 414
        case diskQuotaExceeded = 415
        case noSpaceLeft = 416
        case inputOutputError = 417
        case illegalNameOrPath = 418
        case illegalFileName = 419
        case deviceOrResourceBusy = 421
        case noSuchTaskOfFileOperation = 599
     
        public var description: String {
            switch self {
            case .unknown:
                return "Unknown error"
            case .invalid:
                return "No parameter of API, method or version"
            case .noneExistAPI:
                return "The requested API does not exist"
            case .noneExistMethod:
                return "The requested method does not exist"
            case .notSupported:
                return "The requested version does not support the functionality"
            case .permission:
                return "The logged in session does not have permission"
            case .sessionTimeout:
                return "Session timeout"
            case .sessionInterupted:
                return "Session interrupted by duplicate login"
            case .invalidParameterOfFileOperation:
                return "Invalid parameter of file operation"
            case .unknownErrorOfFileOperation:
                return "Unknown error of file operation"
            case .systemTooBusy:
                return "System is too busy"
            case .fileExist:
                return "File already exists"
            case .diskQuotaExceeded:
                return "Disk quota exceeded"
            case .noSpaceLeft:
                return "No space left on device"
            case .inputOutputError:
                return "Input/output error"
            case .illegalNameOrPath:
                return "Illegal name or path"
            case .illegalFileName:
                return "Illegal file name"
            case .deviceOrResourceBusy:
                return "Device or resource busy"
            case .noSuchTaskOfFileOperation:
                return "No such task of the file operation"
            }
        }
    }
}

public struct QuickIDResponse: Codable {
    public let command: String
    public let version: Int
    public let errno: Int
    public let service: QuickIDService?
}

public struct QuickIDService: Codable {
    
    enum CodingKeys: String, CodingKey {
        case relayIP = "relay_ip"
        case relayPort = "relay_port"
        case env
    }
    
    public let relayIP: String?
    public let relayPort: Int?
    public let env: QuickIDEnv?
}

public struct QuickIDEnv: Codable {
    
    enum CodingKeys: String, CodingKey {
        case relayRegion = "relay_region"
        case controlHost = "control_host"
    }
    
    let relayRegion: String
    let controlHost: String
}

public extension SynologyKit {
    
    struct AuthResponse: Codable {
        
        /// Authorized session ID. When the user log in with format=sid,
        /// cookie will not be set and each API request should provide a request parameter _sid=< sid> along with other parameters.
        public let sid: String
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
    
    struct SharedFolders: Codable {
        
        /// Total number of shared folders.
        public let total: Int
        
        /// Requested offset.
        public let offset: Int
        
        /// Array of <shared folder> objects.
        public let shares: [SharedFolder]?
    }
    
    struct SharedFolder: Codable {
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
    struct Files: Codable {
        
        /// Total number of files
        public let total: Int
        
        /// Requested offset
        public let offset: Int
        
        /// Array of <file> objects
        public let files: [File]?
    }

    struct File: Codable {
        
        /// Folder/file path started with a shared folder
        public let path: String
        
        /// File name
        public let name: String?
        
        /// If this file is folder or not
        public let isdir: Bool
        
        /// File list within a folder which is described by a <file> object.
        /// The value is returned, only if goto_path parameter is given
        public let children: Files?
        
        /// File additional object
        public let additional: Addition?
    }
    
    struct Addition: Codable {
        
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
        
        /// File size in bytes
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

    struct VolumeStatus: Codable {
        
        /// Byte size of free space of a volume where a shared folder is located.
        public let freespace: Int
        
        /// Byte size of total space of a volume where a shared folder is located.
        let totalspace: Int
        
        /// “true”: A volume where a shared folder is located isread-only;
        /// “false”: It’s writable.
        let readonly: Bool
    }

    struct Owner: Codable {
        
        /// User name of file owner.
        public let user: String
        
        /// Group name of file group.
        public let group: String
        
        /// File UID.
        public let uid: Int
        
        /// File GID
        public let gid: Int
    }

    struct FileTime: Codable {
        
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
