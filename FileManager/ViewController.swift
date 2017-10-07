//
//  ViewController.swift
//  FileManager
//
//  Created by tomzhangle on 10/6/17.
//  Copyright © 2017 tomzhangle. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    let sizeFormatter = ByteCountFormatter()
    var directory: Directory?
    var directoryItems: [Metadata]?
    var directoryItemsFiles: [Metadata]?
    var directoryFiles: Directory?
    var dataSource1 : Table1!
    
    let urlMain = URL(string: "file:///Users/tomzhangle/From_Desktop/")
    var urlFile: URL?
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

   

    @IBAction func buttonClicked(_ sender: Any) {
        
        let fm = FileManager.default
      
        let from: String? = FileMove.shared.path
        
        
        
        let to = "/Users/tomzhangle/Desktop/"
        
        if from != nil {
            do
            {
                Swift.print(from!)
               // Swift.print(to)
                let decodeFrom = from!.removingPercentEncoding
                let fileName = (decodeFrom! as NSString).lastPathComponent
                Swift.print(fileName)
                try fm.moveItem(atPath: decodeFrom!, toPath: to + fileName)
                
                resultField.stringValue = "loaded to desktop"
                if FileMove.shared.left {
                   directory = Directory(folderURL: urlMain!)
                   reloadFileList()
                }
                else {
                    directoryFiles = Directory(folderURL: urlFile!)
                    reloadFileListFiles()
                }
                
            } catch{
                resultField.stringValue = "\(error)"
            }
            
        }

       // resultField.stringValue = fm.homeDirectoryForCurrentUser.path
        
    }
    
   // @IBOutlet weak var showFolders: NSScrollView!
    
     func reloadFileList() {
        directory = Directory(folderURL: urlMain!)
        directoryItems = directory?.contentsOrderedBy(sortOrder, ascending: sortAscending)
        tableView.reloadData()
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
        
        let escapedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
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
        
        let item = directoryItems![itemsSelected]
        
        let urlString = directory!.url.path + "/" + item.name
        
        let escapedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        FileMove.shared.path = escapedString
        
        FileMove.shared.left = true
        
        //FileMove.shared.printPath()
        
        
        // self.SelectedPath = escapedString!
       // Swift.print(self.SelectedPath)
        if item.isFolder {
            
            //let newURL = URL(string: "file:///Users/tomzhangle/Desktop/" + item.name)
            
        
                 urlFile = URL(string: escapedString!)
                directoryFiles = Directory(folderURL: urlFile!)

            
            
            
                
           //Swift.print("file:///Users/tomzhangle/Desktop/" + item.name)
 
           // let fm = FileManager.default
            /*
            let rightPath = "/Users/tomzhangle/Desktop/" + item.name
            do {
                directoryItemsFiles = try fm.contentsOfDirectory(atPath: rightPath)
            } catch {
                resultField.stringValue = "failed to read file"
            }*/
            
          //  self.dataSource1.paths = directoryItemsFiles
           // fileView.reloadData()
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
    
    @IBOutlet weak var resultField: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        reloadFileList()
        
       /*
        let fm = FileManager.default
        

        let rightPath = "/Users/tomzhangle/Documents"
        do {
            
            directoryItemsFiles = try fm.contentsOfDirectory(atPath: rightPath)
        } catch {
            resultField.stringValue = "failed to read file"
        }*/
        
        self.dataSource1 = Table1()
        self.dataSource1.paths = []
        fileView.dataSource = self.dataSource1
        fileView.delegate = self.dataSource1
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadFileList),name:NSNotification.Name(rawValue: "refresh"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateFileView),name:NSNotification.Name(rawValue: "fileSelected"), object: nil)

    }
    


}
extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return directoryItems?.count ?? 0
    }
}





extension ViewController: NSTableViewDelegate {
    
    fileprivate enum CellIdentifiers {
            static let Folders = "Folders"
        //static let NameCell = "NameCellID"
       // static let DateCell = "DateCellID"
       // static let SizeCell = "SizeCellID"
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




