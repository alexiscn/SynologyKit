//
//  Constants.swift
//  SynologyKit
//
//  Created by xu.shuifeng on 2019/10/31.
//

import Foundation

enum SynologyAPI: String {
    /// Perform login and logout.
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

struct SynologyCGI {
    static let entry = "entry.cgi"
    static let auth = "auth.cgi"
    static let query = "query.cgi"
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
    
    400: "No such account or incorrect password",
    401: "Account disabled",
    402: "Permission denied",
    403: "2-step verification code required",
    404: "Failed to authenticate 2-step verification code",
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
    case upload
    case query
    case rename
    case replace_all
    case start
    case status
    case stop
    case write
}
