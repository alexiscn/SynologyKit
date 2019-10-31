//
//  SynologySDK+FileStation.swift
//  SynologySDK
//
//  Created by xushuifeng on 2017/10/9.
//

import Foundation
import Alamofire

extension SynologyKit {
    
    
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
                                       additional: SynologyFileAdditionalOptions = .default,
                                       completion: @escaping SynologyKitCompletion<SharedFolders>) {
        let api = SynologyRequest(api: .list, method: .list_share, version: 2, path: EntryCGI)
        var params: Parameters = [:]
        params["offset"] = offset
        params["limit"] = limit
        params["sort_by"] = sortBy.rawValue
        params["sort_direction"] = sortDirection.rawValue
        params["additional"] = additional.value()
        getJSON(path: api.urlString(), parameters: params, completion: completion)
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
                                 additional: SynologyFileAdditionalOptions = .default,
                                 completion: @escaping SynologyKitCompletion<Files>) {
        let api = SynologyRequest(api: .list, method: .list, version: 2, path: EntryCGI)
        var params: Parameters = [:]
        params["folder_path"] = folder
        params["offset"] = offset
        params["limit"] = limit
        params["sort_by"] = sortBy.rawValue
        params["sort_direction"] = sortDirection.rawValue
        params["additional"] = additional.value()
        getJSON(path: api.urlString(), parameters: params, completion: completion)
    }
    
    public class func downloadFile(path: String, to: @escaping DownloadRequest.DownloadFileDestination) -> DownloadRequest {
        let api = SynologyRequest(api: .download, method: .download, version: 2, path: EntryCGI)
        let params = ["path": path, "mode": "open"]
        return download(path: api.urlString(), parameters: params, to: to)
    }
    
    /// Rename a file/folder.
    /// - Parameter path: One or more paths of files/folders to be renamed, separated by commas “,”.
    ///                   The number of paths must be the same as the number of names in the name parameter.
    /// The first path parameter corresponds to the first name parameter
    /// - Parameter name: One or more new names, separated by commas “,”. The number of names must be the same as the number of folder paths in the path parameter. The first name parameter corresponding to the first path parameter.
    /// - Parameter additional: Additional requested file information, separated by commas “,”. When an additional option is requested, responded objects will be provided in the specified additional option.
    /// - Parameter searchTaskId: A unique ID for the search task which is obtained from start method. It is used to update the renamed file in the search result
    public class func rename(path: String, name: String, additional: String? = nil, searchTaskId: String? = nil) {
        
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
        
    }
    
    public class func delete() {
        
    }
}
