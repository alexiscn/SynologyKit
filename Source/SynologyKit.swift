//
//  SynologyKit.swift
//  SynologyKit
//
//  Created by xu.shuifeng on 19/09/2017.
//

import Foundation
import Alamofire

// https://global.download.synology.com/download/Document/DeveloperGuide/Synology_File_Station_API_Guide.pdf

public typealias SynologyCompletion<T: Codable> = (Swift.Result<T, SynologyError>) -> Void

public typealias QuickConnectCompletion = (Swift.Result<QuickIDResponse, SynologyError>) -> Void

/// SynologyKit for File Station
public class SynologyKit {
    
    public static var userAgent = "DS audio 5.13.2 rv:323 (iPhone; iOS 11.0; en_CN)"
    
    public static var host: String?
    
    public static var port: Int?
    
    public static var sessionid: String?
    
    public static var enableHTTPS = false
    
    class func baseURLString() -> String {
        
        guard let host = host else {
            return ""
        }
        
        let scheme = enableHTTPS ? "https": "http"
        
        if let port = port {
            return "\(scheme)://\(host):\(port)/"
        }
        return "\(scheme)://\(host)/"
    }
    
    class func requestUrlString(path: String) -> String {
        return baseURLString().appending(path)
    }
        
    @discardableResult
    class func post<T: Codable>(_ request: SynologyRequest, queue: DispatchQueue?, completion: @escaping SynologyCompletion<T>) -> DataRequest {
        return SessionManager.default.request(request.asURLRequest()).response(queue: queue) { response in
            self.handleDataResponse(response, completion: completion)
        }
    }
    
    class func handleDataResponse<T>(_ response: DefaultDataResponse, completion: @escaping SynologyCompletion<T>) {
        guard let data = response.data else {
            completion(.failure(.invalidResponse(response)))
            return
        }
        do {
            let decodedRes = try JSONDecoder().decode(SynologyResponse<T>.self, from: data)
            if let data = decodedRes.data {
                completion(.success(data))
            } else if let code = decodedRes.error {
                let error = SynologyError.ErrorCode(rawValue: code) ?? .unknown
                completion(.failure(.serverError(error, response)))
            }
        } catch {
            let text = String(data: data, encoding: .utf8)
            completion(.failure(.decodeDataError(response, text)))
        }
    }
    
    public class func download(path: String, parameters: Parameters, to destination: DownloadRequest.DownloadFileDestination?) -> DownloadRequest {
        let urlString = baseURLString().appending("\(path)")
        print(urlString)
        return Alamofire.download(urlString, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil, to: destination)
    }
}

extension SynologyKit {
    
    /// Login to your synology
    /// - Parameters:
    ///   - account: Login account name.
    ///   - passwd: Login account password.
    ///   - completion: Callback closure.
    public class func login(account: String, passwd: String, completion: @escaping SynologyCompletion<AuthResponse>) {
        var parameters: Parameters = [:]
        parameters["account"] = account
        parameters["passwd"] = passwd
        parameters["session"] = "FileStationSession"
        var request = SynologyBasicRequest(path: .auth, api: .auth, method: .login ,params: parameters)
        request.version = 3
        post(request, queue: nil, completion: completion)
    }
    
    /// Logout
    /// - Parameters:
    ///   - completion: Callback closure.
    public class func logout(completion: @escaping SynologyCompletion<EmptyResponse>) {
        let params = ["session": "FileStationSession"]
        let request = SynologyBasicRequest(path: .auth, api: .auth, method: .logout, params: params)
        post(request, queue: nil, completion: completion)
    }
    
    /// List all mount point folders on one given type of virtual file system
    /// - Parameter type: A type of virtual file systems, ex: CIFS or ISO.
    /// - Parameter offset: Optional. Specify how many mount point folders are skipped before
    /// beginning to return listed mount point folders in virtual file system.
    /// - Parameter limit: Optional. Number of mount point folders requested. 0 indicates to list all mount point folders in virtual file system.
    /// - Parameter sortBy: Optional. Specify which file information to sort on.
    /// - Parameter direction: Optional. Specify to sort ascending or to sort descending.
    /// - Parameter additional: Optional. Additional requested file information, separated by a comma, “,”. When an additional option is requested, responded objects will be provided in the specified additional option
    /// - Parameter completion: callback closure.
    public class func listVirtualFolder(type: VirtualFolderType, offset: Int = 0, limit: Int = 0, sortBy: SynologyFileSort = .name, direction: SynologyFileSortDirection = .ascending, additional: Additional? = nil, completion: @escaping SynologyCompletion<String>) {
        var params: Parameters = [:]
        params["type"] = type.rawValue
        params["offset"] = offset
        params["limit"] = limit
        params["sort_by"] = sortBy.rawValue
        params["sort_direction"] = direction.rawValue
        if let additional = additional {
            params["additional"] = additional
        }
        let request = SynologyBasicRequest(path: .fileVirtual, api: .virtualFolder, method: .list, params: params)
        post(request, queue: nil, completion: completion)
    }
    
    /// List all shared folders, enumerate files in a shared folder, and get detailed file information.
    /// - Parameter offset: Optional. Specify how many shared folders are skipped before beginning to return listed shared folders.
    /// - Parameter limit: Optional. Number of shared folders requested. 0 lists all shared folders.
    /// - Parameter sortBy: Optional. Specify which file information to sort on.
    /// - Parameter sortDirection: Optional. Specify to sort ascending or to sort descending.
    /// - Parameter additional: Optional. Additional requested file information, separated by commas “,”. When an additional option is requested, responded objects will be provided in the specified additional option.
    /// - Parameter completion: callback closure.
    public class func listShareFolders(offset: Int = 0,
                                       limit: Int = 0,
                                       sortBy: SynologyFileSort = .name,
                                       sortDirection: SynologyFileSortDirection = .ascending,
                                       additional: SynologyAdditionalOptions = .default,
                                       completion: @escaping SynologyCompletion<SharedFolders>) {
        var params: Parameters = [:]
        params["offset"] = offset
        params["limit"] = limit
        params["sort_by"] = sortBy.rawValue
        params["sort_direction"] = sortDirection.rawValue
        params["additional"] = additional.value()
        var request = SynologyBasicRequest(path: .entry, api: .list, method: .list_share, params: params)
        request.version = 2
        post(request, queue: nil, completion: completion)
    }
    
    /// Enumerate files in a given folder
    /// - Parameter folder: A listed folder path started with a shared folder.
    /// - Parameter offset: Optional. Specify how many files are skipped before beginning to return listed files. Default value is 0.
    /// - Parameter limit: Optional. Number of files requested. 0 indicates to list all files with a given folder. Default value is 0.
    /// - Parameter sortBy: Optional. Specify which file information to sort on. Default value is `name`.
    /// - Parameter sortDirection: Optional. Specify to sort ascending or to sort descending. Default value is `asc`.
    /// - Parameter additional: Optional. Additional requested file information, separated by commas “,”. When an additional option is requested, responded objects will be provided in the specified additional option.
    /// - Parameter completion: callback closure.
    public class func listFolder(_ folder: String,
                                 offset: Int = 0,
                                 limit: Int = 0,
                                 sortBy: SynologyFileSort = .name,
                                 sortDirection: SynologyFileSortDirection = .ascending,
                                 additional: SynologyAdditionalOptions = .default,
                                 completion: @escaping SynologyCompletion<Files>) {
        var params: Parameters = [:]
        params["folder_path"] = folder
        params["offset"] = offset
        params["limit"] = limit
        params["sort_by"] = sortBy.rawValue
        params["sort_direction"] = sortDirection.rawValue
        params["additional"] = additional.value()
        var request = SynologyBasicRequest(path: .entry, api: .list, method: .list, params: params)
        request.version = 2
        post(request, queue: nil, completion: completion)
    }
    
    public class func downloadFile(path: String, to: @escaping DownloadRequest.DownloadFileDestination) -> DownloadRequest {
        let params = ["path": path, "mode": "open"]
        var request = SynologyBasicRequest(path: .entry, api: .download, method: .download, params: params)
        request.version = 2
        return download(path: request.urlQuery(), parameters: params, to: to)
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
    /// - Parameter completion: callback closure.
    public class func createFolder(_ folderPath: String, name: String, forceParent: Bool = false, additional: Additional? = nil, completion: @escaping SynologyCompletion<String>) {
        // TODO - check status
        var params: Parameters = [:]
        params["folder_path"] = folderPath
        params["name"] = name
        params["force_parent"] = forceParent
        if let additional = additional {
            params["additional"] = additional
        }
        let request = SynologyBasicRequest(path: .file_crtfdr, api: .createFolder, method: .create, params: params)
        post(request, queue: nil, completion: completion)
    }
    
    /// Rename a file/folder.
    /// - Parameter path: One or more paths of files/folders to be renamed, separated by commas “,”.
    ///                   The number of paths must be the same as the number of names in the name parameter.
    /// The first path parameter corresponds to the first name parameter
    /// - Parameter name: One or more new names, separated by commas “,”. The number of names must be the same as the number of folder paths in the path parameter. The first name parameter corresponding to the first path parameter.
    /// - Parameter additional: Additional requested file information, separated by commas “,”. When an additional option is requested, responded objects will be provided in the specified additional option.
    /// - Parameter searchTaskId: A unique ID for the search task which is obtained from start method. It is used to update the renamed file in the search result
    public class func rename(path: String, name: String, additional: Additional? = nil, searchTaskId: String? = nil, completion: @escaping SynologyCompletion<Files>) {
        // TODO - check status
        var params: [String: Any] = [:]
        params["path"] = path
        params["name"] = name
        if let additional = additional {
            params["additional"] = additional
        }
        if let taskId = searchTaskId {
            params["search_taskid"] = taskId
        }
        let request = SynologyBasicRequest(path: .fileRename, api: .rename, method: .rename, params: params)
        post(request, queue: nil, completion: completion)
    }
    
    /// Start to copy/move files
    /// This is a non-blocking API.
    /// You need to start to copy/move files with start method. Then, you should poll requests with status
    /// method to get the progress status, or make a request with stop method to cancel the operation.
    /// - Parameter path: One or more copied/moved file/folder path(s) starting with a shared folder, separated by commas “,”.
    /// - Parameter destFolderPath: A desitination folder path where files/folders are copied/moved.
    /// - Parameter overrite: Optional. “true”: overwrite all existing files with the same name; “false”: skip all existing files with the same name; (None): do not overwrite or skip existed files. If there is any existing files, an error occurs (error code: 1003).
    /// - Parameter removeSource: Optional. “true”: move filess/folders;”false”: copy files/folders
    /// - Parameter accurateProgress: Optional. “true”: calculate the progress by each moved/copied file within subfolder. “false”: calculate the progress by files which you give in path parameters. This calculates the progress faster, but is less precise.
    /// - Parameter searchTaskid: Optional. A unique ID for the search task which is gotten from SYNO.FileSation.Search API with start method. This is used to update the search result.
    public class func copyMove(path: String, destFolderPath: String, overrite: Bool, removeSource: Bool = false, accurateProgress: Bool, searchTaskid: String? = nil) {
        // TODO
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
    /// - Parameter completion: Callback closure.
    public class func delete(path: String, accurateProgress: Bool = true, recursive: Bool = true, searchTaskid: String? = nil, completion: @escaping SynologyCompletion<String>) {
        var params: [String: Any] = [:]
        params["path"] = path
        params["accurate_progress"] = accurateProgress
        params["recursive"] = recursive
        if let taskId = searchTaskid {
            params["search_taskid"] = taskId
        }
        let request = SynologyBasicRequest(path: .fileDelete, api: .delete, method: .start, params: params)
        post(request, queue: nil, completion: completion)
    }
    
    public class func extract(filePath: String, destinationFolderPath: String, overwrite: Bool = false, keepDirectory: Bool = true, createSubFolder: Bool = false, password: String? = nil, completion: @escaping SynologyCompletion<String>) {
        var parameters = Parameters()
        parameters["file_path"] = filePath
        parameters["dest_folder_path"] = destinationFolderPath
        parameters["overwrite"] = overwrite
        parameters["keep_dir"] = keepDirectory
        parameters["create_subfolder"] = createSubFolder
        if let password = password {
            parameters["password"] = password
        }
        
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
    public class func compress(path: String, destinationFilePath: String, level: CompressLevel = .moderate, mode: CompressMode = .add, format: CompressFormat, password: String? = nil, completion: @escaping SynologyCompletion<String>) {
        var params: Parameters = [:]
        params["path"] = path
        params["dest_file_path"] = destinationFilePath
        params["level"] = level.rawValue
        params["mode"] = mode.rawValue
        params["format"] = format.rawValue
        if let password = password {
            params["password"] = password
        }
        let request = SynologyBasicRequest(path: .fileCompress, api: .compress, method: .start, params: params)
        post(request, queue: nil, completion: completion)
    }
}

// MARK: - QuickID
extension SynologyKit {
    
    /// Get Synology server information via Quick Connect
    /// - Parameter quickID: quickID of your Synology
    /// - Parameter completion: callback closure
    public class func getGlobalServerInfo(quickID: String, completion: @escaping SynologyCompletion<QuickIDResponse>) {
        let baseUrl = "https://global.QuickConnect.to"
        var params: [String: Any] = [:]
        params["id"] = "audio_http"
        params["serverID"] = quickID
        params["command"] = "get_server_info"
        params["version"] = 1
        let headers = ["User-Agent": userAgent]
        let request = QuickConnectRequest(baseURLString: baseUrl, path: "/Serv.php", params: params, headers: headers)
        SessionManager.default.request(request.asURLRequest()).response(queue: nil) { response in
            self.handleQuickConnectResponse(response, completion: completion)
        }
    }
    
    /// Get Synology server information via Quick Connect
    /// - Parameter quickID: quickID of your Synology
    /// - Parameter platform: platform
    /// - Parameter completion: callback closure
    public class func getServerInfo(quickID: String, platform: String = "iPhone9,1", completion: @escaping QuickConnectCompletion) {
        let url = "https://cnc.quickconnect.to"
        var params: [String: Any] = [:]
        params["location"] = "en_CN"
        params["id"] = "audio_http"
        params["platform"] = platform
        params["serverID"] = quickID
        params["command"] = "request_tunnel"
        params["version"] = 1
        let headers = ["User-Agent": userAgent]
        let request = QuickConnectRequest(baseURLString: url, path: "/Serv.php", params: params, headers: headers)
        SessionManager.default.request(request.asURLRequest()).response(queue: nil) { response in
            self.handleQuickConnectResponse(response, completion: completion)
        }
    }
    
    class func handleQuickConnectResponse(_ response: DefaultDataResponse, completion: @escaping QuickConnectCompletion) {
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

extension SynologyKit {
    
    class func asyncAwait() {
        
    }
    
    class func checkMD5RequestStatus(_ request: SynologyBasicRequest) -> String? {
        var finished: Bool = false
        var statusRequest = request
        statusRequest.method = .status
        let seamphore = DispatchSemaphore(value: 0)
        var md5: String? = nil
        while !finished {
            post(statusRequest, queue: nil) { (response: Swift.Result<MD5Status, SynologyError>) in
                switch response {
                case .success(let res):
                    print(res.finished)
                    if let md5 = res.md5 {
                        print("GOT MD5:\(md5)")
                    }
                    finished = res.finished
                    md5 = res.md5
                case .failure(let error):
                    print(error)
                }
                seamphore.signal()
            }
            seamphore.wait()
        }
        return md5
    }
}
