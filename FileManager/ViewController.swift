//
//  ViewController.swift
//  FileManager
//
//  Created by tomzhangle on 10/6/17.
//  Copyright © 2017 tomzhangle. All rights reserved.
//

import Cocoa
import Witness


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
    
    let fileChange = UserDefaults.standard
   
    
    
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

   
    func  moveFileToDeskTop (from: String, to: String) {
        
        let fileName = (from as NSString).lastPathComponent
        
        do
        {
            
            try fm.moveItem(atPath: from, toPath: to + fileName)
            
            
            if isKeyPresentInUserDefaults(key: "alias") {
                
                var myarray = self.fileChange.stringArray(forKey: "alias") ?? [String]()
                
                myarray.append(from)
                fileChange.set(myarray, forKey: "alias")
            }
            else
            {
                let myarray = [from]
                fileChange.set(myarray, forKey: "alias")
            }
            
            //try fm.linkItem(atPath: decodeFrom! + "_alias", toPath: to + fileName)
            
            
            
            resultField.stringValue = "loaded to desktop"
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
        }
        
    }


    @IBAction func buttonClicked(_ sender: Any) {
        
    
        let from: String? = FileMove.shared.path
        
    
        let to = "/Users/tomzhangle/Desktop/"
        
        if from != nil {
   
                Swift.print(from!)
               // Swift.print(to)
                let decodeFrom = from!.removingPercentEncoding
                let fileName = (decodeFrom! as NSString).lastPathComponent
                Swift.print(fileName)
                
                let myGroup = DispatchGroup()
                myGroup.enter()
                let task:Process = Process()
                
                let aliasString = "make new alias to file (posix file \"" + decodeFrom!
                    + "\") at POSIX file \"" + (decodeFrom! as NSString).deletingLastPathComponent + "\""
                
                Swift.print(aliasString)
                //POSIX file \"/Users/tomzhangle/Desktop/lab5\""
                
                task.launchPath = "/usr/bin/osascript"
                task.arguments = ["-e","tell application \"Finder\"","-e",aliasString, "-e", "end tell"]
                
                task.launch()
                
                myGroup.leave() //// When your task completes
                myGroup.notify(queue: DispatchQueue.main) {
                    moveFileToDeskTop(decodeFrom!, to)

        }
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
        
        let aliasArray = fileChange.stringArray(forKey: "alias") ?? [String]()
        
        var compareArray: [String] = []
        
        for alias in aliasArray {
            
        let escapedString = ("file://" + alias).addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
         let original = resolveFinderAlias(at: URL(string: (escapedString)!)!)
            compareArray.append(original!)
            
           // compareArray.append(escapedString!)
        }
        
        Swift.print("newFile")
        Swift.print(newFile!)
        Swift.print("compareArray")
        Swift.print(compareArray)
        
        
        if compareArray.contains(newFile!){
            let index = compareArray.index(of: newFile!)
            let originalLocation = aliasArray[index!]
            
            let fileName = (newFile! as NSString).lastPathComponent
            let route = (originalLocation as NSString).deletingLastPathComponent
            
            do {
                //directoryItemsFiles = try fm.contentsOfDirectory(atPath: rightPath)
                
                try  fm.removeItem(atPath: originalLocation)
                try fm.moveItem(atPath: newFile!, toPath: route + "/" + fileName)
                resultField.stringValue = "file put back"
            } catch {
                resultField.stringValue = "\(error)"
            }
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
        
        if  itemsSelected >= directoryItems!.count {
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
            
           // Swift.print("empty")
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
        
        Swift.print(fileChange.stringArray(forKey: "alias") ?? [String]())

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
        /*
        else if tableColumn == tableView.tableColumns[1] {
            text = item.name
            cellIdentifier = CellIdentifiers.RightFile
            
        }*/
        
        
            /*
            text = dateFormatter.string(from: item.date)
            cellIdentifier = CellIdentifiers.DateCell
        } else if tableColumn == tableView.tableColumns[2] {
            text = item.isFolder ? "--" : sizeFormatter.string(fromByteCount: item.size)
            cellIdentifier = CellIdentifiers.SizeCell
        }*/
        
        // 3
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            cell.imageView?.image = image ?? nil
            return cell
        }
        return nil
    }
}





