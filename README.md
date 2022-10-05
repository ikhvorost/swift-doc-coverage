
[![Swift 5](https://img.shields.io/badge/Swift-5-f48041.svg?style=flat)](https://developer.apple.com/swift)
![Platforms: macOS](https://img.shields.io/badge/Platforms-iOS%20|%20macOS%20|%20tvOS%20|%20watchOS%20-blue.svg?style=flat)
[![Swift Package Manager: compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
[![Build](https://github.com/ikhvorost/swift-doc-coverage/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/ikhvorost/swift-doc-coverage/actions/workflows/swift.yml)
[![codecov](https://codecov.io/gh/ikhvorost/swift-doc-coverage/branch/main/graph/badge.svg?token=5UpPTDzotg)](https://codecov.io/gh/ikhvorost/swift-doc-coverage)

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/donate/?hosted_button_id=TSPDD3ZAAH24C)

# swift-doc-coverage

`swift-doc-coverage` generates documentation coverage statistics or warnings for Swift files and can be used from the command-line on macOS.

## Usage

The utility checks documentation for each declaration (class, structure, enumeration, protocol, type aliase, function, variable etc.) in swift files from provided path(s) and generate the coverage report. You can also provide a minimum access level (public, interval etc.) to include only needed declarations.

```terminal
$ swift-doc-coverage --help
OVERVIEW: Generates documentation coverage statistics for Swift files.

USAGE: swift-doc-coverage [<inputs> ...] [--minimum-access-level <minimum-access-level>] [--report <report>] [--output <output>]

ARGUMENTS:
  <inputs>                One or more paths to a directory containing Swift files.

OPTIONS:
  -m, --minimum-access-level <minimum-access-level>
                          The minimum access level of the symbols considered for coverage statistics: open, public, internal, fileprivate, private. (default: public)
  -r, --report <report>   Report modes: statistics, warnings, json. (default: statistics)
  -o, --output <output>   The file path for generated report.
  --version               Show the version.
  -h, --help              Show help information.
```

### Statistics report

```terminal
$ swift-doc-coverage ./Rect --report statistics --minimum-access-level internal
1) ./Rect/Rect.swift: 50% [2/4]
Undocumented:
<Rect.swift:9:5> Rect.size
<Rect.swift:12:5> Rect.center

2) ./Rect/CompactRect.swift: 0% [0/4]
Undocumented:
<CompactRect.swift:3:1> CompactRect
<CompactRect.swift:4:5> CompactRect.origin
<CompactRect.swift:5:5> CompactRect.size
<CompactRect.swift:6:5> CompactRect.center

3) ./Rect/AlternativeRect.swift: 0% [0/4]
Undocumented:
<AlternativeRect.swift:3:1> AlternativeRect
<AlternativeRect.swift:4:5> AlternativeRect.origin
<AlternativeRect.swift:5:5> AlternativeRect.size
<AlternativeRect.swift:6:5> AlternativeRect.center

Total: 16% [2/12]
```

Where: 
- \<Rect.swift:9:5\> - location in format "filename:line:column"
- Rect.size - declaration name

### JSON report

It's possible to obtain documentation coverage statistics in JSON format:

```terminal
$ swift-doc-coverage ./Rect.swift -r json -m public -o ./Rect.json 
```
Rect.json:
```json
{
  "sources" : [
    {
      "path" : "./Rect.swift",
      "totalCount" : 4,
      "undocumented" : [
        {
          "line" : 9,
          "name" : "Rect.size",
          "column" : 5
        },
        {
          "line" : 12,
          "name" : "Rect.center",
          "column" : 5
        }
      ]
    }
  ]
}
```


### XCode

You can  intergate the utility in your XCode project to generate warnings for undocumented declarations by adding a build phase script: `Your Target` > `Build Phases` > `Add a new buid phase`

```terminal
swift-doc-coverage "${SOURCE_ROOT}" --report warnings
```

After running the build command you can see next warnings in XCode:

```
⚠️ No documentation for 'logger'.
⚠️ No documentation for 'MyClass'.
⚠️ No documentation for 'MyClass.hello()'.
⚠️ No documentation for 'MyClass.init()'.
...
```

> Swift Package Manager: Package.swift doesn't support adding build phase scripts so you need to run the utility manually for your package's folder or convert the package to XCode project.

## Installation

### Manually

To install the tool run next single command (using `curl`):

```terminal
$ bash <(curl -s https://raw.githubusercontent.com/ikhvorost/swift-doc-coverage/main/install.sh)
```

OR:

```terminal
$ git clone https://github.com/ikhvorost/swift-doc-coverage.git
$ cd swift-doc-coverage
$ sudo make install
```

## License

`swift-doc-coverage` is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/donate/?hosted_button_id=TSPDD3ZAAH24C)
