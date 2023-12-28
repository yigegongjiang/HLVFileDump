// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import HLVFileDump

@main
struct Command: ParsableCommand {
  static var configuration = CommandConfiguration(
    abstract: "Identify the file type. Is it JPG, ELF or else?",
    version: "1.0.0",
    subcommands: [File.self, Istext.self],
    defaultSubcommand: File.self
  )
  
  mutating func run() throws {
  }
}

extension Command {
  struct File: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Identify the file type." )
    
    @Argument(help: "the files path.", transform: { URL(filePath: NSString(string: $0).standardizingPath) })
    var path: URL
    
    mutating func run() throws {
      let r = HLVFileMagic.default.dump(path.path(percentEncoded: false))
      
      switch r {
      case let .magic(name, alias, _):
        if let alias {
          print("type: \(name), alias: \(alias.joined(separator: " "))")
        } else {
          print("type: \(name)")
        }
      case .error(let msg):
        print(msg)
      case .unknow:
        print("type: unknow")
      }
    }
  }
  
  struct Istext: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "The file is text file by utf8." )
    
    @Argument(help: "the files path.", transform: { URL(filePath: NSString(string: $0).standardizingPath) })
    var path: URL
    
    mutating func run() throws {
      let r = HLVFile.isText(path.path(percentEncoded: false), encoding: .utf8)
      print("\(r ? "YES, This Is Text File." : "NO, This Not Text File.")")
    }
  }
}
