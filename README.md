# SIWA

SignIn With Apple Button for SwiftUI

## Install

### Swift Package Manager

Select Xcode menu File > Swift Packages > Add Package Dependency... and enter repository URL with GUI.

```
  Repository: https://github.com/mtfum/SIWA
```

## Usage

```swift
SIWA() { result in
  switch result {
  case .success(let credential):
    // do something
  case .failure(let error):
    // do something
  }
}
```

Button is `ASAuthorizationAppleIDButton` by default.
You can customize it!

Credentail in Result have idToken and rawNonce.
```swift
struct Credential {
  let idToken: String
  let rawNonce: String
}
```

## Tests

There are no tests yet. 
I'm waiting for your PR!

## Information and Contact

Developed by [@mtfum](https://github.com/mtfum).

Contact me by Twitter [@mtfum](https://twitter.com/mtfum)

## License

SIWA is licensed under the MIT License. 
