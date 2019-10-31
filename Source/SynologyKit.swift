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
            let decodedRes = try JSONDecoder().decode(T.self, from: data)
            completion(.success(decodedRes))
        } catch {
            completion(.failure(.decodeDataError))
        }
    }
    
    class func download(path: String, parameters: Parameters, to destination: DownloadRequest.DownloadFileDestination?) -> DownloadRequest {
        let urlString = baseURLString().appending("\(path)")
        print(urlString)
        return Alamofire.download(urlString, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil, to: destination)
    }
}

extension SynologyKit {
    
    public class func login(account: String, passwd: String, completion: @escaping SynologyCompletion<AuthResponse>) {
        var request = SynologyBasicRequest(api: .auth, method: .login, version: 3, path: CGI.auth)
        var parameters: Parameters = [:]
        parameters["account"] = account
        parameters["passwd"] = passwd
        parameters["session"] = "FileStationSession"
        request.params = parameters
        post(request, queue: nil, completion: completion)
    }
    
    public class func logout(session: String) {
        //let request = SynologyRequest(api: .Auth, method: .logout, version: 1, path: "auth.cgi")
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
        var request = SynologyBasicRequest(api: .list, method: .list_share, version: 2, path: CGI.entry)
        request.params = params
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
        var request = SynologyBasicRequest(api: .list, method: .list, version: 2, path: CGI.entry)
        request.params = params
        post(request, queue: nil, completion: completion)
    }
    
    public class func downloadFile(path: String, to: @escaping DownloadRequest.DownloadFileDestination) -> DownloadRequest {
        let api = SynologyBasicRequest(api: .download, method: .download, version: 2, path: CGI.entry)
        let params = ["path": path, "mode": "open"]
        return download(path: api.urlQuery(), parameters: params, to: to)
    }
    
    /// Rename a file/folder.
    /// - Parameter path: One or more paths of files/folders to be renamed, separated by commas “,”.
    ///                   The number of paths must be the same as the number of names in the name parameter.
    /// The first path parameter corresponds to the first name parameter
    /// - Parameter name: One or more new names, separated by commas “,”. The number of names must be the same as the number of folder paths in the path parameter. The first name parameter corresponding to the first path parameter.
    /// - Parameter additional: Additional requested file information, separated by commas “,”. When an additional option is requested, responded objects will be provided in the specified additional option.
    /// - Parameter searchTaskId: A unique ID for the search task which is obtained from start method. It is used to update the renamed file in the search result
    public class func rename(path: String, name: String, additional: String? = nil, searchTaskId: String? = nil) {
        // TODO
    }
    
    /// Start to copy/move files
    /// This is a non-blocking API.
    /// You need to start to copy/move files with start method. Then, you should poll requests with status
    /// method to get the progress status, or make a request with stop method to cancel the operation.
    /// - Parameter path: One or more copied/moved file/folder path(s) starting with a shared folder, separated by commas “,”.
    /// - Parameter dest_folder_path: A desitination folder path where files/folders are copied/moved.
    /// - Parameter overrite: Optional. “true”: overwrite all existing files with the same name; “false”: skip all existing files with the same name; (None): do not overwrite or skip existed files. If there is any existing files, an error occurs (error code: 1003).
    /// - Parameter removeSource: Optional. “true”: move filess/folders;”false”: copy files/folders
    /// - Parameter accurate_progress: Optional. “true”: calculate the progress by each moved/copied file within subfolder. “false”: calculate the progress by files which you give in path parameters. This calculates the progress faster, but is less precise.
    /// - Parameter search_taskid: Optional. A unique ID for the search task which is gotten from SYNO.FileSation.Search API with start method. This is used to update the search result.
    public class func copyMove(path: String, dest_folder_path: String, overrite: Bool, removeSource: Bool = false, accurate_progress: Bool, search_taskid: String? = nil) {
        // TODO
    }
    
    public class func delete() {
        // TODO
    }
}

// MARK: - QuickID
extension SynologyKit {
    
    public class func getServerInfo(quickID: String, completion: @escaping (QuickIDResponse) -> Void) {
        let url = "https://global.QuickConnect.to/Serv.php"
        var params: [String: Any] = [:]
        params["id"] = "audio_http"
        params["serverID"] = quickID
        params["command"] = "get_server_info"
        params["version"] = 1
        
        let headers = ["User-Agent": userAgent]
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).response { (dataResponse) in
            if let error = dataResponse.error {
                print("QuickID login error:\(error)")
            } else if let data = dataResponse.data {
                if let response = try? JSONDecoder().decode(QuickIDResponse.self, from: data) {
                    completion(response)
                } else {
                    print("can not parse json")
                    if let txt = String(data: data, encoding: .utf8) {
                        print("response text:\(txt)")
                    }
                }
            }
        }
    }
    
    public class func getServerInfo(quickID: String, platform: String, completion: @escaping (QuickIDResponse) -> Void) {
        let url = "https://cnc.quickconnect.to/Serv.php"
        var params: [String: Any] = [:]
        params["location"] = "en_CN"
        params["id"] = "audio_http"
        params["platform"] = platform
        params["serverID"] = quickID
        params["command"] = "request_tunnel"
        params["version"] = 1

        let headers = ["User-Agent": userAgent]

        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).response { (dataResponse) in
            if let error = dataResponse.error {
                print("QuickID login error:\(error)")
            } else if let data = dataResponse.data {
                if let response = try? JSONDecoder().decode(QuickIDResponse.self, from: data) {
                    completion(response)
                }
            }
        }
    }
}
