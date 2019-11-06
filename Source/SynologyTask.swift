//
//  SynologyTask.swift
//  SynologyKit
//
//  Created by xu.shuifeng on 2019/11/6.
//

import Foundation

public protocol SynologyTask: Codable {
    /// If the task is finished or not.
    var finished: Bool { get }
}

/// Common Non-Blocking Task Response
struct TaskResult: Codable {
    var taskid: String
}

public extension SynologyClient {
    
    struct SearchFileTask: SynologyTask {
        /// If the searching task is finished or not.
        public var finished: Bool
        
        /// Total number of matched files
        public let total: Int
        
        /// Requested offset.
        public let offset: Int
        
        /// Array of <file> objects.
        public let files: [File]
    }
    
    struct MD5Task: SynologyTask {
        
        /// Check if the task is finished or not.
        public var finished: Bool
        
        /// MD5 of the requested file.
        public let md5: String?
    }
    
    struct DirectorySizeTask: SynologyTask {
        
        enum CodingKeys: String, CodingKey {
            case finished
            case numberOfDirectory = "num_dir"
            case numberOfFiles = "num_file"
            case totalSize = "total_size"
        }
        
        public var finished: Bool
        
        /// Number of directories in the queried path(s).
        public let numberOfDirectory: Int
        
        /// Number of files in the queried path(s).
        public let numberOfFiles: Int
        
        /// Accumulated byte size of the queried path(s).
        public let totalSize: Int64
    }
    
    struct CopyMoveTask: SynologyTask {
        enum CodingKeys: String, CodingKey {
            case finished
            case processedSize = "processed_size"
            case total
            case path
            case progress
            case destinationFolderPath = "dest_folder_path"
        }
        
        public var finished: Bool
        
        /// If accurate_progress parameter is “true,” byte sizes of all copied/moved files will be accumulated.
        /// If “false,” only byte sizes of the file you give in path parameter is accumulated.
        public let processedSize: Int64
        
        /// If accurate_progress parameter is “true,” the value indicates total byte sizes of files including subfolders will be copied/moved.
        /// If “false,” it indicates total byte sizes of files you give in path parameter excluding files within subfolders.
        /// Otherwise, when the total number is calculating, the value is -1.
        public let total: Int64
        
        /// A copying/moving path which you give in path parameter.
        public let path: String
        
        /// A progress value is between 0~1. It is equal to processed_size parameter divided by total parameter.
        public let progress: Float
        
        /// A desitination folder path where files/folders are copied/moved.
        public let destinationFolderPath: String?
    }
    
    struct DeletionTask: SynologyTask {
        enum CodingKeys: String, CodingKey {
            case finished
            case processdNumber = "processed_num"
            case total
            case path
            case processingPath = "processing_path"
            case progress
        }
        
        public var finished: Bool
        
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
        
        /// Progress value whose range between 0~1 is equal to processed_num parameter divided by total parameter.
        public let progress: Float
    }
    
    struct ExtractTask: SynologyTask {
        
        enum CodingKeys: String, CodingKey {
            case finished
            case progress
            case destinationFolderPath = "dest_folder_path"
        }
        
        /// If the task is finished or not.
        public var finished: Bool
        
        /// The extract progress expressed in range 0 to 1.
        public let progress: Float
        
        /// The requested destination folder for the task.
        public let destinationFolderPath: String
    }
    
    struct CompressionTask: SynologyTask {
        enum CodingKeys: String, CodingKey {
            case finished
            case destinationFilePath = "dest_file_path"
        }
        
        /// Whether or not the compress task is finished.
        public var finished: Bool
        
        /// The requested destination path of an archive.
        public let destinationFilePath: String?
    }
}
