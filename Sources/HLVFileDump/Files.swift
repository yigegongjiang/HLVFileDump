//
//  File.swift
//  
//
//  Created by gebiwanger on 2023/12/22.
//

import Foundation

let Files = FileManager.default

public func hlvFileExistCheck(_ path: String) -> URL? {
  let fixedpath = NSString(string: path).standardizingPath
  
  guard Files.fileExists(atPath: fixedpath) else {
    return nil
  }
  
  return URL(filePath: fixedpath)
}
