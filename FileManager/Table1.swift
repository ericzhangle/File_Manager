//
//  Table1.swift
//  FileManager
//
//  Created by tomzhangle on 10/7/17.
//  Copyright © 2017 tomzhangle. All rights reserved.
//

import Cocoa

class Table1: NSTableView, NSTableViewDataSource, NSTableViewDelegate
    
{   public var paths: [Metadata]?
    var cellIdentifier: String = ""
    
    override func draw(_ dirtyRect: NSRect)
    {
        super.draw(dirtyRect)
    }
    func numberOfRows(in tableView: NSTableView) -> Int {
       // Swift.print("rows :" + String(paths?.count ?? 0))
        return paths?.count ?? 0
    }
    
    fileprivate enum CellIdentifiers {
        static let Files = "Files"
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
       // FileMove.shared.path = escapedString
        
       // FileMove.shared.path = "123123"
        //FileMove.shared.printPath()
        
  NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fileSelected"), object: nil)
        
    
    }
    
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var image: NSImage?
        // let path = ["zhangle","nimei","buxing"]
        
        guard let item = paths?[row] else {
            return nil
        }
       
       // var text: String = "Zhang Le"
       // var cellIdentifier =
        
        // 2
        if tableColumn == tableView.tableColumns[0] {
            image = item.icon
            cellIdentifier = CellIdentifiers.Files
        }
        
        
        
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            //Swift.print("here")
            cell.textField!.stringValue = item.name
            cell.imageView?.image = image ?? nil
            return cell
        }
        return nil
    }

}
