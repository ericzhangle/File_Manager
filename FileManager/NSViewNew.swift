//
//  NSViewNew.swift
//  FileManager
//
//  Created by tomzhangle on 10/7/17.
//  Copyright © 2017 tomzhangle. All rights reserved.
//

import Cocoa

class NSViewNew: NSView {
    
    //@IBOutlet weak var viewController: ViewController!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // Declare and register an array of accepted types
        register(forDraggedTypes: [NSFilenamesPboardType, NSURLPboardType, NSPasteboardTypeTIFF])
    }
    
    //let fileTypes = ["txt", "jpeg", "bmp", "png", "gif"]
  //  var fileTypeIsOk = false
    var droppedFilePath: String?
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
        /*
        if checkExtension(drag: sender) {
            fileTypeIsOk = true
            return .copy
        } else {
            fileTypeIsOk = false
            return []
        }*/
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
        /*
        if fileTypeIsOk {
            
            //Swift.print("zhangle")
            return .copy
        } else {
            return []
        }*/
    }
    @IBOutlet weak var resultField: NSTextField!
    
  /*
    @IBAction func buttonClicked(_ sender: Any) {
        
        let fm = FileManager.default
        let path = "/Users/tomzhangle/Desktop"
        // Swift.print("zhangle")
        
        var content:String = ""
        do {
            
            let items = try fm.contentsOfDirectory(atPath: path)
            
            for item in items {
                content += item + "\n"
            }
        } catch {
            resultField.stringValue = "failed to read file"
        }

    }
    */

    
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if let board = sender.draggingPasteboard().propertyList(forType: "NSFilenamesPboardType") as? NSArray,
            let imagePath = board[0] as? String {
            // THIS IS WERE YOU GET THE PATH FOR THE DROPPED FILE
            droppedFilePath = imagePath
            
            let fileName = (droppedFilePath! as NSString).lastPathComponent
            
            FileMove.shared.backPath = droppedFilePath!
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "checkBack"), object: nil)
           /*
            let fm = FileManager.default
            do
            {
                //Swift.print(droppedFilePath!)
                //Swift.print("/Users/tomzhangle/From_Desktop/" + fileName)
                try fm.moveItem(atPath: droppedFilePath!, toPath:"/Users/tomzhangle/From_Desktop/" + fileName)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil)
                
            //   Swift.print(viewController.timePut)
                resultField.stringValue = "moved to place"
            } catch{
                resultField.stringValue = "failed to move file"
            }
            */

            
            return true
        }
        return false
    }
    /*
    func checkExtension(drag: NSDraggingInfo) -> Bool {
        if let board = drag.draggingPasteboard().propertyList(forType: "NSFilenamesPboardType") as? NSArray,
            let  path = board[0] as? String {
            let url = NSURL(fileURLWithPath: path)
            if let fileExtension = url.pathExtension?.lowercased() {
                return fileTypes.contains(fileExtension)
            }
        }
        return false
    }*/
    
}
