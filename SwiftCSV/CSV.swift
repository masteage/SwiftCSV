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

@objc open class CSV : NSObject{
    static fileprivate let comma: Character = ","
	static fileprivate let s_delimiter = comma
//	static fileprivate let dollar: Character = "$"
//	static fileprivate let s_delimiter = dollar
	
    open var header = [String]()
    var _rows: [[String: String]]? = nil
//    var _columns: [String: [String]]? = nil
	
    var text = ""
    var delimiter = s_delimiter
    
	var loadColumns = false
	var fileFullPath = ""
	
	/// load file
	public func load(filename: String)
	{
		// remove all
		removeAll()
		
		// road by filename
		var contents = ""
		do{contents = try String(contentsOfFile: filename, encoding: String.Encoding.utf8)} catch{}
		self.reinit(string: contents, delimiter: delimiter, loadColumns: loadColumns)
		self.fileFullPath = filename
	}
	
	/// save file
	public func save(filename: String) -> Bool
	{
		fileFullPath = filename
		return save()
	}
	
	public func save() -> Bool
	{
		refreshTextByRow()
		do{ try text.write(toFile: fileFullPath, atomically: false, encoding: String.Encoding.utf8) } catch { return false }
		return true
	}
	
	/// header
	public func addHeader(header: String)
	{
		self.header.append(header)
	}
	
	/// row count
	public func rowCount() -> Int
	{
		return rows.count
	}
	
	/// row index
	public func rowIndex(key: String, value: String) -> Int
	{
		var index = 0
		for row in rows
		{
			if(row[key] != nil && row[key] == value )
			{
				return index
			}
			index += 1
		}
		return -1
	}
	
	/// get
	public func get(row: Int, col: Int) -> String
	{
		return rows[row][header[col]]!
	}
	
	/// get - String
	public func getString(row: Int, col: Int) -> String
	{
		return rows[row][header[col]]!
	}
	
	/// get - String by header
	public func getStringByHeader(row: Int, col: String) -> String
	{
		return rows[row][col]!
	}
	
	/// get - Int
	public func getInteger(row: Int, col: Int) -> Int
	{
		return Int(rows[row][header[col]]!) ?? 0
	}
	
	/// get - Int by header
	public func getIntegerByHeader(row: Int, col: String) -> Int
	{
		return Int(rows[row][col]!) ?? 0
	}
	
	/// set - String
	public func setString(row: Int, col: Int, val: String)
	{
		newElement(row: row)
		_rows?[row][header[col]] = val
	}
	
	public func setStringByHeader(row: Int, col: String, val: String)
	{
		newElement(row: row)
		_rows?[row][col] = val
	}
	
	/// set - Int
	public func setInteger(row: Int, col: Int, val: Int)
	{
		newElement(row: row)
		_rows?[row][header[col]] = String(val)
	}
	
	/// sort
	/// : sort by value (string->int)
	public func sort(col: Int)
	{
		let key = header[col]
		_rows = rows.sorted(by: {(left:[String:String], right:[String:String]) -> Bool in
			Int(left[key]!)! < Int(right[key]!)!
		})
	}
	
	/// remove
	public func removeRow(row: Int)
	{
		_rows?.remove(at: row)
	}
	
	/// remove all
	public func removeAll()
	{
		header.removeAll()
		_rows?.removeAll()
		_rows = nil
		text = ""
		fileFullPath = ""
		delimiter = CSV.s_delimiter
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
			text.append(delimiter)
		}
		text = text.substring(to: text.index(text.endIndex, offsetBy: -1))
//		text.append("\r\n")
		text.append("\n")
		
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
				text.append(delimiter)
			}
			text = text.substring(to: text.index(text.endIndex, offsetBy: -1))
//			text.append("\r\n")
			text.append("\n")
		}
		
//		text = text.substring(to: text.index(text.endIndex, offsetBy: -1))
	}
	
	// new element
	private func newElement(row: Int)
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
	
	private func reinit(string: String = "", delimiter: Character = s_delimiter, loadColumns: Bool = false)
	{
		self.text = string
		self.delimiter = delimiter
		self.loadColumns = loadColumns
		
		let createHeader: ([String]) -> () = { head in
			self.header = head
		}
		enumerateAsArray(createHeader, limitTo: 1, startAt: 0)
	}
	
	/// default init
	public override init()
	{
		super.init()
	}
	
    /// Load a CSV file from a string
    ///
    /// string: string data of the CSV file
    /// delimiter: character to split row and header fields by (default is ',')
    /// loadColumns: whether to populate the columns dictionary (default is true)
    public init(string: String = "", delimiter: Character = s_delimiter, loadColumns: Bool = false) {
		
		super.init()
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
    public convenience init(name: String, delimiter: Character = s_delimiter, encoding: String.Encoding = String.Encoding.utf8, loadColumns: Bool = false) throws {
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
    public convenience init(url: URL, delimiter: Character = s_delimiter, encoding: String.Encoding = String.Encoding.utf8, loadColumns: Bool = false) throws {
        let contents = try String(contentsOf: url, encoding: encoding)
        
        self.init(string: contents, delimiter: delimiter, loadColumns: loadColumns)
    }
    
    /// Turn the CSV data into NSData using a given encoding
    open func dataUsingEncoding(_ encoding: String.Encoding) -> Data? {
        return description.data(using: encoding)
    }
	
	deinit
	{
		// remove all
		removeAll()
	}
}
