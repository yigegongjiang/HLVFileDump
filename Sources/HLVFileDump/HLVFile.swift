//
//  File 2.swift
//  
//
//  Created by gebiwanger on 2023/12/23.
//

import Foundation

public class HLVFile {
}

extension HLVFile {
  
  /// Check the file is text file.
  ///
  /// 对于二进制文件，没有办法通过特定的文本编码来解析它们。它们显然不是文本文件。
  /// 对于普通文本文件，它们需要通过特定的编码来读取（编码和解码应该一致，例如utf-8）。如果读取编码错误，它也不是有效文本文件。
  /// 更甚至，有些场景会对二进制文件插入特定编码的文本内容以做标记，这种场景虽然部分内容可以认为是文本，但当前文件也并不是文本文件。
  ///
  /// 实际上，对于一个文件是否是文本文件，并没有完全行之有效的方案。只能通过尝试去理解内容，这是有一定误差的。
  /// 可行的方案有：`文件名后缀匹配`、`magic number 过滤`等，虽然会有一定误差，但在比较稳定的环境下，这也是有效的。
  ///
  /// 应用上，比较稳定的方案是对文本内容全量解码，这在文本较小的时候非常行之有效。若环境中出现图片、压缩文件等，这会有极大的性能损耗。
  /// 这里提供一种思路，即对文本内容主动进行多个位置的截取解码，以较小的性能开销来对文本文件进行识别。
  ///
  /// - Returns: true：是文本文件。
  public static func isText(_ path: String, encoding: String.Encoding = .utf8) -> Bool {
    guard let pathUrl = hlvFileExistCheck(path) else { return false }
    
    guard let filehandle = try? FileHandle(forReadingFrom: pathUrl) else { return false }
    
    defer {
      _ = try? filehandle.close()
    }
    
    guard let max = try? filehandle.seekToEnd() else { return false }
    
    // 采样长度
    let cutCount: Int = 10
    
    // 字节采样
    func cutData(_ position: UInt64) throws -> Data? {
      try? filehandle.seek(toOffset: position)
      return try filehandle.read(upToCount: cutCount)
    }
    
    // 字节分析
    func parseData(_ data: Data) -> Bool {
      
      let max = data.count
      let byteL = 5
      
      guard max > byteL else { return false }
      
      for i in 0...(max - byteL) {
        for j in 1...byteL {
          if let r = String(data: data.subdata(in: i..<(i+j)), encoding: encoding) {
            if r.count > 0 {
              return true
            }
          }
        }
      }
      
      return false
    }
    
    // 采样量
    var sample = 0
    switch max {
    case 0..<100: // < 100B
      sample = 0
    case 0..<1024: // < 1k
      sample = 5
    case 1024..<1024*10: // < 10k
      sample = 10
    case 1024*10..<1024*100: // < 100k
      sample = 50
    case 1024*100..<1024*1024: // < 1M
      sample = 100
    case 1024*1024..<1024*1024*10: // < 10M
      sample = 200
    default:
      sample = 200
    }
    
    guard sample > 0 else {
      // 对于小文件，无需采样，直接全量解析
      try? filehandle.seek(toOffset: 0)
      guard let d = try? filehandle.readToEnd() else { return false }
      guard let r = String(data: d, encoding: encoding) else { return false }
      return r.count > 0
    }
    
    let samples = (0..<sample).map { _ in uint64.random(in: 0...(max - uint64(cutCount))) }

    // 对抽样点进行抽样解码
    // 当前抽样点验证失败，则整体验证失败，后面抽样不会执行
    var flag = samples.count
    for s in samples {
      do {
        guard let d = try cutData(s) else { break }
        if !parseData(d) {
          break
        }
      } catch {
        break
      }
      flag -= 1
    }
    
    return flag == 0
  }
}
