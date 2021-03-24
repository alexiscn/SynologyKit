//
//  SynologyRequest.swift
//  SynologyKit
//
//  Created by xu.shuifeng on 20/09/2017.
//

import Foundation
import Alamofire

protocol SynologyRequest {
    
    var baseURLString: String { get set }
    
    var path: String { get }
    
    var params: Parameters { get set }
    
    var headers: HTTPHeaders? { get set }
    
    func asURLRequest() -> URLRequestConvertible
}

struct SynologyBasicRequest: SynologyRequest {
    
    var baseURLString: String
    
    /// path of the API. The path information can be retrieved by requesting SYNO.API.Info
    var path: String = SynologyCGI.entry
    
    /// Name of the API requested
    var api: SynologyAPI
    
    /// Method of the API requested
    var method: SynologyMethod
    
    var params: Parameters
    
    /// Version of the API requested
    var version: Int = 1
    
    var timeoutInterval: TimeInterval?
    
    var headers: HTTPHeaders?
    
    func urlQuery() -> String {
        return "webapi/\(path)?api=\(api.rawValue)&version=\(version)&method=\(method)"
    }
    
    func asURLRequest() -> URLRequestConvertible {
        do {
            let urlString = "\(baseURLString)webapi/\(path)"
            var parameter = params
            parameter["api"] = api.rawValue
            parameter["method"] = method.rawValue
            parameter["version"] = version
            let request = try URLRequest(url: urlString, method: .post, headers: headers)
            var encodedRequest = try URLEncoding.default.encode(request, with: parameter)
            if let interval = timeoutInterval {
                encodedRequest.timeoutInterval = interval
            }
            return encodedRequest
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func asURL(sessionID: String?) -> URL? {
        do {
            let urlString = "\(baseURLString)webapi/\(path)"
            var parameter = params
            parameter["api"] = api.rawValue
            parameter["method"] = method.rawValue
            parameter["version"] = version
            if let sid = sessionID {
                parameter["_sid"] = sid
            }
            let request = try URLRequest(url: urlString, method: .get, headers: headers)
            let encodedRequest = try URLEncoding.default.encode(request, with: parameter)
            return encodedRequest.url
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    init(baseURLString: String, api: SynologyAPI, method: SynologyMethod, params: Parameters) {
        self.baseURLString = baseURLString
        self.api = api
        self.method = method
        self.params = params
    }
}

struct QuickConnectRequest: SynologyRequest {
    
    var baseURLString: String
    
    var path: String
    
    var params: Parameters
    
    var headers: HTTPHeaders?
    
    func asURLRequest() -> URLRequestConvertible {
        do {
            let urlString = baseURLString + path
            let request = try URLRequest(url: urlString, method: .post, headers: headers)
            let encodedRequest = try JSONEncoding.default.encode(request, with: params)
            return encodedRequest
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

public extension SynologyClient {
    
    enum FileSortBy: String {
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
    
    enum FileSortDirection: String {
        case ascending = "asc"
        case descending = "desc"
    }
    
    struct AdditionalOptions: OptionSet {
        
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let realPath = AdditionalOptions(rawValue: 1 << 0)
        public static let size = AdditionalOptions(rawValue: 1 << 1)
        public static let owner = AdditionalOptions(rawValue: 1 << 2)
        public static let time = AdditionalOptions(rawValue: 1 << 3)
        public static let perm = AdditionalOptions(rawValue: 1 << 4)
        public static let mountPointType = AdditionalOptions(rawValue: 1 << 5)
        public static let volumeStatus = AdditionalOptions(rawValue: 1 << 6)
        public static let type = AdditionalOptions(rawValue: 1 << 7)
        public static let `default`: AdditionalOptions = [.size, .time, .type]
        
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

    enum VirtualFolderType: String {
        case cifs
        case iso
    }
    
    /// Compress level. default is moderate
    enum CompressLevel: String {
        /// moderate compression and normal compression speed
        case moderate
        /// pack files with no compress
        case store
        /// fastest compression speed but less compression
        case fastest
        /// slowest compression speed but optimal compression
        case best
    }
    
    /// CompressMode, default is add
    enum CompressMode: String {
        /// Update existing items and add new files. If an archive does not exist, a new one is created.
        case add
        /// Update existing items if newer on the file system and add new files. If the archive does not exist create a new archive.
        case update
        ///  Update existing items of an archive if newer on the file system. Does not add new files to the archive.
        case refreshen
        /// Update older files in the archive and add files that are not already in the archive.
        case synchronize
    }

    enum CompressFormat: String {
        case zip
        case sevenZ = "7z"
    }
    
    struct SearchOptions {
        
        public enum FileType: String {
            case file
            case directory
            case all
        }
        
        /// Optional. Search for files whose names and extensions match a case-insensitive glob pattern.
        /// Note:
        ///      1. If the pattern doesn’t contain any glob syntax (? and *), * of glob syntax will be
        ///      added at begin and end of the string automatically for partially matching the pattern
        ///      2. You can use “,” to separate multiple glob patterns.
        public var pattern: String? = nil
        
        /// Optional. Search for files whose extensions match a file type pattern in a case-insensitive glob pattern.
        /// If you give this criterion, folders aren’t matched.
        /// Note: You can use commas “,” to separate multiple glob patterns.
        public var `extension`: String? = nil
        
        /// Optional. “file”: enumerate regular files;
        ///           “dir”: enumerate folders;
        ///           “all” enumerate regular files and folders.
        public var fileType: FileType = .all
        
        /// Optional. Search for files whose sizes are greater than the given byte size.
        public var sizeFrom: Int64? = nil
        
        /// Optional. Search for files whose sizes are less than the given byte size.
        public var sizeTo: Int64? = nil
        
        /// Optional. Search for files whose last modified time after the given Linux timestamp in second.
        public var lastModifiedTimeFrom: TimeInterval? = nil
        
        /// Optional. Search for files whose last modified time before the given Linux timestamp in second.
        public var lastModifiedTimeTo: TimeInterval? = nil
        
        /// Optional. Search for files whose create time after the given Linux timestamp in second.
        public var createTimeFrom: TimeInterval? = nil
        
        /// Optional. Search for files whose create time before the given Linux timestamp in second.
        public var createTimeTo: TimeInterval? = nil
        
        /// Optional. Search for files whose last access time after the given Linux timestamp in second.
        public var lastAccesTimeFrom: TimeInterval? = nil
        
        /// Optional. Search for files whose last access time before the given Linux timestamp in second.
        public var lastAccessTimeTo: TimeInterval? = nil
        
        /// Optional. Search for files whose user name matches this criterion. This criterion is case-insensitive.
        public var owner: String? = nil
        
        /// Optional. Search for files whose group name matches this criterion. This criterion is case-insensitive.
        public var group: String? = nil
        
        public init() {}
    }
    
    enum FileThumbSize: String {
        case small
        case medium
        case large
        case original
    }
    
    enum FileThumbRotation: Int {
        case none = 0
        case rotate90 = 1
        case rotate180 = 2
        case rotate270 = 3
        case rotate360 = 4
    }
    
    struct ListOptions {
        public var offset: Int = 0
        public var limit: Int = 0
        public var sortBy: FileSortBy = .createTime
        public var sortDirection: FileSortDirection = .ascending
        
        func value() -> Parameters {
            return [
                "offset": offset,
                "limit": limit,
                "sort_by": sortBy.rawValue,
                "sort_direction": sortDirection.rawValue
            ]
        }
        
        public init() {}
    }
    
    enum BackgroundTaskFilter: String {
        case copyMove = "SYNO.FileStation.CopyMove"
        case delete = "SYNO.FileStatio n.Delete"
        case extract = "SYNO.FileStatio n.Extract"
        case compress = "SYNO.FileStatio n.Compress"
    }
    
    struct UploadOptions {
        /// Optional. The value could be one of following:
        /// true: overwrite the destination file if one exists
        /// false: skip the upload if the destination file exists
        /// nil: when it’s not specified as true or false, the upload will be responded with error when the destination file exists
        public var overwrite: Bool? = nil
        
        /// Optional. Set last modify time of the uploaded file, unit: Linux timestamp in millisecond.
        public var modificationTime: Int64? = nil
        
        /// Optional. Set the create time of the uploaded file, unit: Linux timestamp in millisecond.
        public var createTime: Int64? = nil
        
        /// Optional. Set last access time of the uploaded file, unit: Linux timestamp in millisecond.
        public var accessTime: Int64? = nil
        
        public init() { }
    }
    
    enum SharingSortBy: String {
        case id
        case name
        case isFolder
        case path
        case dateExpired = "date_expired"
        case dateAvailable = "date_available"
        case status
        case hasPassword = "has_password"
        case url
        case linkOwner = "link_owner"
    }
}
