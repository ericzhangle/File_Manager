//
//  ViewController.swift
//  FileManager
//
//  Created by tomzhangle on 10/6/17.
//  Copyright © 2017 tomzhangle. All rights reserved.
//

import Cocoa
import Witness


extension String {
    
    func fileName() -> String {
        
        if let fileNameWithoutExtension = NSURL(fileURLWithPath: self).deletingPathExtension?.lastPathComponent {
            return fileNameWithoutExtension
        } else {
            return ""
        }
    }
    
    func fileExtension() -> String {
        
        if let fileExtension = NSURL(fileURLWithPath: self).pathExtension {
            return fileExtension
        } else {
            return ""
        }
    }
}

class ViewController: NSViewController {
    
    let sizeFormatter = ByteCountFormatter()
    var directory: Directory?
    var directoryItems: [Metadata]?
    var directoryItemsFiles: [Metadata]?
    var directoryFiles: Directory?
    var dataSource1 : Table1!
    var urlLeft: URL?
    var urlRight: URL?
    var bottonClick: Bool = false
    let fm = FileManager.default
    var selectedFile: URL?
    var selectedFileIsLeft: Bool = false
    let baseURL = URL(string: "file:///Users/tomzhangle/From_Desktop")
    
   // var currentFolder: URL?
    
    

    @IBOutlet weak var routeString: NSTextField!
    
    @IBAction func backStepClicked(_ sender: Any) {
        
        if urlLeft?.path != baseURL!.path{
            // Swift.print(urlLeft)
            //Swift.print(baseURL)
            urlLeft = urlLeft?.deletingLastPathComponent()
            
            refreshAndReload(leftURL: urlLeft, rightURL: nil, lableURL: urlLeft,reloadLeft: true,reloadRight: true)
            
        }
            
        else {
            resultField.stringValue = "End of the archive folder"
        }
    }
    
    
    
    //var currentFile: String?
    let fileChange = UserDefaults.standard
  
    
    var start: CFAbsoluteTime!
   
    @IBAction func deleteStorage(_ sender: Any) {
        let array: [String] = []
        
        fileChange.set(array, forKey: "alias")
        
    }
    

    
    //var witness: Witness?
    
    func resolveBasicPath(at url: URL) -> String? {
        do {
            let resourceValues = try url.resourceValues(forKeys: [.isAliasFileKey])
            var targetPath:String? = nil
            //print(resourceValues)
            if resourceValues.isAliasFile! {
                //print(resourceValues.isAliasFile!)
                let data = try NSURL.bookmarkData(withContentsOf:url)
                //NSURLPathKey contains the target path.
                let rv = NSURL.resourceValues(forKeys:[ URLResourceKey.pathKey ], fromBookmarkData: data)
                targetPath = rv![URLResourceKey.pathKey] as! String?
                
                return targetPath
                //let original = try URL(resolvingAliasFileAt: url)
                //return original.path
            }
            
        }catch  {
            print(error)
        }
        return nil
    }
    
    func resolveFinderAlias(at url: URL) -> String? {
        do {
            let resourceValues = try url.resourceValues(forKeys: [.isAliasFileKey])
  
                if resourceValues.isAliasFile! {

                    let original = try URL(resolvingAliasFileAt: url)
                    return original.path
                
            }
            
        }catch  {
            print(error)
        }
        return nil
    }
    


    var sortOrder = Directory.FileOrder.Name
    var sortAscending = true
    
    @IBOutlet weak var tableView: NSTableView!
   
    @IBOutlet weak var fileView: NSTableView!
   
/*
    override var representedObject: Any? {
        didSet {
            
            if let url = representedObject as? URL {
                 urlLeft = url
               // directory = Directory(folderURL: url)
                reloadFileList()
                
            }
            

        }
    }
 */
    func confirmDelete(filePath: URL) -> Bool {
        let msg = NSAlert()
        msg.addButton(withTitle: "OK")      // 1st button
       // msg.addButton(withTitle: "Replace") // 2st button
        msg.addButton(withTitle: "Cancel")  // 3nd button
        msg.messageText = "Confirm Delete"
        msg.informativeText = "Please confirm to Delete file:" + filePath.lastPathComponent
        
        let response: NSModalResponse = msg.runModal()
        
        if (response == NSAlertFirstButtonReturn) {
            return true
        }
        else{
            return false
        }
    }

    
    
    
    
 
    func getString(title: String, question: String, defaultValue: String) -> [String] {
        let msg = NSAlert()
        msg.addButton(withTitle: "OK")      // 1st button
        msg.addButton(withTitle: "Replace") // 2st button
        msg.addButton(withTitle: "Cancel")  // 3nd button
        msg.messageText = title
        msg.informativeText = question
        
        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 400, height: 24))
        txt.stringValue = defaultValue
       // txt.sizeToFit()
        
        msg.accessoryView = txt
        let response: NSModalResponse = msg.runModal()
        
        if (response == NSAlertFirstButtonReturn) {
            if txt.stringValue == "" {
                return [""]
            }
            else{
                return ["txt",txt.stringValue]
            }
        }
        else if response == 1001 && txt.stringValue != ""{
            return ["replace", txt.stringValue]
        }
        else {
            return [""]
        }
    }
    
    func decideFileName (path: String) -> [String] {
        
        let fileName = (path as NSString).lastPathComponent
        let folder = (path as NSString).deletingLastPathComponent
        var newFileName = fileName
        //Swift.print(path)
        var fSuffix = 1
        var userFileName: String = newFileName
        var newUserFileName: String = ""
        //Swift.print(folder)
        while  (newUserFileName == "" && fm.fileExists(atPath: folder + "/" + userFileName)) || (newUserFileName != "" && newUserFileName != userFileName && fm.fileExists(atPath: folder + "/" + newUserFileName) )
        {   if newUserFileName != "" {
            userFileName = newUserFileName
            }
            Swift.print("funny")
            var response = getString(title:"Duplicated Name",question: "Duplicated file name found at dektop, enter a name or hit enter",defaultValue: userFileName)
            if response[0] == "txt"{
                newUserFileName = response[1]
            }
            else if (response[0] == "replace" && fm.fileExists(atPath: folder + "/" + response[1])) {
                do {
                    try fm.removeItem(atPath: folder + "/" + response[1])
                }
                catch {
                    resultField.stringValue = "\(error)"
                    Swift.print(error)
                }
                return ["txt",response[1]]
            }
            else if response[0] == "" {
                return [""]
            }
            else
            {
                resultField.stringValue = "no file to be replaced, cancell operation"
                return [""]
            }
            
        }
        
        if newUserFileName == "" || newUserFileName == userFileName {
            while fm.fileExists(atPath: folder + "/" + newFileName){
                newFileName =  newFileName.fileName() + " " + String(fSuffix) + "." + newFileName.fileExtension()
                fSuffix = fSuffix + 1
            }
            return ["txt",newFileName]
        }
        else
        {
            return ["txt",newUserFileName]
        }
        
    }
   
    func  moveFileToDeskTop (from: String, to: String) {

        
        let fileName = (to as NSString).lastPathComponent
        
        let oldName = (from as NSString).lastPathComponent
        let folder = (from as NSString).deletingLastPathComponent
      //  var newFileName = fileName
        do
        {
            try fm.moveItem(atPath: from, toPath: to)
            
            
            usleep(300000)
            try fm.moveItem(atPath: from + " alias", toPath: folder + "/." + fileName + "_alias")
            usleep(300000)
            if isKeyPresentInUserDefaults(key: "alias") {
                
                var myarray = fileChange.stringArray(forKey: "alias") ?? [String]()
                
                 myarray.append(folder + "/." + fileName + "_alias")
               //myarray = []
                fileChange.set(myarray, forKey: "alias")
            }
            else
            {
                let myarray = [folder + "/." + fileName + "_alias"]
                fileChange.set(myarray, forKey: "alias")
            }
            
            //try fm.linkItem(atPath: decodeFrom! + "_alias", toPath: to + fileName)
            
            
            if (fileName == oldName){
                 resultField.stringValue = "loaded to desktop"
            }
            else{
                resultField.stringValue = "file name changed to :" + fileName
            }
            
            if selectedFileIsLeft{
                    refreshAndReload(leftURL: urlLeft, rightURL: nil, lableURL: urlLeft,reloadLeft: true,reloadRight: true)
            }
            else {
                refreshAndReload(leftURL: urlLeft, rightURL: urlRight, lableURL: urlRight,reloadLeft:false,reloadRight:true)
            }
            
        } catch{
            resultField.stringValue = "\(error)"
            Swift.print(error)
        }
        
    }

    @IBAction func loadToDesktopButtonClicked(_ sender: Any) {
        
        if !bottonClick {
            bottonClick = true
            
            start = CFAbsoluteTimeGetCurrent()
        }
        else{
            
            let elapsed = CFAbsoluteTimeGetCurrent() - start
            
            //Swift.print(elapsed)
            if elapsed < 3 {
                resultField.stringValue = "too fast operation"
                return
            }
            else {
                start = CFAbsoluteTimeGetCurrent()
            }
            
        }
        
        //var from: String?

        
        if selectedFile != nil {
            
            let decodeFrom = selectedFile!.path
            
            let fileName = (decodeFrom as NSString).lastPathComponent
            
            let to = "/Users/tomzhangle/Desktop/"
            
            let response = decideFileName(path: to + fileName)
            var newFileName: String = fileName
            
            if response[0] == "txt" {
                newFileName = response[1]
            }
            else if response[0] == ""{
                return
            }

            let task:Process = Process()
                
           let aliasString = "make new alias file to (posix file \"" + decodeFrom + "\") at POSIX file \"" + (decodeFrom as NSString).deletingLastPathComponent + "\""
            
            // let aliasString = "make new alias file to (posix file \"" + decodeFrom! + "\") at desktop"

            
             //   Swift.print(aliasString)
                //POSIX file \"/Users/tomzhangle/Desktop/lab5\""
                
                task.launchPath = "/usr/bin/osascript"
                task.arguments = ["-e","tell application \"Finder\"","-e",aliasString, "-e", "end tell"]
                Swift.print(aliasString)
                task.launch()
                usleep(300000)
                moveFileToDeskTop(from: decodeFrom, to: to + newFileName)
                usleep(300000)
                selectedFile = nil
        }
        
    }
    
   // @IBOutlet weak var showFolders: NSScrollView!
    
    func returnURL (path: String) -> URL?{
           let escapedString = ("file://" + path).addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            let resultURL = URL(string: escapedString!)
            return resultURL
 
    }
    
    func checkFolder(folder: URL?){
       // Swift.print("folder")
       // Swift.print(folder)
        //Swift.print(baseURL)
        if folder?.path != baseURL!.path {
            refreshAndReload(leftURL: folder!.deletingLastPathComponent(), rightURL: folder, lableURL: urlLeft,reloadLeft: true,reloadRight: true)
        }
        else{
            refreshAndReload(leftURL: folder, rightURL: nil, lableURL: folder,reloadLeft: true,reloadRight: true)
        }
    }

    func checkBack() {
        let newFile = FileMove.shared.backPath
        
        if newFile == nil {
            return
        }
        
        var fileName = (newFile! as NSString).lastPathComponent

        var aliasArray = fileChange.stringArray(forKey: "alias") ?? [String]()
        
        var compareArray: [String] = []
        
        for alias in aliasArray {
        
            
        let escapedString = ("file://" + alias).addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
         let original = resolveFinderAlias(at: URL(string: escapedString!)!)
            
           // Swift.print(original!)
            
            if (original != nil)
            {
              compareArray.append(original!)
            }
            else{
              
               let  basicPath = resolveBasicPath(at:URL(string: escapedString!)!)
                if basicPath == nil {
                    return
                }
                let route = (basicPath! as NSString).deletingLastPathComponent
                
                let checkName = (basicPath! as NSString).lastPathComponent
                
            
                if (checkName == fileName) {
                    
                    do{
                    
                        try fm.moveItem(atPath: newFile!, toPath: basicPath!)
                        usleep(300000)
                            resultField.stringValue = "Warning: Moved file to location"
                        let folder = returnURL(path: route)
   

                        checkFolder(folder: folder)
                    }
                    catch {
                        resultField.stringValue = "Error copying files"
                    }
                    
                }
                else
                {
                    resultField.stringValue = "Error: Failed to move file back"
 
                }
                
                
                do {
                     try fm.removeItem(atPath: alias)
                }
                catch {
                    Swift.print(error)
                }
                let index = aliasArray.index(of: alias)
                aliasArray.remove(at:index!)
                fileChange.set(aliasArray, forKey: "alias")
                return
            }
            
           // compareArray.append(escapedString!)
        }
        
        
        if compareArray.contains(newFile!){
            let index = compareArray.index(of: newFile!)
            let originalLocation = aliasArray[index!]
            let route = (originalLocation as NSString).deletingLastPathComponent
            
            let response = decideFileName(path:route + "/" + fileName)
            
            if response[0] == "txt" {
                fileName = response[1]
            }
            else if response[0] == ""{
                return
            }
            
            do {
                //directoryItemsFiles = try fm.contentsOfDirectory(atPath: rightPath)
                
                try  fm.removeItem(atPath: originalLocation)
                usleep(300000)
                try fm.moveItem(atPath: newFile!, toPath: route + "/" + fileName)
                
                aliasArray.remove(at:index!)
                fileChange.set(aliasArray, forKey: "alias")
                
                resultField.stringValue = "file put back"
                let folder = returnURL(path: route)
                checkFolder(folder: folder)
                //refreshAndReload(leftURL: folder, rightURL: nil, lableURL: folder,reloadLeft: true,reloadRight: true)
                
            } catch {
                resultField.stringValue = "\(error)"
            }
        }
        else {
            putNormal(filePath: newFile!.removingPercentEncoding!)

        }
        
        
}
    func isFolder (atPath:String) -> Bool?{
        
        let escaped = ("file://" + atPath).addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)

        let u = URL(string: escaped!)
        if let v = try? u!.resourceValues(forKeys: [.isDirectoryKey]) {
            if v.isDirectory! {
                return true
            } else {
               return false
            }
        } else {  
            return nil
        }
    }
    
 func putNormal (filePath:String){
    var fileName = ( filePath as NSString).lastPathComponent
    
    let ext = fileName.fileExtension()
    
    let folderName = ext.uppercased() + "S"
    let basePath = baseURL?.path
    let route = basePath! + "/" + folderName
    
    do {
        if isFolder(atPath: filePath) == false{
            if !fm.fileExists(atPath: route)
            {
  
                try fm.createDirectory(atPath: route, withIntermediateDirectories: false)
                
               // reloadFileList()
            }
            
            let response = decideFileName(path: route + "/" + fileName)
            
            if response[0] == "txt" {
                fileName = response[1]
            }
            else if response[0] == ""{
                return
            }
            
            try fm.moveItem(atPath: filePath, toPath: route + "/" + fileName)
            usleep(300000)
            resultField.stringValue = "file put in place"
            let folder = returnURL(path: route)
            checkFolder(folder: folder)
           // refreshAndReload(leftURL: folder, rightURL: nil, lableURL: folder,reloadLeft: true,reloadRight: true)
        }
        else if isFolder(atPath: filePath) == true{
            
            let response = decideFileName(path: basePath! + "/" + fileName)
            
            if response[0] == "txt" {
                fileName = response[1]
            }
            else if response[0] == ""{
                return
            }

           try fm.moveItem(atPath: filePath, toPath: basePath! + "/" + fileName)
           let folder = returnURL(path: basePath!)
            checkFolder(folder: folder)
           //refreshAndReload(leftURL: folder, rightURL: nil, lableURL: folder,reloadLeft: true,reloadRight: true)
            
        }
        else {
            return
        }
    }
    catch {
        
        Swift.print (error)
        
    }
    
    
}
    
    func refreshAndReload (leftURL: URL?,rightURL: URL?, lableURL: URL?, reloadLeft: Bool, reloadRight:Bool){
        
        urlLeft = leftURL
        urlRight = rightURL
        if urlLeft != nil {
            directory = Directory(folderURL: urlLeft!)
            directoryItems = directory?.contentsOrderedBy(sortOrder, ascending: sortAscending)
        }
        else{
            directoryItems = nil
        }
        if reloadLeft {
            tableView.reloadData()
        }
        if urlRight != nil{
            directoryFiles = Directory(folderURL: urlRight!)
            directoryItemsFiles = directoryFiles?.contentsOrderedBy(sortOrder, ascending: sortAscending)
            self.dataSource1.paths = directoryItemsFiles
        }
        else {
            self.dataSource1.paths = nil
        }
        if reloadRight{
            fileView.reloadData()
        }
        
        updateRouteString(route: lableURL)
    }
    /*
func reloadFileList() {
        let route = urlMain!.path
    
        updateRouteString(route: route)
    
    }*/
/*
func reloadFileListFiles() {
        let route = urlFile?.path ?? ""
        updateRouteString(route: route)
        directoryItemsFiles = directoryFiles?.contentsOrderedBy(sortOrder, ascending: sortAscending)
        self.dataSource1.paths = directoryItemsFiles ?? []
        Swift.print(directoryItemsFiles)
        //Swift.print("result:" + String(self.dataSource1.paths?.count ?? 0))
        fileView.reloadData()
    }
 */

func updateFileView(){
        let itemsSelected = fileView.selectedRow
        
        //Swift.print(String(itemsSelected))
    if  !(itemsSelected >= 0 && itemsSelected < directoryItemsFiles!.count) {
        selectedFile = nil
        selectedFileIsLeft = false
        return
    }
        let item = directoryItemsFiles![itemsSelected]
        
        selectedFile = item.url
    
        selectedFileIsLeft = false
    
    refreshAndReload(leftURL: urlLeft, rightURL: urlRight, lableURL: selectedFile,reloadLeft: false,reloadRight:false )
    
      // directoryFiles!.url.path + "/" + item.name
       // let escapedString = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
       // FileMove.shared.path = escapedString
       // FileMove.shared.left = false
       // routeString.stringValue = urlString
       //updateRouteString(route: urlString)
       // Swift.print(escapedString!)
    }
    
    func updateRouteString (route: URL?) {
        
        routeString.stringValue = route?.path ?? "";
        routeString.sizeToFit()
    }
    
    func updateStatus() {
        
      //  let text: String
        
        // 1
        let itemsSelected = tableView.selectedRow
        //Swift.print("select")
        //Swift.print(String(itemsSelected))
        
        if  !(itemsSelected >= 0 && itemsSelected < directoryItems!.count) {
            selectedFile = nil
           selectedFileIsLeft = true
                return
        }
        let item = directoryItems![itemsSelected]
        
       // Swift.print(item.name)
        selectedFile = item.url
        
       selectedFileIsLeft = true

        if item.isFolder {
            
            //let newURL = URL(string: "file:///Users/tomzhangle/Desktop/" + item.name)
            refreshAndReload(leftURL: urlLeft, rightURL: selectedFile, lableURL: selectedFile,reloadLeft: false,reloadRight: true)
 
        }else {
           refreshAndReload(leftURL: urlLeft, rightURL: nil, lableURL: selectedFile,reloadLeft: false,reloadRight: true)
            
        }
        /*
        directoryItemsFiles = directoryFiles?.contentsOrderedBy(sortOrder, ascending: sortAscending)
        self.dataSource1.paths = directoryItemsFiles ?? []
        Swift.print(directoryItemsFiles)
        //Swift.print("result:" + String(self.dataSource1.paths?.count ?? 0))
        fileView.reloadData()
*/
       // resultField.stringValue = filePath
}
    
   func tableViewDoubleClick(_ sender:AnyObject) {
    //Swift.print ("double clicked")
        
       // Swift.print("double clicked")

   
        guard tableView.selectedRow >= 0 && tableView.selectedRow < directoryItems!.count ,
            let item = directoryItems?[tableView.selectedRow] else {
                return
        }
    
        if item.isFolder {
            
            // 2
           // self.representedObject = item.url as Any
            
            refreshAndReload(leftURL: item.url, rightURL: nil, lableURL: item.url, reloadLeft: true, reloadRight: true)
        }
        else {
            // 3
            NSWorkspace.shared().open(item.url as URL)
        }
 
    }
    
    func fileViewDoubleClick(_ sender:AnyObject) {
        
        guard fileView.selectedRow >= 0 && tableView.selectedRow < directoryItemsFiles!.count ,
            let item = directoryItemsFiles?[fileView.selectedRow] else {
                return
        }
        
        if item.isFolder {
            
            
            refreshAndReload(leftURL: item.url, rightURL: nil, lableURL: item.url, reloadLeft: true, reloadRight: true)
        }
        else {
            // 3
            NSWorkspace.shared().open(item.url as URL)
        }
        
    }
    func checkDelete (){
        if selectedFile == nil{
            return
        }
        else{
            
            let response = confirmDelete(filePath:selectedFile!)
            if !response {
                return
            }
            else {
                do {
                    try fm.removeItem(at: selectedFile!)
                    if selectedFileIsLeft{
                        refreshAndReload(leftURL: urlLeft, rightURL: nil, lableURL: urlLeft, reloadLeft: true, reloadRight: true)
                    }
                    else{
                        refreshAndReload(leftURL: urlLeft, rightURL: urlRight, lableURL: urlLeft, reloadLeft: false, reloadRight: true)
                    }
                    
                    
                }
                catch {
                    Swift.print(error)
                }
                
                
            }
        }
        
        
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        updateStatus()
        }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    @IBOutlet weak var resultField: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        urlLeft = URL(string: "file:///Users/tomzhangle/From_Desktop")
        urlRight = nil
       // start = CFAbsoluteTimeGetCurrent()
  
        tableView.target = self
        
        fileView.target = self.dataSource1
        
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        fileView.doubleAction = #selector(fileViewDoubleClick(_:))
        
        self.dataSource1 = Table1()
       // self.dataSource1.paths = nil
        fileView.dataSource = self.dataSource1
        fileView.delegate = self.dataSource1
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkDelete),name:NSNotification.Name(rawValue: "checkDelete"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateFileView),name:NSNotification.Name(rawValue: "fileSelected"), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(self.checkBack),name:NSNotification.Name(rawValue: "checkBack"), object: nil)
        //let escapedString = "file:///Users/tomzhangle/From_Desktop/IoT%20pics/screen%20shot%202017-10-03%20at%209.08.43%20pm.png%20alias"
        
        
        //Screen%20Shot%202017%2D10%2D04%20at%209.57.42%20AM.png%20alias"
        let array = fileChange.stringArray(forKey: "alias") ?? [String]()
         refreshAndReload(leftURL: urlLeft, rightURL: nil, lableURL: urlLeft,reloadLeft: true,reloadRight: true)
        //Swift.print(resolveFinderAlias(at: URL(string: (escapedString))!) ?? "not found")
        Swift.print(array)
        }
    //let array = fileChange.stringArray(forKey: "alias") ?? [String]()

}


extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return directoryItems?.count ?? 0
    }
}


extension ViewController: NSTableViewDelegate {
    
    fileprivate enum CellIdentifiers {
            static let Folders = "Folders"
      }
    
        func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var image: NSImage?
        var text: String = ""
        var cellIdentifier: String = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        
        // 1
        guard let item = directoryItems?[row] else {
            return nil
        }
        //Swift.print(item.name)
        // 2
            if tableColumn == tableView.tableColumns[0] {
            image = item.icon
            text = item.name
            cellIdentifier = CellIdentifiers.Folders
        }

            if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView{
            cell.textField?.stringValue = text
            cell.imageView?.image = image ?? nil
            return cell
        }
        return nil
    }
}





