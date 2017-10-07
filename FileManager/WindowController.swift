//
//  WindowController.swift
//  FileManager
//
//  Created by tomzhangle on 10/7/17.
//  Copyright © 2017 tomzhangle. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    @IBAction func openDocument(_ sender: AnyObject?) {
        
        let openPanel = NSOpenPanel()
        openPanel.showsHiddenFiles = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        
        openPanel.beginSheetModal(for: self.window!) { response in
            guard response == NSFileHandlingPanelOKButton else {
                return
            }
            self.contentViewController?.representedObject = openPanel.url
        }
    }


}
