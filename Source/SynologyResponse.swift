//
//  SynologyResponse.swift
//  SynologyKit
//
//  Created by xu.shuifeng on 20/09/2017.
//

import Foundation
import Alamofire

struct SynologyResponse<T>: Codable where T: Codable {
    public var success: Bool
    public var data: T?
    public var error: ErrorCode?
}

public struct ErrorCode: Codable {
    public let code: Int
}

public enum SynologyError: Error, CustomStringConvertible {
    case invalidResponse(AFDataResponse<Data?>)
    case decodeDataError(AFDataResponse<Data?>, String?)
    case serverError(Int, String, AFDataResponse<Data?>)
    case unknownError
    case uploadError(Error)
    
    public var description: String {
        switch self {
        case .invalidResponse(let res):
            debugPrint(res)
            return "Invalid Server Response"
        case .decodeDataError(let res, let html):
            debugPrint(res)
            if let html = html {
                debugPrint(html)
            }
            return "Decode Error"
        case .serverError(let code, let message, let res):
            debugPrint("Error Code:\(code), response: \(res)")
            return message
        case .unknownError:
            return "Unknown Error"
        case .uploadError(let error):
            return "Upload Error:\(error.localizedDescription)"
        }
    }
}

public struct QuickIDResponse: Codable {
    public let command: String
    public let version: Int
    public let errno: Int
    public let service: QuickIDService?
}

public struct QuickConnectResponse: Codable {
    public let command: String?
    public let env: QuickIDEnv?
    public let errno: Int
    public let server: QuickConnectServer?
    public let service: QuickIDService?
}

public struct QuickConnectServer: Codable {
    public let ddns: String?
    public let ds_state: String?

    public struct External: Codable {
        public let ip: String
        public let ipv6: String?
    }
    
    public let external: External?
    
    public let fqnd: String?
    
    public let gateway: String?
    
    public let interface: [ServerInterface]?
    
    public struct ServerInterface: Codable {
        public let ip: String
        public let mask: String
        public let name: String
    }
    
    public struct SeverIPV6: Codable {
        public let addr_type: Int?
        public let address: String?
        public let prefix_length: Int?
        public let scope: String?
    }
}

public struct QuickIDService: Codable {
    
    enum CodingKeys: String, CodingKey {
        case relayIP = "relay_ip"
        case relayPort = "relay_port"
        case env
        case port
    }
    
    public let relayIP: String?
    public let relayPort: Int?
    public let env: QuickIDEnv?
    public let port: Int?
}

public struct QuickIDEnv: Codable {
    
    enum CodingKeys: String, CodingKey {
        case relayRegion = "relay_region"
        case controlHost = "control_host"
    }
    
    let relayRegion: String
    let controlHost: String
}

public struct UploadResponse: Codable {
    
    public let success: Bool
    
    public let data: UploadFile?
    
    public let error: ErrorCode?
    
    public struct UploadFile: Codable {
        public let blSkip: Bool
        
        public let file: String
        
        public let pid: Int
        
        public let progress: Float
    }
}

public extension SynologyClient {
    
    struct AuthResponse: Codable {
        
        /// Authorized session ID. When the user log in with format=sid,
        /// cookie will not be set and each API request should provide a request parameter _sid=< sid> along with other parameters.
        public let sid: String
    }
    
    struct EmptyResponse: Codable { }
    
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
    
    struct FileStationAPIInfo: Codable {
        public let maxVersion: Int
        public let minVersion: Int
        public let path: String
        public let requestFormat: String
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
        public let name: String
        
        /// Shared-folder additional object.
        public let additional: FileAdditional?
        
        public func toFile() -> File {
            return File(path: path, name: name, isdir: isdir, children: nil, additional: additional)
        }
    }
    
    struct VirtualFolderList: Codable {
        /// Total number of mount point folders.
        public let total: Int
        
        /// Requested offset.
        public let offset: Int
        
        /// Array of <virtual folder> object.
        public let folders: [VirtualFolder]?
    }
    
    struct VirtualFolder: Codable {
        
        /// Path of a mount point folder
        public let path: String
        
        /// Name of a mount point folder
        public let name: String
        
        /// Virtual folder additional object.
        public let additional: FileAdditional?
    }
    
    enum FavoriteStatus: String, Codable {
        /// A folder, which a favorite links to, exists
        case valid
        /// A folder, which a favorite links to, doesn’t exist or be not permitted to access it.
        case broken
        /// Both valid and broken statuses
        case all
    }
    
    struct FavoriteList: Codable {
        /// Requested offset.
        public let total: Int
        /// Total number of favorites.
        public let offset: Int
        /// Array of <favorite> objects.
        public let favorites: [Favorite]?
    }
    
    struct Favorite: Codable {
        /// Folder path of a user’s favorites, started with a shared folder.
        public let path: String
        
        /// Favorite name
        public let name: String
        
        /// Favorite status
        public let status: FavoriteStatus
        
        /// Favorite additional object.
        public let additional: FileAdditional?
    }
    
    struct FolderOperationResponse: Codable {
        /// Array of <file> objects about file information of a new folder path.
        public let folders: [File]
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
        public let name: String
        
        /// If this file is folder or not
        public let isdir: Bool
        
        /// File list within a folder which is described by a <file> object.
        /// The value is returned, only if goto_path parameter is given
        public let children: Files?
        
        /// File additional object
        public let additional: FileAdditional?
    }
    
    struct FileAdditional: Codable {
        
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
    
    struct FileInfo: Codable {
        public let files: [File]
    }
    
    struct SharingLinkList: Codable {
        
        /// Total number of sharing links.
        public let total: Int
        
        /// Requested offset
        public let offset: Int
        
        /// Array of <Sharing_Link> object.
        public let links: [SharingLink]
    }
    
    struct SharingLink: Codable {
        
        public enum Status: String, Codable {
            case valid
            case invalid
            case expired
            case broken
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case url
            case linkOwner = "link_owner"
            case path
            case isFolder
            case hasPassword = "has_password"
            case dateExpired = "date_expired"
            case dateAvaiable = "date_available"
            case status
        }
        
        /// A unique ID of a sharing link
        public let id: String
        
        /// A URL of a sharing link.
        public let url: String
        
        /// A user name of a sharing link owner
        public let linkOwner: String
        
        /// A file or folder path of a sharing link
        public let path: String
        
        /// Whether the sharing link is for a folder
        public let isFolder: Bool
        
        /// Whether the sharing link has password
        public let hasPassword: Bool
        
        /// The expiration date of the sharing link in the format 1 YYYY-MM-DD.
        /// If the value is set to 0, the link will be permanent.
        public let dateExpired: String
        
        /// The date when the sharing link becomes active in the format YYYY-MM-DD.
        /// If the value is set to 0, the file sharing link will be active immediately after creation
        public let dateAvaiable: String
        
        public let status: Status
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
    
    struct BackgroundTaskList: Codable {
        
        /// Total number of background tasks.
        public let total: Int
        
        /// Requested offset.
        public let offset: Int
        
        /// Array of <background task> objects.
        public let tasks: [BackgroundTask]
    }
    
    struct BackgroundTask: Codable {
        
        /// Requested API name.
        public let api: String
        
        /// Requested API version.
        public let version: Int
        
        /// Requested API method.
        public let method: String
        
        /// A requested unique ID for the background task.
        public let taskid: String
        
        /// Whether or not the background task is finished.
        public let finished: Bool
    }
}
