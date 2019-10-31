//
//  Constants.swift
//  SynologyKit
//
//  Created by xu.shuifeng on 2019/10/31.
//

import Foundation

public enum SynologyAPI: String {
    
    case auth = "SYNO.API.Auth"
    /// Provide File Station info.
    case info = "SYNO.API.Info"
    /// List all shared folders, enumerate files in a shared folder,
    /// and get detailed file information.
    case list = "SYNO.FileStation.List"
    /// Search files on given criteria.
    case search = "SYNO.FileStation.Search"
    /// List all mount point folders of virtual file system, ex: CIFS or ISO.
    case virtualFolder = "SYNO.FileStation.VirtualFolder"
    /// Add a folder to user’s favorites or do operations on user’s favorites.
    case favorite = "SYNO.FileStation.Favorite"
    /// Get a thumbnail of a file.
    case thumb = "SYNO.FileStation.Thumb"
    /// Get the total size of files/folders within folder(s).
    case dirSize = "SYNO.FileStation.DirSize"
    /// Get MD5 of a file.
    case md5 = "SYNO.FileStation.MD5"
    /// Check if the file/folder has a permission of a file/folder or not.
    case checkPermission = "SYNO.FileStation.CheckPermission"
    /// Upload a file.
    case upload = "SYNO.FileStation.Upload"
    /// Download files/folders.
    case download = "SYNO.FileStation.Download"
    /// Generate a sharing link to share files/folders with other
    /// people and perform operations on sharing links.
    case sharing = "SYNO.FileStation.Sharing"
    /// Create folder(s)
    case createFolder = "SYNO.FileStation.CreateFolder"
    /// Rename a file/folder.
    case rename = "SYNO.FileStation.Rename"
    /// Copy/Move files/folders.
    case copyMove = "SYNO.FileStation.CopyMove"
    /// Delete files/folders.
    case delete = "SYNO.FileStation.Delete"
    /// Extract an archive and do operations on an archive.
    case extract = "SYNO.FileStation.Extract"
    /// Compress files/folders.
    case compress = "SYNO.FileStation.Compress"
    /// Get information regarding tasks of file operations which
    /// are run as the background process including copy, move,
    /// delete, compress and extract tasks or perform operations
    /// on these background tasks
    case backgroundTask = "SYNO.FileStation.BackgroundTask"
}

public enum SynologyError: Int, CustomStringConvertible {
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

public enum SynologyFileSort: String {
    case name = "name"
    /// file owner
    case user = "user"
    /// file group
    case group = "group"
    ///  last modified time
    case lastModifiedtime = "mtime"
    ///  last access time
    case lastAccessTime = "atime"
    ///  last change time
    case lastChangeTime = "ctime"
    /// create time
    case createTime = "crtime"
    /// POSIX permission
    case posix = "posix"
}

public enum SynologyFileSortDirection: String {
    case ascending = "asc"
    case descending = "desc"
}
