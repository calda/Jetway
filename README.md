# Jetway
A Swift framework for creating and calling statically-typed API endpoints

I'm currently using this as my networking layer in an upcoming update to [Window.app](https://itunes.apple.com/us/app/window-fasting-tracker/id1112765909?mt=8). 

## Usage

Rigorous documentation will come later. Here's a small sample from [JetwayTests.xctest](https://github.com/calda/Jetway/tree/master/JetwayTests):

```swift
struct SongResponse: Codable {
    let results: [Song]
}

struct Song: Codable {
    let trackName: String
    let artistName: String
}
```

```swift
// MARK: - SampleSongsAPI

enum SampleSongsAPI {
    
    static func configure() {
        BaseURL.default = URL(string: "https://itunes.apple.com")!
    }
    
    static func songs(for query: String) -> PublicEndpoint<Void, SongResponse> {
        let encodedTerm = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return .endpoint(.GET, "search?term=\(encodedTerm)&entity=song")
    }
    
}
```

```swift
// to be called once, perhaps in AppDelegate.swift:
SampleSongsAPI.configure()

// calling an Endpoint
SampleSongsAPI.songs(for: "Earth, Wind, & Fire").call().then { response in

    // SongResponse
    //   ▿ results : 50 elements
    //     ▿ 0 : Song
    //     - trackName : "September"
    //     - artistName : "Earth, Wind & Fire"
    //     ▿ 1 : Song
    //     - trackName : "Let's Groove"
    //     - artistName : "Earth, Wind & Fire"
    //     ▿ 2 : Song
    //     - trackName : "Boogie Wonderland"
    //     - artistName : "Earth, Wind & Fire"
    //     ...
    
}.catch { error in
    someErrorHandler(error)
}
```
