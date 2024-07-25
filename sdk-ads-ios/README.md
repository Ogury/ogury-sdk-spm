# OguryAds

![Version](https://img.shields.io/badge/Version-3.6.0-blue.svg?style=flat)

![iOS](https://img.shields.io/badge/iOS-10+-lightgrey.svg?style=flat)
![iPadOS](https://img.shields.io/badge/iPadOS-10+-lightgrey.svg?style=flat)

`OguryAds` is the main framework of **Ogury**, responsible for delivering Ads to the end user.

## Summary

- [Installation](#installation)
  - [CocoaPods](#cocoapods)
- [Contributing](#contributing)
- [License](#license)

## Installation

### Cocoapods

To integrate `OguryAds` into your project, add the following line in your `Podfile`:

```ruby
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'OguryAds'
end
```

Then run the following command:

`$ pod install`

If needed, you might want to ensure that you are fetching the last version available by running:

`$ pod update`

## Contributing

Check [CONTRIBUTING](https://github.com/Ogury/sdk-ads-ios/blob/master/CONTRIBUTING.md) for more details on how you can contribute to the project.

## License

See [LICENSE](https://github.com/Ogury/sdk-ads-ios/blob/master/LICENSE) for more details.
