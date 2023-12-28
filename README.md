# 文件类型识别

## `文本文件`识别

对于一个文件是否是`文本文件`，并没有完全行之有效的识别方案。只能通过尝试去理解内容，这是有一定误差的。  
可行的方案有：`文件名后缀匹配`、`magic number 过滤`等，虽然会有一定误差，但在比较稳定的环境下，这也是有效的。

对文本内容全量解码，这在文本较小的时候非常行之有效。若环境中出现图片、压缩文件等，这会有极大的性能损耗。

这里提供一种思路，即对文本内容主动进行多个位置的截取解码，以较小的性能开销来对文本文件进行识别。

### 命令

```
hlvdump istext xxx.md

> YES, This Is Text File.(or "NO, This Not Text File.")
```

### Code

```
import HLVFileDump

let r = HLVFile.isText(path), encoding: .utf8)
print("\(r ? "YES, This Is Text File." : "NO, This Not Text File.")")
```

## 文件 magic number 识别

通过 `magic number` 可以非常准确的识别特定的文件类型，这基于 ELF 等类似的二进制文件均具有表现一致的文件头。

### 命令

```
hlvdump MyI.zip
> type: zip, alias: jar zipx

hlvdump test.log
> type: text
```

### Code

```
import HLVFileDump

let r = HLVFileDump.default.dump(path)

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
```

## Installation

By Swift Package Manager.

```
let package = Package(
    dependencies: [
        .package(url: "https://github.com/yigegongjiang/HLVFileDump.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [ .target(dependencies: [...,"HLVFileDump"]) ]
)
```
