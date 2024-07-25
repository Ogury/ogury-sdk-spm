# OguryCore

![Version](https://img.shields.io/badge/Version-1.4.0-blue.svg?style=for-the-badge)
![iOS](https://img.shields.io/badge/iOS-10+-lightgrey.svg?style=for-the-badge)
![iPadOS](https://img.shields.io/badge/iPadOS-10+-lightgrey.svg?style=for-the-badge)

`OguryCore` is a static library that contains all common elements between **Ogury** frameworks.

## Summary

- [Installation](#installation)
- [CocoaPods](#cocoapods)
- [Contributing](#contributing)
- [License](#license)

## Installation

### Cocoapods

To integrate `OguryCore` into your project, add the following line in your `Podfile`:

```ruby
source 'https://github.com/https://github.com/Ogury/ogury-cocoapods-repository.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'OguryCore'
end
```

Then run the following command:

`$ pod install`

If needed, you might want to ensure that you are fetching the last version available by running:

`$ pod update`

## Contributing

Check [CONTRIBUTING](https://github.com/Ogury/sdk-core-ios/blob/master/CONTRIBUTING.md) for more details on how you can contribute to the project.

## License

See [LICENSE](https://github.com/Ogury/sdk-core-ios/blob/master/LICENSE) for more details.
