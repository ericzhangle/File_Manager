//
//  mainWindowView.swift
//  FileManager
//
//  Created by tomzhangle on 10/10/17.
//  Copyright © 2017 tomzhangle. All rights reserved.
//

import Cocoa

class mainWindowView: NSViewController {

   // @IBOutlet var button: nsVIewControll!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.window?.titlebarAppearsTransparent = true
        self.view.window?.isMovableByWindowBackground = true
        
        //button1.isHidden = true
        
      //  button.mouseDownCanMoveWindow = true
        
      self.view.wantsLayer = true
       
          }
    override func awakeFromNib() {
        if self.view.layer != nil {
            let color : CGColor = CGColor(red: 0.27, green: 0.91, blue: 0.64, alpha: 0.5)
            self.view.layer?.backgroundColor = color

        }
        
    }
    
    
    
}
