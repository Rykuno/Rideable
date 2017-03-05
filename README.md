# ios-should-i-ride
The petrol head inspired app you never asked for!


## Testing
1. Create a free [Wunderground] account and generate your api key.
2. Create an `IgnoreConstants` class in which contains a struct to hold your private key, as such.

```swift
import Foundation

struct IgnoreConstants{
    static let apiKey = "your_api_key"
}
```

[Wunderground]: <https://www.wunderground.com/>
