//
//  Constants.swift
//  ColorCatcher
//
//  Created by Ramón Miklus on 21/07/21.
//

import Foundation

struct K {
    static let appName = "Color Catcher"
    static let cellIdentifier = "NoteCell"
    static let colorSegue = "ColorSegue"
    
    struct Fonts {
        static let standard = "Helvetica Neue"
        static let bold = "HelveticaNeue-Bold"
    }
    
    struct Messages {
        static let noImage = "No image found"
        static let instructions = "Take a picture of something to catch the average HEX color"
    }
    
    struct Table {
        static let deleteRow = "delete"
    }
}
