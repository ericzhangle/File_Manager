//
//  NSWindowNew.swift
//  FileManager
//
//  Created by tomzhangle on 10/7/17.
//  Copyright © 2017 tomzhangle. All rights reserved.
//

import Cocoa

class NSWindowNew: NSWindow {
    override init(contentRect: NSRect, styleMask style: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)
        
        // Set the opaque value off,remove shadows and fill the window with clear (transparent)
        self.isOpaque = false
        self.hasShadow = false
        self.backgroundColor = NSColor.clear
        
        // Change the title bar appereance
        self.title = "My Custom Title"
        //self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
    }
}
