//
//  nsVIewControll.swift
//  FileManager
//
//  Created by tomzhangle on 10/10/17.
//  Copyright © 2017 tomzhangle. All rights reserved.
//

import Cocoa

class nsVIewControll: NSView {
    var myWindowController : NSWindowController?
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
    
    
    override var mouseDownCanMoveWindow: Bool {
        return true
    }
    
   

    override func mouseDown(with : NSEvent) {
        Swift.print("left mouse")
    }
    
    override func rightMouseDown(with : NSEvent) {
        
        myWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "mainWindows") as? NSWindowController
        myWindowController!.showWindow(self)
      //var myWindowController : NSWindowController?
    }
    

}
