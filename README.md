# SynologyKit

Note
==
This project is still under developing

Features
==
* Support QuickConnect Sign In
* Support IP/Port Sign In
* List Share Folders
* List Share Files
* Download Share File


Install
== 

```sh
pod 'SynologyKit'
```


Usage
==

TODO

#### Create `SynologyClient` 

```
let address = "192.168.1.5"
let port = 5000
client = SynologyClient(host: address, port: port, enableHTTPS: false)
```

or via Quick Connect ID

```swift
client = SynologyClient(host: "your_quick_connect_id")
```


#### Login in

```swift
let account = "your_synology_account"
let password = "your_synology_password"
client.login(account: account, passwd: password) { [weak self] response in
      switch response {
      case .success(let authRes):
          self?.client?.updateSessionID(authRes.sid)
          self?.handleLoginSuccess()
          if remember {
              LoginManager.shared.save(address: address, username: account, password: password)
          }
          print(authRes.sid)
      case .failure(let error):
          print(error.description)
      }
  }
```

#### List Share Folders

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

#### List Folder

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
