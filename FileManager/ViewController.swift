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
    let urlMain = URL(string: "file:///Users/tomzhangle/From_Desktop/")
    var urlFile: URL?
    let fm = FileManager.default

    //var currentFile: String?
    let fileChange = UserDefaults.standard
    var from: String?
    
    var start: CFAbsoluteTime!
   
    @IBAction func deleteStorage(_ sender: Any) {
        let array: [String] = []
        
        //myarray = []
        fileChange.set(array, forKey: "alias")
        
    }
    
    
    //var witness: Witness?
    
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
    

    

   // var SelectedPath: String = ""
    
   public var timePut: String = ""
    
   // var directoryFiles: Directory?
    
    //added
    //var directoryItemsFiles: [String] = []
    var sortOrder = Directory.FileOrder.Name
    var sortAscending = true
    
    @IBOutlet weak var tableView: NSTableView!
   
    @IBOutlet weak var fileView: NSTableView!
   

    override var representedObject: Any? {
        didSet {
            
            if let url = representedObject as? URL {
               // Swift.print(url)
                directory = Directory(folderURL: url)
                reloadFileList()
                
            }
            

        }
    }
    func getString(title: String, question: String, defaultValue: String) -> [String] {
        let msg = NSAlert()
        msg.addButton(withTitle: "OK")      // 1st button
        msg.addButton(withTitle: "Replace") // 2st button
        msg.addButton(withTitle: "Cancel")  // 3nd button
        msg.messageText = title
        msg.informativeText = question
        
        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        txt.stringValue = defaultValue
        
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
        Swift.print(folder)
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
            
            if FileMove.shared.left {
                directory = Directory(folderURL: self.urlMain!)
                reloadFileList()
            }
            else {
                directoryFiles = Directory(folderURL: self.urlFile!)
                reloadFileListFiles()
            }
            
        } catch{
            resultField.stringValue = "\(error)"
            Swift.print(error)
        }
        
    }


    @IBAction func buttonClicked(_ sender: Any) {
        
        if FileMove.shared.path! == from
        {
            let elapsed = CFAbsoluteTimeGetCurrent() - start
            
            //Swift.print(elapsed)
            if elapsed < 5 {
                resultField.stringValue = "too fast operation"
                return
                
            }
        }
        else
        {
            start = CFAbsoluteTimeGetCurrent()
        }
       
        from = FileMove.shared.path
        

        
        if from != nil {
            
            let decodeFrom = from!.removingPercentEncoding
            
            let fileName = (decodeFrom! as NSString).lastPathComponent
            
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
                
           let aliasString = "make new alias file to (posix file \"" + decodeFrom! + "\") at POSIX file \"" + (decodeFrom! as NSString).deletingLastPathComponent + "\""
            
            // let aliasString = "make new alias file to (posix file \"" + decodeFrom! + "\") at desktop"

            
             //   Swift.print(aliasString)
                //POSIX file \"/Users/tomzhangle/Desktop/lab5\""
                
                task.launchPath = "/usr/bin/osascript"
                task.arguments = ["-e","tell application \"Finder\"","-e",aliasString, "-e", "end tell"]
                Swift.print(aliasString)
                task.launch()
                usleep(300000)
                moveFileToDeskTop(from: decodeFrom!, to: to + newFileName)
                usleep(300000)
                FileMove.shared.path = nil
        }
        
    }
    
   // @IBOutlet weak var showFolders: NSScrollView!
    
     func reloadFileList() {
        directory = Directory(folderURL: urlMain!)
        directoryItems = directory?.contentsOrderedBy(sortOrder, ascending: sortAscending)
        tableView.reloadData()
    }
    func checkBack() {
        let newFile = FileMove.shared.backPath
        
        let fileName = (newFile! as NSString).lastPathComponent

        
        
       
        
        var aliasArray = fileChange.stringArray(forKey: "alias") ?? [String]()
        
        var compareArray: [String] = []
        
        for alias in aliasArray {
        
            
        let escapedString = ("file://" + alias).addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
         let original = resolveFinderAlias(at: URL(string: (escapedString)!)!)
            
            if (original != nil)
            {
              compareArray.append(original!)
            }
            else{
                //Swift.print(escapedString!)
                
                do{
                  let route = (alias as NSString).deletingLastPathComponent
                  try fm.moveItem(atPath: newFile!, toPath: route + "/" + fileName)
                    usleep(300000)
                   let newOriginal = resolveFinderAlias(at: URL(string: (escapedString)!)!)
                    if newOriginal != nil{
                        
                      resultField.stringValue = "Warning: Moved file to location"
                        if route == "/Users/tomzhangle/From_Desktop" {
                            reloadFileList()
                        }
                        else
                        {
                        let escaped = route.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
                            
                            urlFile = URL(string:escaped!)
                            directoryFiles = Directory(folderURL: urlFile!)
                            reloadFileListFiles()
                        }
                        
                    }
                    else
                    {
                       try fm.moveItem(atPath:  route + "/" + fileName, toPath: newFile!)
                       resultField.stringValue = "Error: Failed to move file back"
                    }
                    
                    try fm.removeItem(atPath: alias)
                    
                    let index = aliasArray.index(of: alias)
                    aliasArray.remove(at:index!)
                    fileChange.set(aliasArray, forKey: "alias")
                    
            }
                catch {
                    resultField.stringValue = "Error copying files"
                }
                
                return
            }
            
           // compareArray.append(escapedString!)
        }
        
        
        if compareArray.contains(newFile!){
            let index = compareArray.index(of: newFile!)
            let originalLocation = aliasArray[index!]
            let route = (originalLocation as NSString).deletingLastPathComponent
            
            do {
                //directoryItemsFiles = try fm.contentsOfDirectory(atPath: rightPath)
                
                try  fm.removeItem(atPath: originalLocation)
                usleep(300000)
                try fm.moveItem(atPath: newFile!, toPath: route + "/" + fileName)
                
                aliasArray.remove(at:index!)
                fileChange.set(aliasArray, forKey: "alias")
                
                resultField.stringValue = "file put back"
                if route == "/Users/tomzhangle/From_Desktop" {
                   reloadFileList()
                }
                else
                {
                    
                let escaped = route.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
                    
                urlFile = URL(string:escaped!)
                directoryFiles = Directory(folderURL: urlFile!)
                reloadFileListFiles()
                    
                }
                
            } catch {
                resultField.stringValue = "\(error)"
            }
        }
        else {
            
            
            
            
        }
        
        
}

func reloadFileListFiles() {
        directoryItemsFiles = directoryFiles?.contentsOrderedBy(sortOrder, ascending: sortAscending)
        self.dataSource1.paths = directoryItemsFiles ?? []
        //Swift.print("result:" + String(self.dataSource1.paths?.count ?? 0))
        fileView.reloadData()
    }
    
func updateFileView(){
        let itemsSelected = fileView.selectedRow
        
        //Swift.print(String(itemsSelected))
    if  !(itemsSelected >= 0 && itemsSelected < directoryItemsFiles!.count) {
        FileMove.shared.path = nil
        FileMove.shared.left = false
        return
    }
        let item = directoryItemsFiles![itemsSelected]
        
        let urlString = directoryFiles!.url.path + "/" + item.name
        
        let escapedString = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        FileMove.shared.path = escapedString
        FileMove.shared.left = false

       // Swift.print(escapedString!)
    }
    
    
    func updateStatus() {
        
      //  let text: String
        
        // 1
        let itemsSelected = tableView.selectedRow
        Swift.print("select")
        //Swift.print(String(itemsSelected))
        
        if  !(itemsSelected >= 0 && itemsSelected < directoryItems!.count) {
            FileMove.shared.path = nil
            FileMove.shared.left = true
                return
        }
        let item = directoryItems![itemsSelected]
        
        let urlString = directory!.url.path + "/" + item.name
        
        let escapedString = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        FileMove.shared.path = escapedString
        
        FileMove.shared.left = true
        
        //FileMove.shared.printPath()
        
        
        // self.SelectedPath = escapedString!
       // Swift.print(self.SelectedPath)
        if item.isFolder {
            
            //let newURL = URL(string: "file:///Users/tomzhangle/Desktop/" + item.name)
            
        
                 urlFile = URL(string: escapedString!)
                directoryFiles = Directory(folderURL: urlFile!)

 
        }else {
            directoryFiles = nil
            
           // resultField.stringValue = resolveFinderAlias(at: URL(string: "file://" + escapedString!)!) ?? "not alias"
        }
        
        reloadFileListFiles()

       // resultField.stringValue = filePath
}

    func tableViewSelectionDidChange(_ notification: Notification) {
       // Swift.print("update")
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
        
        
        reloadFileList()

        
        self.dataSource1 = Table1()
        self.dataSource1.paths = []
        fileView.dataSource = self.dataSource1
        fileView.delegate = self.dataSource1
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadFileList),name:NSNotification.Name(rawValue: "refresh"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateFileView),name:NSNotification.Name(rawValue: "fileSelected"), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(self.checkBack),name:NSNotification.Name(rawValue: "checkBack"), object: nil)
        //let escapedString = "file:///Users/tomzhangle/From_Desktop/IoT%20pics/screen%20shot%202017-10-03%20at%209.08.43%20pm.png%20alias"
        
        
        //Screen%20Shot%202017%2D10%2D04%20at%209.57.42%20AM.png%20alias"
        let array = fileChange.stringArray(forKey: "alias") ?? [String]()

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





