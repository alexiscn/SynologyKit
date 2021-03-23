# SynologyKit

Synology File API for Swift.

Table of Contents
=================

* [Features](#features)
* [Installation](#installation)
    * [CocoaPods](#cocoapods)
    * [Swift Package Manager](#swift-package-manager)
* [Get Started](#get-started)
    * [Create SynologyClient](#create-synologyclient)
    * [Login in](#login-in)
    * [List Share Folders](#list-share-folders)
    * [List Folder](#list-folder)
    * [Download file](#download-file)
    * [Upload file](#upload-file)
    * [Search file](#search-file)
* [LICENSE](#license)

## Features

* Support QuickConnect Sign In
* Support IP/Port Sign In
* List Share Folders
* List Share Files
* Get file info
* List Virtual Folder
* Favorites management (list/add/delete/edit/replaceAll)
* Get thumbnail of a file
* Get directory size
* Calculate file md5
* Directory management (create/rename/list)
* Copy move file
* Delete file (folder)
* Extract(compress) file
* Background task management(list/clearFinished)
* Download file
* Upload file


## Installation

### CocoaPods

SynologyKit is available through CocoaPods. To install it, simply add the following line to your Podfile:

```sh
pod 'SynologyKit', '~>1.0.0'
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. 

Once you have your Swift package set up, adding SynologyKit as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/alexiscn/SynologyKit.git", from: "1.2.0")
]
```

## Get Started

Other api can refer [Synology Official Document](https://global.download.synology.com/download/Document/Software/DeveloperGuide/Package/FileStation/All/enu/Synology_File_Station_API_Guide.pdf)

### Create SynologyClient

```
let address = "192.168.1.5"
let port = 5000
client = SynologyClient(host: address, port: port, enableHTTPS: false)
```

or via Quick Connect ID

```swift
client = SynologyClient(host: "your_quick_connect_id")
```


### Login in

After create SynologyClient, you can now sign in with following code:

```swift
let account = "your_synology_account"
let password = "your_synology_password"
client.login(account: account, passwd: password) { [weak self] response in
      switch response {
      case .success(let authRes):
          self?.client?.updateSessionID(authRes.sid)
          self?.handleLoginSuccess()
          print(authRes.sid)
      case .failure(let error):
          print(error.description)
      }
  }
```

When `sid` is got, you should update `SynologyClient` with SessionID. And then you can have access to all rest apis. 

### List Share Folders

Before your list folder files, you should first list share folders.

```swift
client.listShareFolders { response in
    switch response {
    case .success(let result):
        if let shares = result.shares {
            print("share folders count:\(shares.count)")
        }
    case .failure(let error):
        print(error)
    }
}
```        

### List Folder

```swift
client.listFolder(folder) { response in
    switch response {
    case .success(let result):
        if let files = result.files {
            for file in files {
                print("filename: \(file.name), path:\(file.path), isDirectory:\(file.isdir)")
            }
        }
    case .failure(let error):
        print(error)
    }
}
```

### Download file

Download file just as easy as using `Alamofire`.

```swift
let destination: DownloadRequest.Destination = { (temporaryURL, response)  in
    let options = DownloadRequest.Options.removePreviousFile
    let localURL = URL(fileURLWithPath: NSHomeDirectory().appending("/Documents/\(file.name)"))
    return (localURL,options)
}

client.downloadFile(path: file.path, to: destination).downloadProgress { progress in
    print(progress)
}.response { response in
    if response.error == nil, let path = response.fileURL?.path {
        print("File Downloaded to :\(path)")
    }
}
```

### Upload file

Upload file is done with Alamofire.

```swift
client.upload(data: data, filename: "test.json", destinationFolderPath: folder, createParents: true, options: nil) { result in
    switch result {
    case .success(let request, _, _):
        request.uploadProgress { progress in
            print(progress)
        }.response { response in
            if response.error == nil {
                print("Uploaded")
            }
        }
    case .failure(let error):
        print(error)
    }
}
```

### Search file

Search file

```swift
var options = SynologyClient.SearchOptions();
options.pattern = "*.jpg";
client.search(atFolderPath: folderPath, options: options) { result in
    switch result {
    case .success(let task):
        for file in task.files {
            print(file.path)
        } 
    case .failure(let error):
        print(error.description)
    }
}
```

## LICENSE

`SynologyKit` is MIT-licensed. [LICENSE](LICENSE)
