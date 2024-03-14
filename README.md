[![Swift: 5.9, 5.8, 5.7](https://img.shields.io/badge/Swift-5.9%20|%205.8%20|%205.7%20-f48041.svg?style=flat)](https://developer.apple.com/swift)
![Platforms: iOS, macOS, tvOS, visionOS, watchOS](https://img.shields.io/badge/Platforms-iOS%20|%20macOS%20|%20tvOS%20|%20visionOS%20|%20watchOS%20-blue.svg?style=flat)
[![Swift Package Manager: compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
[![Build](https://github.com/ikhvorost/swift-doc-coverage/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/ikhvorost/swift-doc-coverage/actions/workflows/swift.yml)
[![codecov](https://codecov.io/gh/ikhvorost/swift-doc-coverage/branch/main/graph/badge.svg?token=5UpPTDzotg)](https://codecov.io/gh/ikhvorost/swift-doc-coverage)
[![Swift Doc Coverage](https://img.shields.io/badge/Swift%20Doc%20Coverage-100%25-f39f37?logo=google-docs&logoColor=white)](https://github.com/ikhvorost/swift-doc-coverage)

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/donate/?hosted_button_id=TSPDD3ZAAH24C)

# Swift Doc Coverage

`swift-doc-coverage` tool generates documentation coverage report for Swift files and can be used from the command-line on `macOS`.

## Usage

The utility checks code documentation comments for each declaration (`class`, `struct`, `enum`, `protocol`, `func`, `typealias` etc.) in Swift files from provided path(s) and generates the documentation coverage report, Xcode warnings of json.

```
$ swift-doc-coverage -h
OVERVIEW: Generates documentation coverage statistics for Swift files.

USAGE: swift-doc-coverage <inputs> ... [--skips-hidden-files <skips-hidden-files>] [--ignore-regex <ignore-regex>] [--minimum-access-level <minimum-access-level>] [--report <report>] [--output <output>]

ARGUMENTS:
  <inputs>                One or more paths to directories or Swift files.

OPTIONS:
  -s, --skips-hidden-files <skips-hidden-files>
                          An option to skip hidden files. (default: true)
  -i, --ignore-regex <ignore-regex>
                          Skip source code files with file paths that match the
                          given regular expression.
  -m, --minimum-access-level <minimum-access-level>
                          The minimum access level of the symbols considered
                          for coverage statistics: open, public, internal,
                          fileprivate, private. (default: public)
  -r, --report <report>   Report modes: coverage, warnings, json. (default:
                          coverage)
  -o, --output <output>   The file path for generated report.
  --version               Show the version.
  -h, --help              Show help information.
```

### Documentation coverage

To get the documentation coverage report of Swift files in your directory for `public` access level and above (`open`) you can simple run:

```
$ swift-doc-coverage ./Resources
1) /Resources/Rect/Rect.swift: 50% [1/2] (0.013s)
Undocumented:
<Rect.swift:14:3> var Rect.center

2) /Resources/Size.swift: 0% [0/1] (0.002s)
Undocumented:
<Size.swift:3:1> struct Size

3) /Resources/Point.swift: 0% [0/1] (0.002s)
Undocumented:
<Point.swift:3:1> struct Point


Total: 25% [1/4] (0.023s)
```

Where: 
- `file:///Resources/Rect/Rect.swift` - file path to a found Swift file
- `50%` - documentation coverage in percents
- `[1/2]` - documented declarations count vs all found declarations count
- `(0.013s)` - a processing time
- `<Rect.swift:14:3>` - a declaration location in format `<filename:line:column>`
- `var Rect.center` - a declaration name

You can also provide an other minimum access levels (`private`, `interval` etc.) to get documentation coverage for more declarations in your code.

### Xcode warnings

You can integrate the utility into your Xcode project to generate warnings for undocumented declarations by adding a build phase script: 

`Your Target` > `Build Phases` > `Add Run Script Phase`

```terminal
swift-doc-coverage "${SOURCE_ROOT}" --report warnings
```

After running `Product` > `Build` command you can see next warnings in Xcode:

```
⚠️ No documentation for 'var Rect.center'.
⚠️ No documentation for 'struct Size'.
⚠️ No documentation for 'struct Point'.
```

### JSON

It's possible to obtain all Swift declarations of your code in JSON format:

```
$ swift-doc-coverage ./Rect -r json
[
  {
    "url" : "file:///Rect/Rect.swift",
    "declarations" : [
      {
        "name" : "struct Rect",
        "column" : 1,
        "accessLevel" : 0,
        "keyword" : "struct",
        "comments" : [
          {
            "isDoc" : true,
            "text" : "Doc line"
          }
        ],
        "line" : 4
      },
      {
        "column" : 3,
        "line" : 5,
        "comments" : [
        ],
        "accessLevel" : 3,
        "name" : "let Rect.index",
        "keyword" : "let"
      },
      {
        "name" : "var Rect.origin",
        "line" : 8,
        "column" : 3,
        "comments" : [
          {
            "isDoc" : true,
            "text" : "Doc block"
          }
        ],
        "keyword" : "var",
        "accessLevel" : 4
      },
      {
        "accessLevel" : 2,
        "line" : 11,
        "comments" : [
          {
            "text" : "Comment line",
            "isDoc" : false
          }
        ],
        "keyword" : "var",
        "column" : 3,
        "name" : "var Rect.size"
      },
      {
        "name" : "var Rect.center",
        "column" : 3,
        "line" : 14,
        "keyword" : "var",
        "accessLevel" : 1,
        "comments" : [
          {
            "text" : "Comment block",
            "isDoc" : false
          }
        ]
      }
    ]
  }
]
```

## Installation

To install the tool just run the following commands in Terminal:

```
git clone https://github.com/ikhvorost/swift-doc-coverage.git
cd swift-doc-coverage
sudo make install
```

## License

`swift-doc-coverage` is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/donate/?hosted_button_id=TSPDD3ZAAH24C)
