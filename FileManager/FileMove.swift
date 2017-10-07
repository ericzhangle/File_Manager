//
//  fileMove.swift
//  FileManager
//
//  Created by tomzhangle on 10/7/17.
//  Copyright © 2017 tomzhangle. All rights reserved.
//

public class FileMove {
    public var path: String? = nil
    public var left: Bool = true
    
    public func printPath() {
        Swift.print( self.path!)
    }
    public static let shared = FileMove()
    
    
    
}
