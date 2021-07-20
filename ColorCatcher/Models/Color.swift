//
//  Color.swift
//  Colors
//
//  Created by Ramón Miklus on 05/01/2021.
//

import Foundation
import SQLite3

struct Color {
    var id: Int32
    // TODO consider adding also RGB, CMYK, Pantone
    var hex: String
}

class ColorManager {
    // establish connection to the DB as an "undefined" pointer
    var database: OpaquePointer!
    
    static let main = ColorManager()
    
    private init() {}
    
    func connect() {
        if database != nil {
            return
        }
        
        // create folder and file containing sqlite3 DB
        let databaseURL = try! FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("colors.sqlite3")
        
        // open DB -> color &database since we're passing a pointer
        if sqlite3_open(databaseURL.path, &database) != SQLITE_OK {
            print("Could not open DB")
            return
        }
        
        if sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS colors (hex TEXT)", nil, nil, nil) != SQLITE_OK {
            print("Could not create table")
            return
        }
    }
    
    func create(hexString: String) -> Int {
        connect()
        
        print("CONNECT")
        
        var statement: OpaquePointer!
        if sqlite3_prepare_v2(database, "INSERT INTO colors (hex) VALUES(?)", -1, &statement, nil) != SQLITE_OK {
            print("Could not create query")
            return -1
        }
        
        sqlite3_bind_text(statement, 1, NSString(string: hexString).utf8String, -1, nil)
        
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Could not insert note")
            return -1
        }
      
        sqlite3_finalize(statement)
        
        return Int(sqlite3_last_insert_rowid(database))
    }
    
    func getAllColors() -> [Color] {
        connect()
        var result: [Color] = []
        
        var statement: OpaquePointer!
        if sqlite3_prepare_v2(database, "SELECT rowid, hex FROM colors", -1, &statement, nil) != SQLITE_OK {
            print("Error creating select")
            return []
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            result.append(Color(id: Int32(Int(sqlite3_column_int(statement, 0))), hex: String(cString: sqlite3_column_text(statement, 1))))
        }
        
        sqlite3_finalize(statement)
        return result
    }
    
    func save(color: Color) {
        connect()
        
        var statement: OpaquePointer!
        
        if sqlite3_prepare_v2(database, "UPDATE colors SET hex = ? WHERE rowid = ?", -1, &statement, nil) != SQLITE_OK {
            print("Error creating update statement")
        }
        
        sqlite3_bind_text(statement, 1, NSString(string: color.hex).utf8String, -1, nil)
        sqlite3_bind_int(statement, 2, Int32(color.id))
        
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Error running update")
        }
        
        sqlite3_finalize(statement)
    }
    
    func delete(color: Color) {
        connect()
        
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(
            database,
            "DELETE FROM colors WHERE rowid = ?",
            -1,
            &statement,
            nil) != SQLITE_OK {
            print("Error creating color delete statement")
        } else {
            sqlite3_bind_int(statement, 1, color.id)
        }
        
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Error deleting color")
        }
        
        sqlite3_finalize(statement)
    }
    
}
