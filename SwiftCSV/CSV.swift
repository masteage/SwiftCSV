//
//  CSV.swift
//  SwiftCSV
//
//  Created by Naoto Kaneko on 2/18/16.
//  Copyright © 2016 Naoto Kaneko. All rights reserved.
//

import Foundation

extension URL {
	var fileExists: Bool {
		let manager = FileManager.default
		return manager.fileExists(atPath: path)
	}
}

open class CSV {
    static fileprivate let comma: Character = ","
    
    open var header: [String]!
    var _rows: [[String: String]]? = nil
//    var _columns: [String: [String]]? = nil
	
    var text: String
    var delimiter: Character
    
    let loadColumns: Bool
	var fileFullPath = ""
	
	// load
	func load(filename: String)
	{
		// remove all
		removeAll()
		
		// road by filename
		var contents = ""
		do{contents = try String(contentsOfFile: filename, encoding: String.Encoding.utf8)} catch{}
		self.reinit(string: contents, delimiter: CSV.comma, loadColumns: loadColumns)
		self.fileFullPath = filename
	}
	
	// save
	func save() -> Bool
	{
		refreshTextByRow()
		guard let url = URL(string:fileFullPath), url.fileExists else { return false }
		do{ try text.write(toFile: fileFullPath, atomically: false, encoding: String.Encoding.utf8) } catch { return false }
		return true
	}
	
	// row count
	func rowCount() -> Int
	{
		return rows.count
	}
	
	// get
	func get(row: Int, col: Int) -> String
	{
		return rows[row][header[col]]!
	}
	
	// set String
	func setString(row: Int, col: Int, val: String)
	{
		newElement(row: row, col: col)
		_rows?[row][header[col]] = val
	}
	
	// set Int
	func setInteger(row: Int, col: Int, val: Int)
	{
		newElement(row: row, col: col)
		_rows?[row][header[col]] = String(val)
	}
	
	// sort
	// - sort by value (string->int)
	func sort(col: Int)
	{
		let key = header[col]
		_rows = rows.sorted(by: {(left:[String:String], right:[String:String]) -> Bool in
			Int(left[key]!)! < Int(right[key]!)!
		})
	}
	
	// remove
	func removeRow(row: Int)
	{
		_rows?.remove(at: row)
	}
	
	// remove all
	func removeAll()
	{
		header.removeAll()
		_rows?.removeAll()
		_rows = nil
		text = ""
		fileFullPath = ""
		delimiter = CSV.comma
//		loadColumns = false
	}
	
	// refresh text
	private func refreshTextByRow()
	{
		// remove
		text.removeAll()
		
		// header
		for key in header
		{
			text.append(key)
			text.append(",")
		}
		text = text.substring(to: text.index(text.endIndex, offsetBy: -1))
		text.append("\r\n")
		
		// body
		for row in rows
		{
			for key in header
			{
				var tempString = ""
				if( row[key] != nil )
				{
					tempString = row[key]!
				}
				text.append(tempString)
				text.append(",")
			}
			text = text.substring(to: text.index(text.endIndex, offsetBy: -1))
			text.append("\r\n")
		}
		
		text = text.substring(to: text.index(text.endIndex, offsetBy: -1))
	}
	
	// new element
	private func newElement(row: Int, col: Int)
	{
		// row
		if( !rows.indices.contains(row) )
		{
			_rows?.append([String:String]())
		}
		
		// col
		for key in header
		{
			if( rows[row][key] == nil )
			{
				_rows?[row][key] = ""
			}
		}
	}
	
	private func reinit(string: String = "", delimiter: Character = comma, loadColumns: Bool = false)
	{
		self.text = string
		self.delimiter = delimiter
//		self.loadColumns = loadColumns
		
		let createHeader: ([String]) -> () = { head in
			self.header = head
		}
		enumerateAsArray(createHeader, limitTo: 1, startAt: 0)
	}
	
    /// Load a CSV file from a string
    ///
    /// string: string data of the CSV file
    /// delimiter: character to split row and header fields by (default is ',')
    /// loadColumns: whether to populate the columns dictionary (default is true)
    public init(string: String = "", delimiter: Character = comma, loadColumns: Bool = false) {
        self.text = string
        self.delimiter = delimiter
        self.loadColumns = loadColumns
        
        let createHeader: ([String]) -> () = { head in
            self.header = head
        }
        enumerateAsArray(createHeader, limitTo: 1, startAt: 0)
    }
    
    /// Load a CSV file
    ///
    /// name: name of the file (will be passed to String(contentsOfFile:encoding:) to load)
    /// delimiter: character to split row and header fields by (default is ',')
    /// encoding: encoding used to read file (default is NSUTF8StringEncoding)
    /// loadColumns: whether to populate the columns dictionary (default is true)
    public convenience init(name: String, delimiter: Character = comma, encoding: String.Encoding = String.Encoding.utf8, loadColumns: Bool = false) throws {
        let contents = try String(contentsOfFile: name, encoding: encoding)
        self.init(string: contents, delimiter: delimiter, loadColumns: loadColumns)
		self.fileFullPath = name
    }
    
    /// Load a CSV file from a URL
    ///
    /// url: url pointing to the file (will be passed to String(contentsOfURL:encoding:) to load)
    /// delimiter: character to split row and header fields by (default is ',')
    /// encoding: encoding used to read file (default is NSUTF8StringEncoding)
    /// loadColumns: whether to populate the columns dictionary (default is true)
    public convenience init(url: URL, delimiter: Character = comma, encoding: String.Encoding = String.Encoding.utf8, loadColumns: Bool = false) throws {
        let contents = try String(contentsOf: url, encoding: encoding)
        
        self.init(string: contents, delimiter: delimiter, loadColumns: loadColumns)
    }
    
    /// Turn the CSV data into NSData using a given encoding
    open func dataUsingEncoding(_ encoding: String.Encoding) -> Data? {
        return description.data(using: encoding)
    }
}
