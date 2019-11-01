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

enum SynologyCGI: String {
    case entry = "entry.cgi"
    case auth = "auth.cgi"
    case query = "query.cgi"
    case info = "info.cgi"
    case fileShare = "file_share.cgi"
    case fileFind = "file_find.cgi"
    case fileVirtual = "file_virtual.cgi"
    case fileFavorite = "file_favorite.cgi"
    case fileThumb = "file_thumb.cgi"
    case fileDirSize = "file_dirSize.cgi"
    case fileMD5 = "file_md5.cgi"
    case filePermission = "file_permission.cgi"
    case fileDownload = "file_download.cgi"
    case fileSharing = "file_sharing.cgi"
    case file_crtfdr = "file_crtfdr.cgi"
    case fileRename = "file_rename.cgi"
    case fileMoveCopy = "file_MVCP.cgi"
    case fileDelete = "file_delete.cgi"
    case fileExtract = "file_extract.cgi"
    case fileCompress = "file_compress.cgi"
    case backgroundTask = "background_task.cgi"
    case apiUpload = "api_upload.cgi"
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
