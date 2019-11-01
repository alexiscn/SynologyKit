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

let SynologyErrorMapper: [Int: String] = [
    100: "Unknown error",
    101: "No parameter of API, method or version",
    102: "The requested API does not exist",
    103: "The requested method does not exist",
    104: "The requested version does not support the functionality",
    105: "The logged in session does not have permission",
    106: "Session timeout",
    107: "Session interrupted by duplicate login",
    
    400: "Invalid parameter of file operation",
    401: "Unknown error of file operation",
    402: "System is too busy",
    403: "Invalid user does this file operation",
    404: "Invalid group does this file operation",
    405: "Invalid user and group does this file operation",
    406: "Can’t get user/group information from the account server",
    407: "Operation not permitted",
    408: "No such file or directory",
    409: "Non-supported file system ",
    410: "Failed to connect internet-based file system (ex: CIFS)",
    411: "Read-only file system",
    412: "Filename too long in the non-encrypted file system",
    413: "Filename too long in the encrypted file system",
    414: "File already exists",
    415: "Disk quota exceeded",
    416: "No space left on device",
    417: "Input/output error",
    418: "Illegal name or path",
    419: "Illegal file name",
    420: "Illegal file name on FAT file system",
    421: "Device or resource busy",
    599: "No such task of the file operation",
    
    800: "A folder path of favorite folder is already added to user’s favorites",
    801: "A name of favorite folder conflicts with an existing folder path in the user’s favorites",
    802: "There are too many favorites to be added",
    
    900: "Failed to delete file(s)/folder(s). More information in <errors> object",
    
    1000: "Failed to copy files/folders. More information in <errors> object",
    1001: "Failed to move files/folders. More information in <errors> object",
    1002: "An error occurred at the destination. More information in <errors> object",
    1003: "Cannot overwrite or skip the existing file because no overwrite parameter is given",
    1004: "File cannot overwrite a folder with the same name, or folder cannot overwrite a file with the same name",
    1006: "Cannot copy/move file/folder with special characters to a FAT32 file system",
    1007: "Cannot copy/move a file bigger than 4G to a FAT32 file system",
    
    1100: "Failed to create a folder. More information in <errors> object.",
    1101: "The number of folders to the parent folder would exceed the system limitation",
    
    1200: "Failed to rename it. More information in <errors> object",
    
    1300: "Failed to compress files/folders",
    1301: "Cannot create the archive because the given archive name is too long",
    
    1400: "Failed to extract files",
    1401: "Cannot open the file as archive",
    1402: "Failed to read archive data error",
    1403: "Wrong password",
    1404: "Failed to get the file and dir list in an archive",
    1405: "Failed to find the item ID in an archive file",
    
    1800: "There is no Content-Length information in the HTTP header or the received size doesn’t match the value of Content-Length information in the HTTP header",
    1801: "Wait too long, no date can be received from client (Default maximum wait time is 3600 seconds)",
    1802: "No filename information in the last part of file content",
    1803: "Upload connection is cancelled",
    1804: "Failed to upload too big file to FAT file system",
    1805: "Can’t overwrite or skip the existed file, if no overwrite parameter is given",
    
    2000: "Sharing link does not exist",
    2001: "Cannot generate sharing link because too many sharing links exist",
    2002: "Failed to access sharing links"
]

public enum SynologyError: Error {
    case invalidResponse(DefaultDataResponse)
    case decodeDataError(DefaultDataResponse, String?)
    case serverError(Int, String, DefaultDataResponse)
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

public extension SynologyClient {
    
    struct AuthResponse: Codable {
        
        /// Authorized session ID. When the user log in with format=sid,
        /// cookie will not be set and each API request should provide a request parameter _sid=< sid> along with other parameters.
        public let sid: String
    }
    
    struct EmptyResponse: Codable {
        
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
    
    /// Common Non-Blocking Task Response
    struct Task: Codable {
        public let taskid: String?
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
        public let additional: Additional?
        
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
        public let name: String?
        
        /// Virtual folder additional object.
        public let additional: Additional?
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
        public let additional: Additional?
    }
    
    struct Additional: Codable {
        
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
    
    struct DirectorySizeStatus: Codable {
        enum CodingKeys: String, CodingKey {
            case finished
            case numberOfDirectory = "num_dir"
            case numberOfFiles = "num_file"
            case totalSize = "total_size"
        }
        
        /// If the task is finished or not.
        public let finished: Bool
        
        /// Number of directories in the queried path(s).
        public let numberOfDirectory: Int
        
        /// Number of files in the queried path(s).
        public let numberOfFiles: Int
        
        /// Accumulated byte size of the queried path(s).
        public let totalSize: Int64
    }
    
    struct MD5Status: Codable {
        
        /// Check if the task is finished or not.
        public let finished: Bool
        
        /// MD5 of the requested file.
        public let md5: String?
    }
    
    struct CopyMoveStatus: Codable {
        enum CodingKeys: String, CodingKey {
            case processedSize = "processed_size"
            case total
            case path
            case finished
            case progress
            case destinationFolderPath = "dest_folder_path"
        }
        
        /// If accurate_progress parameter is “true,” byte sizes of all copied/moved files will be accumulated.
        /// If “false,” only byte sizes of the file you give in path parameter is accumulated.
        public let processedSize: Int64
        
        /// If accurate_progress parameter is “true,” the value indicates total byte sizes of files including subfolders will be copied/moved.
        /// If “false,” it indicates total byte sizes of files you give in path parameter excluding files within subfolders.
        /// Otherwise, when the total number is calculating, the value is -1.
        public let total: Int64
        
        /// A copying/moving path which you give in path parameter.
        public let path: String
        
        /// If the copy/move task is finished or not.
        public let finished: Bool
        
        /// A progress value is between 0~1. It is equal to processed_size parameter divided by total parameter.
        public let progress: Float
        
        /// A desitination folder path where files/folders are copied/moved.
        public let destinationFolderPath: String?
    }
    
    struct DeletionStatus: Codable {
        enum CodingKeys: String, CodingKey {
            case processdNumber = "processed_num"
            case total
            case path
            case processingPath = "processing_path"
            case finished
            case progress
        }
        
        /// If accurate_progress parameter is “true,” the number of all deleted files will be accumulated.
        /// If “false,” only the number of file you give in path parameter is accumulated.
        public let processdNumber: Int64
        
        /// If accurate_progress parameter is “true,” the value indicates how many files including subfolders will be deleted.
        /// If “false,” it indicates how many files you give in path parameter. When the total number is calculating, the value is -1.
        public let total: Int64
        
        /// A deletion path which you give in path parameter.
        public let path: String
        
        /// A deletion path which could be located at a subfolder.
        public let processingPath: String?
        
        /// Whether or not the deletion task is finished.
        public let finished: Bool
        
        /// Progress value whose range between 0~1 is equal to processed_num parameter divided by total parameter.
        public let progress: Float
    }
    
    struct ExtractStatus: Codable {
        
        enum CodingKeys: String, CodingKey {
            case finished
            case progress
            case destinationFolderPath = "dest_folder_path"
        }
        
        /// If the task is finished or not.
        public let finished: Bool
        
        /// The extract progress expressed in range 0 to 1.
        public let progress: Float
        
        /// The requested destination folder for the task.
        public let destinationFolderPath: String
    }
    
    struct CompressionStatus: Codable {
        enum CodingKeys: String, CodingKey {
            case finished
            case destinationFilePath = "dest_file_path"
        }
        
        /// Whether or not the compress task is finished.
        public let finished: Bool
        
        /// The requested destination path of an archive.
        public let destinationFilePath: String?
    }

}
