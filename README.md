# LinkPreviews

A simple SwiftUI-friendly wrapper around the [Link Presentation](https://developer.apple.com/documentation/linkpresentation/) framework by Apple. 

## Usage
```swift
import LinkPreviews
LinkPreview(URL("https://www.google.com")!)

LinkPreview(
    URL("https://www.google.com")!,
    onFetchError: { error in
        print(error)
    },
    placeholder: {
        Text("Fetching preview...")
    },
    fallback: { url in
        Text("\(url)")
    }
)
```

## Roadmap
This package has not yet been validated on tvOS, visionOS, macCatalyst. Please create an Issue on GitHub if you find a problem. 

### Swift 6 Concurrency
A full concurrency audit of this package has not yet been completed. Currently this package uses `@preconcurrency import LinkPresentation`.  

## Installation
This package is in beta and is not yet fully released. To use the beta use the `beta` branch on git. 
