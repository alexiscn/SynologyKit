//
//  SynologyClient.swift
//  SynologyKit
//
//  Created by xu.shuifeng on 19/09/2017.
//

import Foundation
import Alamofire

#if os(iOS) || os(watchOS) || os(tvOS)
import MobileCoreServices
#elseif os(macOS)
import CoreServices
#endif

// https://global.download.synology.com/download/Document/DeveloperGuide/Synology_File_Station_API_Guide.pdf

public typealias SynologyCompletion<T: Codable> = (Swift.Result<T, SynologyError>) -> Void

public typealias SynologyStreamCompletion = (Swift.Result<Data, SynologyError>) -> Void

/// Non-blocking api request progress callback
public typealias SynologyProgressHandler<T: SynologyTask> = ((T) -> Void)?

public typealias GlobalQuickConnectCompletion = (Swift.Result<QuickConnectResponse, SynologyError>) -> Void

public typealias QuickIDCompletion = (Swift.Result<QuickIDResponse, SynologyError>) -> Void

/// SynologyKit for File Station
public class SynologyClient {
    
    public var userAgent = "DS audio 5.13.2 rv:323 (iPhone; iOS 11.0; en_CN)"
    
    public var sessionid: String?
    
    public var connected: Bool { return sessionid != nil }
    
    private var host: String
    private var port: Int?
    private var enableHTTPS = false
    private let Session = "FileStation"
    private let queue = DispatchQueue(label: "me.shuifeng.SynologyKit", qos: .background, attributes: .concurrent)
    
    func baseURLString() -> String {
        let scheme = enableHTTPS ? "https": "http"
        if let port = port {
            return "\(scheme)://\(host):\(port)/"
        }
        return "\(scheme)://\(host)/"
    }
    
    /// Init a client
    /// - Parameters:
    ///   - host: IP or QuickConnect ID
    ///   - port: port
    ///   - enableHTTPS: enableHTTPS, default is false.
    public init(host: String, port: Int? = nil, enableHTTPS: Bool = false) {
        self.host = host
        self.port = port
        self.enableHTTPS = enableHTTPS
    }
    
    public func updateSessionID(_ sessionID: String) {
        self.sessionid = sessionID
    }
    
    func post<T: Codable>(_ request: SynologyRequest, completion: @escaping SynologyCompletion<T>) {
        var _request = request
        if let sessionId = sessionid {
            var parameters = request.params
            parameters["_sid"] = sessionId
            _request.params = parameters
        }
        queue.async {
            AF.request(_request.asURLRequest()).response { response in
                self.handleDataResponse(response, completion: completion)
            }
        }
    }
    
    func getStreamData(_ request: SynologyRequest, completion: @escaping SynologyStreamCompletion) {
        var actualRequest = request
        if let sessionId = sessionid {
            var parameters = request.params
            parameters["_sid"] = sessionId
            actualRequest.params = parameters
        }
        queue.async {
            AF.request(actualRequest.asURLRequest()).response { response in
                if let error = response.error {
                    let code = response.response?.statusCode ?? -1
                    completion(.failure(.serverError(code, error.localizedDescription, response)))
                    return
                }
                guard let data = response.data else {
                    completion(.failure(.invalidResponse(response)))
                    return
                }
                completion(.success(data))
            }
        }
    }
    
    func handleDataResponse<T>(_ response: AFDataResponse<Data?>, completion: @escaping SynologyCompletion<T>) {
        if let error = response.error {
            let code = response.response?.statusCode ?? -1
            completion(.failure(.serverError(code, error.localizedDescription, response)))
            return
        }
        guard let data = response.data else {
            completion(.failure(.invalidResponse(response)))
            return
        }
        do {
            let decodedRes = try JSONDecoder().decode(SynologyResponse<T>.self, from: data)
            if let data = decodedRes.data {
                completion(.success(data))
            } else if let error = decodedRes.error {
                let message = SynologyErrorMapper[error.code] ?? "Unknown error"
                completion(.failure(.serverError(error.code, message, response)))
            }
        } catch {
            let text = String(data: data, encoding: .utf8)
            completion(.failure(.decodeDataError(response, text)))
        }
    }
    
    private func mimeType(forPathExtension pathExtension: String) -> String {
        if let id = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue(),
            let contentType = UTTypeCopyPreferredTagWithClass(id, kUTTagClassMIMEType)?.takeRetainedValue()
        {
            return contentType as String
        }
        return "application/octet-stream"
    }
}

// MARK: - Public functions
extension SynologyClient {
    
    func getServerAPIInfo(completion: @escaping SynologyCompletion<String>) {
        let parameters = ["query": "SYNO.API.Auth,SYNO.FileStation."]
        var request = SynologyBasicRequest(baseURLString: baseURLString(), api: .info, method: .query, params: parameters)
        request.path = SynologyCGI.query
        post(request, completion: completion)
    }
    
    /// Login to your synology
    /// - Parameters:
    ///   - account: Login account name.
    ///   - passwd: Login account password.
    ///   - completion: Callback closure.
    public func login(account: String, passwd: String, completion: @escaping SynologyCompletion<AuthResponse>) {
        
        if host.contains(".") {
            var parameters: Parameters = [:]
            parameters["account"] = account
            parameters["passwd"] = passwd
            parameters["session"] = Session
            var request = SynologyBasicRequest(baseURLString: baseURLString(), api: .auth, method: .login ,params: parameters)
            request.path = SynologyCGI.auth
            request.version = 3
            post(request, completion: completion)
            return
        } else {
            loginViaQuickID(host, account: account, password: passwd, completion: completion)
        }
    }
    
    // try inner login first
    private func tryInnerLogin(account: String, passwd: String, relayIP: String, relayPort: Int, completion: @escaping SynologyCompletion<AuthResponse>) {
        var parameters: Parameters = [:]
        parameters["account"] = account
        parameters["passwd"] = passwd
        parameters["session"] = Session
        var request = SynologyBasicRequest(baseURLString: baseURLString(), api: .auth, method: .login ,params: parameters)
        request.path = SynologyCGI.auth
        request.version = 3
        request.timeoutInterval = 15
        post(request) { (result: Result<AuthResponse, SynologyError>) in
            switch result {
            case .failure(_):
                self.host = relayIP
                self.port = relayPort
                self.login(account: account, passwd: passwd, completion: completion)
            case .success(let res):
                completion(.success(res))
            }
        }
    }
    
    private func loginViaQuickID(_ quickID: String, account: String, password: String, completion: @escaping SynologyCompletion<AuthResponse>) {
        getGlobalServerInfo(quickID: host) { response in
            switch response {
            case .success(let connect):
                if let inter = connect.server?.interface?.first, let p = connect.service?.port,
                   let relayIP = connect.service?.relayIP, let relayPort = connect.service?.relayPort {
                    self.host = inter.ip
                    self.port = p
                    self.tryInnerLogin(account: account, passwd: password, relayIP: relayIP, relayPort: relayPort, completion: completion)
                } else if let h = connect.service?.relayIP, let p = connect.service?.relayPort {
                    self.host = h
                    self.port = p
                    self.login(account: account, passwd: password, completion: completion)
                } else if let controlHost = connect.env?.controlHost {
                    self.getServerInfo(server: controlHost, quickID: quickID) { quickIDRes in
                        switch quickIDRes {
                        case .success(let connectResponse):
                            if let h = connectResponse.service?.relayIP, let p = connectResponse.service?.relayPort {
                                self.host = h
                                self.port = p
                                self.login(account: account, passwd: password, completion: completion)
                            } else {
                                completion(.failure(.unknownError))
                            }
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                } else {
                    completion(.failure(.unknownError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Logout
    /// - Parameters:
    ///   - completion: Callback closure.
    public func logout(completion: @escaping SynologyCompletion<EmptyResponse>) {
        let params = ["session": Session]
        var request = SynologyBasicRequest(baseURLString: baseURLString(), api: .auth, method: .logout, params: params)
        request.path = SynologyCGI.auth
        post(request, completion: completion)
    }
    
    /// Provide File Station information
    /// - Parameter completion: Callback closure.
    public func getInfo(completion: @escaping SynologyCompletion<FileStationInfo>) {
        let request = SynologyBasicRequest(baseURLString: baseURLString(), api: .info, method: .getinfo, params: Parameters())
        post(request, completion: completion)
    }
    
    /// List all shared folders, enumerate files in a shared folder, and get detailed file information.
    /// - Parameter offset: Optional. Specify how many shared folders are skipped before beginning to return listed shared folders.
    /// - Parameter limit: Optional. Number of shared folders requested. 0 lists all shared folders.
    /// - Parameter sortBy: Optional. Specify which file information to sort on.
    /// - Parameter sortDirection: Optional. Specify to sort ascending or to sort descending.
    /// - Parameter additional: Optional. Additional requested file information, separated by commas “,”. When an additional option is requested, responded objects will be provided in the specified additional option.
    /// - Parameter completion: callback closure.
    public func listShareFolders(offset: Int = 0,
                                       limit: Int = 0,
                                       sortBy: FileSortBy = .name,
                                       sortDirection: FileSortDirection = .ascending,
                                       additional: AdditionalOptions = .default,
                                       completion: @escaping SynologyCompletion<SharedFolders>) {
        var params: Parameters = [:]
        params["offset"] = offset
        params["limit"] = limit
        params["sort_by"] = sortBy.rawValue
        params["sort_direction"] = sortDirection.rawValue
        params["additional"] = additional.value()
        var request = SynologyBasicRequest(baseURLString: baseURLString(), api: .list, method: .list_share, params: params)
        request.version = 2
        post(request, completion: completion)
    }
    
    /// Enumerate files in a given folder
    /// - Parameter folder: A listed folder path started with a shared folder.
    /// - Parameter offset: Optional. Specify how many files are skipped before beginning to return listed files. Default value is 0.
    /// - Parameter limit: Optional. Number of files requested. 0 indicates to list all files with a given folder. Default value is 0.
    /// - Parameter sortBy: Optional. Specify which file information to sort on. Default value is `name`.
    /// - Parameter sortDirection: Optional. Specify to sort ascending or to sort descending. Default value is `asc`.
    /// - Parameter additional: Optional. Additional requested file information, separated by commas “,”. When an additional option is requested, responded objects will be provided in the specified additional option.
    /// - Parameter completion: callback closure.
    public func listFolder(_ folder: String,
                                 offset: Int = 0,
                                 limit: Int = 0,
                                 sortBy: FileSortBy = .name,
                                 sortDirection: FileSortDirection = .ascending,
                                 additional: AdditionalOptions = .default,
                                 completion: @escaping SynologyCompletion<Files>) {
        var params: Parameters = [:]
        params["folder_path"] = folder
        params["offset"] = offset
        params["limit"] = limit
        params["sort_by"] = sortBy.rawValue
        params["sort_direction"] = sortDirection.rawValue
        params["additional"] = additional.value()
        var request = SynologyBasicRequest(baseURLString: baseURLString(), api: .list, method: .list, params: params)
        request.version = 2
        post(request, completion: completion)
    }
    
    /// Get information of file(s)
    /// - Parameters:
    ///   - path: One or more folder/file path(s) started with a shared folder, separated by a comma, “,”.
    ///   - additional: Optional. Additional requested file information, separated by a comma, “,”.
    ///           When an additional option is requested, responded objects will be provided in the specified additional option.
    ///   - completion: Callback closure.
    public func getFileInfo(atPath path: String, additional: AdditionalOptions? = nil, completion: @escaping SynologyCompletion<FileInfo>) {
        var parameters = Parameters()
        parameters["path"] = path
        if let options = additional {
            parameters["additional"] = options.value()
        }
        let request = SynologyBasicRequest(baseURLString: baseURLString(), api: .list, method: .getinfo, params: parameters)
        post(request, completion: completion)
    }
    
    /// Search files according to given criteria
    /// - Parameters:
    ///   - folderPath: A searched folder path starting with a shared folder.
    ///   - options: Search options.
    ///   - recursive: Optional. If searching files within a folder and subfolders recursively or not.
    public func search(atFolderPath folderPath: String, options: SearchOptions, recursive: Bool = true, completion: @escaping SynologyCompletion<SearchFileTask>) {
        var parameters = Parameters()
        parameters["folder_path"] = folderPath
        parameters["recursive"] = recursive
        if let pattern = options.pattern {
            parameters["pattern"] = pattern
        }
        if let ext = options.extension {
            parameters["extension"] = ext
        }
        parameters["filetype"] = options.fileType.rawValue
        if let sizeFrom = options.sizeFrom {
            parameters["size_from"] = sizeFrom
        }
        if let sizeTo = options.sizeTo {
            parameters["size_to"] = sizeTo
        }
        if let modifiyTimeFrom = options.lastModifiedTimeFrom {
            parameters["mtime_from"] = modifiyTimeFrom
        }
        if let modifiyTimeTo = options.lastModifiedTimeTo {
            parameters["mtime_to"] = modifiyTimeTo
        }
        if let createTimeFrom = options.createTimeFrom {
            parameters["crtime_from"] = createTimeFrom
        }
        if let createTimeTo = options.createTimeTo {
            parameters["crtime_to"] = createTimeTo
        }
        if let accessTimeFrom = options.lastAccesTimeFrom {
            parameters["atime_from"] = accessTimeFrom
        }
        if let accessTimeTo = options.lastAccessTimeTo {
            parameters["atime_to"] = accessTimeTo
        }
        if let owner = options.owner {
            parameters["owner"] = owner
        }
        if let group = options.group {
            parameters["group"] = group
        }
        let request = SynologyBasicRequest(baseURLString: baseURLString(), api: .search, method: .start, params: parameters)
        postNonBlockingRequest(request, completion: completion, method: .list)
    }
    
    /// List all mount point folders on one given type of virtual file system
    /// - Parameter type: A type of virtual file systems, ex: CIFS or ISO.
    /// - Parameter offset: Optional. Specify how many mount point folders are skipped before
    /// beginning to return listed mount point folders in virtual file system.
    /// - Parameter limit: Optional. Number of mount point folders requested. 0 indicates to list all mount point folders in virtual file system.
    /// - Parameter sortBy: Optional. Specify which file information to sort on.
    /// - Parameter direction: Optional. Specify to sort ascending or to sort descending.
    /// - Parameter additional: Optional. Additional requested file information, separated by a comma, “,”. When an additional option is requested, responded objects will be provided in the specified additional option
    /// - Parameter completion: Callback closure.
    public func listVirtualFolder(type: VirtualFolderType, offset: Int = 0, limit: Int = 0, sortBy: FileSortBy = .name, direction: FileSortDirection = .ascending, additional: AdditionalOptions? = nil, completion: @escaping SynologyCompletion<VirtualFolderList>) {
        var params: Parameters = [:]
        params["type"] = type.rawValue
        params["offset"] = offset
        params["limit"] = limit
        params["sort_by"] = sortBy.rawValue
        params["sort_direction"] = direction.rawValue
        if let additional = additional {
            params["additional"] = additional.value()
        }
        let request = SynologyBasicRequest(baseURLString: baseURLString(), api: .virtualFolder, method: .list, params: params)
        post(request, completion: completion)
    }
    
    /// List user’s favorites
    /// - Parameters:
    ///   - offset: Optional. Specify how many favorites are skipped before beginning to return user’s favorites.
    ///   - limit: Optional. Number of favorites requested. 0 indicates to list all favorites.
    ///   - statusFilter: Optional. Show favorites with a given favorite status.
    ///   - additional: Optional. Additional requested information of a folder which a favorite links to, separated by a comma, “,”.
    ///                 When an additional option is requested, responded objects will be provided in the specified additional option.
    ///   - completion: Callback closure.
    public func listFavorites(offset: Int = 0, limit: Int = 0, statusFilter: FavoriteStatus = .all, additional: AdditionalOptions? = nil, completion: @escaping SynologyCompletion<FavoriteList>) {
        var parameters = Parameters()
        parameters["offset"] = offset
        parameters["limit"] = limit
        parameters["status_filter"] = statusFilter.rawValue
        if let additional = additional {
            parameters["additional"] = additional.value()
        }
        let request = SynologyBasicRequest(baseURLString: baseURLString(), api: .favorite, method: .list, params: parameters)
        post(request, completion: completion)
    }
    
    /// Add a folder to user’s favorites
    /// - Parameters:
    ///   - path: A folder path starting with a shared folder is added to the user’s favorites.
    ///   - name: A favorite name.
    ///   - index: Optional. Index of location of an added favorite.
    ///            If it’s equal to -1, the favorite will be added to the last one in user’s favoirete.
    ///            If it’s between 0 ~ total number of favorites-1, the favorite will be inserted into user’s favorites by the index.
    ///   - completion: Callback closure.
    public func addFavorite(path: String, name: String, index: Int = -1, completion: @escaping SynologyCompletion<EmptyResponse>) {
        var parameters = Parameters()
        parameters["path"] = path
        parameters["name"] = name
        parameters["index"] = index
        let request = SynologyBasicRequest(baseURLString: baseURLString(), api: .favorite, method: .add, params: parameters)
        post(request, completion: completion)
    }
    
    /// Delete a favorite in user’s favorites.
    /// - Parameters:
    ///   - path: A folder path starting with a shared folder is deleted from a user’s favorites.
    ///   - completion: Callback closure.
    public func deleteFavorite(path: String, completion: @escaping SynologyCompletion<EmptyResponse>) {
        var parameters = Parameters()
        parameters["path"] = path
        let request = SynologyBasicRequest(baseURLString: baseURLString(), api: .favorite, method: .delete, params: parameters)
        post(request, completion: completion)
    }
    
    /// Delete all broken statuses of favorites.
    /// - Parameter completion: Callback closure.
    public func clearBrokenFavorites(completion: @escaping SynologyCompletion<EmptyResponse>) {
        let request = SynologyBasicRequest(baseURLString: baseURLString(), api: .favorite, method: .clean, params: Parameters())
        post(request, completion: completion)
    }
    
    /// Edit a favorite name
    /// - Parameters:
    ///   - path: A folder path starting with a shared folder is edited from a user’s favorites.
    ///   - name: New favorite name.
    ///   - completion: Callback closure.
    public func editFavorite(path: String, name: String, completion: @escaping SynologyCompletion<EmptyResponse>) {
        var parameters = Parameters()
        parameters["path"] = path
        parameters["name"] = name
        let request = SynologyBasicRequest(baseURLString: baseURLString(), api: .favorite, method: .edit, params: parameters)
        post(request, completion: completion)
    }
    
    /// Replace multiple favorites of folders to the existed user’s favorites
    /// - Parameters:
    ///   - path: One or more folder paths starting with a shared folder, separated by a comma “,” is added to the user’s favorites.
    ///           The number of paths must be the same as the number of favorite names in the name parameter.
    ///           The first path parameter corresponds to the first name parameter.
    ///   - name: One or more new favrorite names, separated by a comma “, “.
    ///           The number of favorite names must be the same as the number of folder paths in the path parameter.
    ///           The first name parameter corresponding to the first path parameter.
    ///   - completion: Callback closure.
    public func replaceAllFavorite(path: String, name: String, completion: @escaping SynologyCompletion<EmptyResponse>) {
        var parameters = Parameters()
        parameters["path"] = path
        parameters["name"] = name
        let request = SynologyBasicRequest(baseURLString: baseURLString(), api: .favorite, method: .replace_all, params: parameters)
        post(request, completion: completion)
    }
    
    /// Get a thumbnail of a file.
    /// Note:
    ///      1. Supported image formats: jpg, jpeg, jpe, bmp, png, tif, tiff, gif, arw, srf, sr2, dcr, k25, kdc, cr2, crw, nef,
    ///         mrw, ptx, pef, raf, 3fr, erf, mef, mos, orf, rw2, dng, x3f, raw
    ///      2. Supported video formats in an indexed folder: 3gp, 3g2, asf, dat, divx, dvr-ms, m2t, m2ts, m4v,mkv, mp4, mts,
    ///         mov, qt, tp, trp, ts, vob, wmv, xvid, ac3, amr, rm, rmvb, ifo, mpeg, mpg, mpe, m1v, m2v, mpeg1, mpeg2, mpeg4,
    ///         ogv, webm, flv, f4v, avi, swf, vdr, iso
    ///         PS: Video thumbnails exist only if video files are placed in the “photo” shared folder or users' home folders.
    /// - Parameters:
    ///   - path: A file path started with a shared folder.
    ///   - size: Optional. Return different size thumbnail.
    ///   - rotate: Optional. Return rotated thumbnail.
    ///   - completion: Callback closure.
    public func getThumbOfFile(path: String, size: FileThumbSize = .small, rotate: FileThumbRotation = .none, completion: @escaping SynologyStreamCompletion) {
        var parameters = Parameters()
        parameters["path"] = path
        parameters["size"] = size.rawValue
        parameters["rotate"] = rotate.rawValue
        let request = SynologyBasicRequest(baseURLString: baseURLString(), api: .thumb, method: .get, params: parameters)
        getStreamData(request, completion: completion)
    }
    
    
    /// Get a thumbnail URL of a file.
    /// - Parameters:
    ///   - path: A file path started with a shared folder.
    ///   - size: Different size thumbnail
    public func thumbURL(path: String, size: FileThumbSize = .small) -> URL? {
        var parameters = Parameters()
        parameters["path"] = path
        parameters["size"] = size.rawValue
        let request = SynologyBasicRequest(baseURLString: baseURLString(), api: .thumb, method: .get, params: parameters)
        return request.asURL(sessionID: sessionid)
    }
    
    /// Get the file download url
    /// - Parameters:
    ///   - path: A file started with a shared folder.
    ///   - filename: The name of the file.
    /// - Returns: An url for download or play usage.
    public func fileDownloadURL(atPath path: String, filename: String) -> URL? {
        guard let data = path.data(using: .utf8), let sessionId = sessionid else {
            return nil
        }
        let dlink = "\"" + data.map { String(format: "%02.2hhx", $0) }.joined().uppercased() + "\""
        let nameEncoded = Alamofire.URLEncoding.default.escape(filename)
        let dlinkEncoded = URLEncoding.default.escape(dlink)
        let sidEncoded = URLEncoding.default.escape(sessionId)
        let urlString = "\(baseURLString())fbdownload/\(nameEncoded)?dlink=\(dlinkEncoded)&_sid=\(sidEncoded)&mime=1"
        return URL(string: urlString)
    }
    
    /// Get the accumulated size of files/folders within folder(s).
    /// - Parameters:
    ///   - path: One or more file/folder paths starting with a shared folder for calculating cumulative size, separated by a comma, “,”.
    ///   - completion: Callback closure.
    public func getDirectorySize(atPath path: String, completion: @escaping SynologyCompletion<DirectorySizeTask>) {
        var parameters = Parameters()
        parameters["path"] = path
        let request = SynologyBasicRequest(baseURLString: baseURLString(), api: .dirSize, method: .start, params: parameters)
        postNonBlockingRequest(request, completion: completion)
    }
    
    /// Get MD5 of a file.
    /// - Parameters:
    ///   - filePath: A file path starting with a shared folder for calculating MD5 value.
    ///   - completion: Callback closure.
    public func md5(ofFile filePath: String, completion: @escaping SynologyCompletion<MD5Task>) {
        var parameters = Parameters()
        parameters["file_path"] = filePath
        let request = SynologyBasicRequest(baseURLString: baseURLString(), api: .md5, method: .start, params: parameters)
        postNonBlockingRequest(request, completion: completion)
    }
    
    /// Check if a logged-in user has a permission to do file operations on a given folder/file.
    /// - Parameters:
    ///   - path: A folder path starting with a shared folder to check write permission.
    ///   - createOnly: Optional. True by default. If set to true, the permission will be allowed when there is non-existent file/folder.
    ///   - completion: Callback closure.
    public func checkPermission(path: String, createOnly: Bool = true, completion: @escaping SynologyCompletion<EmptyResponse>) {
        var parameters = Parameters()
        parameters["path"] = path
        parameters["create_only"] = createOnly
        let request = SynologyBasicRequest(baseURLString: baseURLString(), api: .checkPermission, method: .write, params: parameters)
        post(request, completion: completion)
    }
    
    /// Upload a file.
    /// - Parameters:
    ///   - data: The data to be uploaded.
    ///   - filename: File name.
    ///   - destinationFolderPath: A destination folder path starting with a shared folder to which files can be uploaded
    ///   - createParents: Create parent folder(s) if none exist.
    ///   - options: Upload options.
    ///   - progressHandler: The upload progress handler.
    ///   - completion: Callback Closure.
    public func upload(data: Data, filename: String, destinationFolderPath: String, createParents: Bool, options: UploadOptions? = nil, progressHandler: UploadRequest.ProgressHandler? = nil, completion: @escaping SynologyCompletion<UploadResponse>) {
        
        struct UploadParam {
            var key: String
            var value: String
        }
        var parameters: [UploadParam] = []
        parameters.append(UploadParam(key: "path", value: destinationFolderPath))
        parameters.append(UploadParam(key: "create_parents", value: String(createParents)))
        
        if let options = options {
            if let overwrite = options.overwrite {
                parameters.append(UploadParam(key: "overwrite", value: String(overwrite)))
            }
            if let mtime = options.modificationTime {
                parameters.append(UploadParam(key: "mtime", value: String(mtime)))
            }
            if let crtime = options.createTime {
                parameters.append(UploadParam(key: "crtime", value: String(crtime)))
            }
            if let atime = options.accessTime {
                parameters.append(UploadParam(key: "atime", value: String(atime)))
            }
        }
        
        var urlString = baseURLString().appending("webapi/entry.cgi?api=\(SynologyAPI.upload.rawValue)&method=upload&version=2")
        if let sid = self.sessionid {
            urlString = urlString.appending("&_sid=\(sid)")
        }
        let url = URL(string: urlString)!
        
        let multipart: (MultipartFormData) -> Void = { formData in
            for param in parameters {
                formData.append(Data(param.value.utf8), withName: param.key)
            }
            let mimeType: String
            if filename.contains(".") {
                let pathExtension = String(filename.split(separator: ".").last!)
                mimeType = self.mimeType(forPathExtension: pathExtension)
            } else {
                mimeType = "application/octet-stream"
            }
            formData.append(data, withName: "file", fileName: filename, mimeType: mimeType)
        }
        
        AF.upload(multipartFormData: multipart, to: url)
            .uploadProgress { p in
                progressHandler?(p)
            }
            .response { response in
                guard let data = response.data else {
                    completion(.failure(.invalidResponse(response)))
                    return
                }
                do {
                    let decodedRes = try JSONDecoder().decode(UploadResponse.self, from: data)
                    if decodedRes.success {
                        completion(.success(decodedRes))
                    } else {
                        let code = decodedRes.error?.code ?? -1
                        let msg = SynologyErrorMapper[code] ?? "Unknow error"
                        completion(.failure(.serverError(code, msg, response)))
                    }
                } catch {
                    let text = String(data: data, encoding: .utf8)
                    completion(.failure(.decodeDataError(response, text)))
                }
            }
    }
    
    public func downloadFile(path: String, to: @escaping DownloadRequest.Destination) -> DownloadRequest {
        let params = ["path": path, "mode": "open"]
        var request = SynologyBasicRequest(baseURLString: baseURLString(), api: .download, method: .download, params: params)
        request.version = 2
        return download(path: request.urlQuery(), parameters: params, to: to)
    }
    
    /// Download file from synology
    /// - Parameters:
    ///   - path: file path
    ///   - parameters: additional parameters
    ///   - destination: Callback closure.
    public func download(path: String, parameters: Parameters, to destination: DownloadRequest.Destination?) -> DownloadRequest {
        let urlString = baseURLString().appending("\(path)")
        print(urlString)
        return AF.download(urlString, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil, to: destination)
    }
    
    /// List user’s file sharing links.
    /// - Parameters:
    ///   - offset: Optional. Specify how many sharing links are skipped before beginning to return listed sharing links.
    ///   - limit: Optional. Number of sharing links requested. 0 means to list all sharing links.
    ///   - sortBy: Optional. Specify information of the sharing link to sort on.
    ///   - direction: Optional. Specify to sort ascending or to sort descending.
    ///   - forceClean: Optional. If set to false, the data will be retrieval from cache database rapidly.
    ///                           If set to true, all sharing information including sharing statuses and
    ///                           user name of sharing owner will be synchronized. It consumes some time.
    ///   - completion: Callback closure.
    public func getSharingList(offset: Int = 0, limit: Int = 0, sortBy: SharingSortBy? = nil, direction: FileSortDirection = .ascending, forceClean: Bool? = nil, completion: @escaping SynologyCompletion<SharingLinkList>) {
        var params = Parameters()
        params["offset"] = offset
        params["limit"] = limit
        if let sortBy = sortBy {
            params["sort_by"] = sortBy.rawValue
            params["sort_direction"] = direction.rawValue
        }
        if let forceClean = forceClean {
            params["force_clean"] = forceClean
        }
        let request = SynologyBasicRequest(baseURLString: baseURLString(), api: .sharing, method: .list, params: params)
        post(request, completion: completion)
    }
    
    /// Create folders.
    /// - Parameter folderPath: One or more shared folder paths, separated by commas.
    ///           If force_parent is "true," and folder_path does not exist, the folder_path will be created.
    ///           If force_parent is "false," folder_path must exist or a false value will be returned.
    ///           The number of paths must be the same as the number of names in the name parameter.
    ///           The first folder_path parameter corresponds to the first name parameter.
    /// - Parameter name: One or more new folder names, separated by commas “,”.
    ///           The number of names must be the same as the number of folder paths in the folder_path parameter.
    ///           The first name parameter corresponding to the first folder_path parameter.
    /// - Parameter forceParent: Optional. “true”: no error occurs if a folder exists and make parent folders as needed; “false”: parent folders are not created.
    /// - Parameter additional: Optional. Additional requested file information, separated by commas “,”. When an additional option is requested, responded objects will be provided in the specified additional option.
    /// - Parameter completion: Callback closure.
    public func createFolder(_ folderPath: String, name: String, forceParent: Bool = false, additional: AdditionalOptions? = nil, completion: @escaping SynologyCompletion<FolderOperationResponse>) {
        var params: Parameters = [:]
        params["folder_path"] = folderPath
        params["name"] = name
        params["force_parent"] = forceParent
        if let additional = additional {
            params["additional"] = additional
        }
        let request = SynologyBasicRequest(baseURLString: baseURLString(), api: .createFolder, method: .create, params: params)
        post(request, completion: completion)
    }
    
    /// Rename a file/folder.
    /// - Parameter path: One or more paths of files/folders to be renamed, separated by commas “,”.
    ///                   The number of paths must be the same as the number of names in the name parameter.
    /// The first path parameter corresponds to the first name parameter
    /// - Parameter name: One or more new names, separated by commas “,”. The number of names must be the same as the number of folder paths in the path parameter. The first name parameter corresponding to the first path parameter.
    /// - Parameter additional: Additional requested file information, separated by commas “,”. When an additional option is requested, responded objects will be provided in the specified additional option.
    /// - Parameter searchTaskId: A unique ID for the search task which is obtained from start method. It is used to update the renamed file in the search result
    public func rename(path: String, name: String, additional: AdditionalOptions? = nil, searchTaskId: String? = nil, completion: @escaping SynologyCompletion<FileInfo>) {
        var params: [String: Any] = [:]
        params["path"] = path
        params["name"] = name
        if let additional = additional {
            params["additional"] = additional.value()
        }
        if let taskId = searchTaskId {
            params["search_taskid"] = taskId
        }
        let request = SynologyBasicRequest(baseURLString: baseURLString(), api: .rename, method: .rename, params: params)
        post(request, completion: completion)
    }
    
    /// Start to copy/move files
    /// This is a non-blocking API.
    /// You need to start to copy/move files with start method. Then, you should poll requests with status
    /// method to get the progress status, or make a request with stop method to cancel the operation.
    /// - Parameter path: One or more copied/moved file/folder path(s) starting with a shared folder, separated by commas “,”.
    /// - Parameter destFolderPath: A desitination folder path where files/folders are copied/moved.
    /// - Parameter overwrite: Optional. “true”: overwrite all existing files with the same name; “false”: skip all existing files with the same name; (None): do not overwrite or skip existed files. If there is any existing files, an error occurs (error code: 1003).
    /// - Parameter removeSource: Optional. “true”: move filess/folders;”false”: copy files/folders
    /// - Parameter accurateProgress: Optional. “true”: calculate the progress by each moved/copied file within subfolder. “false”: calculate the progress by files which you give in path parameters. This calculates the progress faster, but is less precise.
    /// - Parameter searchTaskId: Optional. A unique ID for the search task which is gotten from SYNO.FileSation.Search API with start method. This is used to update the search result.
    ///   - progressHandler: progressHandler
    ///   - completion: Callback closure.
    public func copyMove(path: String, destFolderPath: String, overwrite: Bool? = nil, removeSource: Bool = false, accurateProgress: Bool = true, searchTaskId: String? = nil, progressHandler: SynologyProgressHandler<CopyMoveTask> = nil, completion: @escaping SynologyCompletion<CopyMoveTask>) {
        var parameters = Parameters()
        parameters["path"] = path
        parameters["dest_folder_path"] = destFolderPath
        if let overwrite = overwrite {
            parameters["overwrite"] = overwrite
        }
        parameters["remove_src"] = removeSource
        parameters["accurate_progress"] = accurateProgress
        if let taskId = searchTaskId {
            parameters["search_taskid"] = taskId
        }
        let request = SynologyBasicRequest(baseURLString: baseURLString(), api: .copyMove, method: .start, params: parameters)
        postNonBlockingRequest(request, progressHandler: progressHandler, completion: completion)
    }
    
    /// Delete file(s)/folder(s).
    /// This is a non-blocking method. You should poll a request with status method to get more
    /// information or make a request with stop method to cancel the operation.
    /// - Parameter path: One or more deleted file/folder paths starting with a shared folder, separated by commas “,”.
    /// - Parameter accurateProgress: Optional. “true”: calculates the progress of each deleted file with the sub-folder recursively;
    ///                “false”: calculates the progress of files which you give in path parameters.
    ///                The latter is faster than recursively, but less precise.
    ///                Note: Only non-blocking methods suits using the status method to get progress.
    /// - Parameter recursive: Optional. “true”: Recursively delete files within a folder.
    ///                        “false”: Only delete first-level file/folder.
    ///                        If a deleted folder contains any file, an error occurs because the folder can’t be directly deleted
    /// - Parameter searchTaskid: Optional. A unique ID for the search task which is gotten from start method.
    ///                        It’s used to delete the file in the search result.
    /// - Parameter progressHandler: progressHandler
    /// - Parameter completion: Callback closure.
    public func delete(path: String, accurateProgress: Bool = true, recursive: Bool = true, searchTaskid: String? = nil, progressHandler: SynologyProgressHandler<DeletionTask> = nil, completion: @escaping SynologyCompletion<DeletionTask>) {
        var params: [String: Any] = [:]
        params["path"] = path
        params["accurate_progress"] = accurateProgress
        params["recursive"] = recursive
        if let taskId = searchTaskid {
            params["search_taskid"] = taskId
        }
        let request = SynologyBasicRequest(baseURLString: baseURLString(), api: .delete, method: .start, params: params)
        postNonBlockingRequest(request, progressHandler: progressHandler, completion: completion)
    }
    
    /// Extract an archive and perform operations on archive files
    /// Note: Supported extensions of archives: zip, gz, tar, tgz, tbz, bz2, rar, 7z, iso
    /// - Parameters:
    ///   - filePath: A file path of an archive to be extracted, starting with a shared folder
    ///   - destinationFolderPath: A destination folder path starting with a shared folder to which the archive will be extracted.
    ///   - overwrite: Optional. Whether or not to overwrite if the extracted file exists in the destination folder
    ///   - keepDirectory: Optional. Whether to keep the folder structure within an archive.
    ///   - createSubFolder: Optional. Whether to create a subfolder with an archive name which archived files are extracted to.
    ///   - password: Optional. The password for extracting the file.
    ///   - progressHandler: progressHandler
    ///   - completion: Callback closure.
    public func extract(filePath: String, destinationFolderPath: String, overwrite: Bool = false, keepDirectory: Bool = true, createSubFolder: Bool = false, password: String? = nil, progressHandler: SynologyProgressHandler<ExtractTask> = nil, completion: @escaping SynologyCompletion<ExtractTask>) {
        var parameters = Parameters()
        parameters["file_path"] = filePath
        parameters["dest_folder_path"] = destinationFolderPath
        parameters["overwrite"] = overwrite
        parameters["keep_dir"] = keepDirectory
        parameters["create_subfolder"] = createSubFolder
        if let password = password {
            parameters["password"] = password
        }
        let request = SynologyBasicRequest(baseURLString: baseURLString(), api: .extract, method: .start, params: parameters)
        postNonBlockingRequest(request, progressHandler: progressHandler, completion: completion)
    }
    
    /// Compress file(s)/folder(s).
    /// This is a non-blocking API. You need to start to compress files with the start method.
    /// Then, you should poll requests with the status method to get compress status, or make a request with the stop method to cancel the operation.
    /// - Parameter path: One or more file paths to be compressed, separated by commas “,”. The path should start with a shared folder.
    /// - Parameter destinationFilePath: A destination file path (including file name) of an archive for the compressed archive.
    /// - Parameter level: Optional. Compress level used.
    /// - Parameter mode: Optional. Compress mode used.
    /// - Parameter format: Optional. The compress format.
    /// - Parameter password: Optional. The password for the archive.
    /// - Parameter completion: Callback closure.
    public func compress(path: String, destinationFilePath: String, level: CompressLevel = .moderate, mode: CompressMode = .add, format: CompressFormat, password: String? = nil, completion: @escaping SynologyCompletion<CompressionTask>) {
        var params: Parameters = [:]
        params["path"] = path
        params["dest_file_path"] = destinationFilePath
        params["level"] = level.rawValue
        params["mode"] = mode.rawValue
        params["format"] = format.rawValue
        if let password = password {
            params["password"] = password
        }
        let request = SynologyBasicRequest(baseURLString: baseURLString(), api: .compress, method: .start, params: params)
        postNonBlockingRequest(request, completion: completion)
    }
    
    /// List all background tasks including copy, move, delete, compress and extract tasks
    /// - Parameters:
    ///   - filter: Optional. List background tasks with one or more given API name(s), separated by commas “,”.
    ///                       If not given, all background tasks are listed.
    ///   - options: List query options.
    ///   - completion: Callback closure.
    public func getBackgroundTaskList(filter: [BackgroundTaskFilter] = [], options: ListOptions = ListOptions(), completion: @escaping SynologyCompletion<BackgroundTaskList>) {
        var parameters = Parameters()
        if filter.count > 0 {
            parameters["api_filter"] = filter.map { $0.rawValue }.joined(separator: ",")
        }
        for v in options.value() {
            parameters[v.key] = v.value
        }
        let request = SynologyBasicRequest(baseURLString: baseURLString(), api: .backgroundTask, method: .list, params: parameters)
        post(request, completion: completion)
    }

    /// Delete all finished background tasks.
    /// - Parameters:
    ///   - taskid: Unique IDs of finished copy, move, delete, compress or extract tasks. Specify multiple task IDs by “,”.
    ///             If it’s not given, all finished tasks are deleted.
    ///   - completion: Callback closure.
    public func clearFinishedBackgroundTask(taskid: String? = nil, completion: @escaping SynologyCompletion<EmptyResponse>) {
        var parameters = Parameters()
        if let taskid = taskid {
            parameters["taskid"] = taskid
        }
        let request = SynologyBasicRequest(baseURLString: baseURLString(), api: .backgroundTask, method: .clear_finished, params: parameters)
        post(request, completion: completion)
    }
}

// MARK: - QuickID
extension SynologyClient {
    
    /// Get Synology server information via Quick Connect
    /// - Parameter quickID: quickID of your Synology
    /// - Parameter completion: callback closure
    func getGlobalServerInfo(quickID: String, completion: @escaping SynologyCompletion<QuickConnectResponse>) {
        let baseUrl = "https://global.QuickConnect.to"
        var params: [String: Any] = [:]
        params["id"] = "dsm"//"audio_http"
        params["serverID"] = quickID
        params["command"] = "get_server_info"
        params["version"] = 1
        var headers = HTTPHeaders()
        headers.add(name: "User-Agent", value: userAgent)
        let request = QuickConnectRequest(baseURLString: baseUrl, path: "/Serv.php", params: params, headers: headers)
        AF.request(request.asURLRequest()).response { response in
            self.handleQuickConnectResponse(response, completion: completion)
        }
    }
    
    /// Get Synology server information via Quick Connect
    /// - Parameter quickID: quickID of your Synology
    /// - Parameter platform: platform
    /// - Parameter completion: callback closure
    public func getServerInfo(server: String, quickID: String, platform: String = "iPhone9,1", completion: @escaping QuickIDCompletion) {
        let url = "https://\(server)"
        var params: [String: Any] = [:]
        params["location"] = "en_CN"
        params["id"] = "dsm"//"audio_http"
        params["platform"] = platform
        params["serverID"] = quickID
        params["command"] = "request_tunnel"
        params["version"] = 1
        var headers = HTTPHeaders()
        headers.add(name: "User-Agent", value: userAgent)
        let request = QuickConnectRequest(baseURLString: url, path: "/Serv.php", params: params, headers: headers)
        AF.request(request.asURLRequest()).response { response in
            self.handleQuickIDResponse(response, completion: completion)
        }
    }
    
    func handleQuickConnectResponse(_ response: AFDataResponse<Data?>, completion: @escaping GlobalQuickConnectCompletion) {
        DispatchQueue.main.async {
            guard let data = response.data else {
                completion(.failure(.invalidResponse(response)))
                return
            }
            do {
                let decodedRes = try JSONDecoder().decode(QuickConnectResponse.self, from: data)
                completion(.success(decodedRes))
            } catch {
                let text = String(data: data, encoding: .utf8)
                completion(.failure(.decodeDataError(response, text)))
            }
        }
    }
    
    func handleQuickIDResponse(_ response: AFDataResponse<Data?>, completion: @escaping QuickIDCompletion) {
        DispatchQueue.main.async {
            guard let data = response.data else {
                completion(.failure(.invalidResponse(response)))
                return
            }
            do {
                let decodedRes = try JSONDecoder().decode(QuickIDResponse.self, from: data)
                completion(.success(decodedRes))
            } catch {
                let text = String(data: data, encoding: .utf8)
                completion(.failure(.decodeDataError(response, text)))
            }
        }
    }
}

// MARK: - Non-Blocking Operations
extension SynologyClient {
        
    // TODO: Add timeout
    func postNonBlockingRequest<T: SynologyTask>(_ request: SynologyBasicRequest, progressHandler: SynologyProgressHandler<T> = nil, completion: @escaping SynologyCompletion<T>, method: SynologyMethod = .status) {
        post(request) { (response: Swift.Result<TaskResult, SynologyError>) in
            switch response {
            case .success(let task):
                self.queue.async {
                    let result: Swift.Result<T, SynologyError> = self.checkTaskStatus(task, request: request, method: method, progressHandler: progressHandler)
                    switch result {
                    case .success(let status):
                        completion(.success(status))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func checkTaskStatus<T: SynologyTask>(_ task: TaskResult, request: SynologyBasicRequest, method: SynologyMethod, progressHandler: SynologyProgressHandler<T>) -> Swift.Result<T, SynologyError> {
        var statusRequest = request
        statusRequest.method = method
        statusRequest.params.removeAll()
        statusRequest.params["taskid"] = task.taskid
        var finished: Bool = false
        let seamphore = DispatchSemaphore(value: 0)
        var error: SynologyError? = nil
        var status: T!
        while !finished {
            post(statusRequest) { (response: Swift.Result<T, SynologyError>) in
                seamphore.signal()
                switch response {
                case .success(let statusResponse):
                    progressHandler?(statusResponse)
                    if statusResponse.finished {
                        finished = true
                        status = statusResponse
                    }
                case .failure(let err):
                    finished = true
                    error = err
                }
            }
            seamphore.wait()
        }
        if let error = error {
            return .failure(error)
        }
        if status == nil {
            return .failure(.unknownError)
        }
        return .success(status)
    }
}
