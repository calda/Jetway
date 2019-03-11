# Jetway
A Swift framework for creating and calling statically-typed API endpoints

⚠️ This framework is currently in `alpha`. Expect frequent changes and additions to the public API.

## Usage

Rigorous documentation will come later. Here's a small sample from [JetwayTests.xctest](https://github.com/calda/Jetway/tree/master/JetwayTests):

```swift
enum SampleSongsAPI {
    
    static func configure() {
        BaseURL.default = URL(string: "https://itunes.apple.com")!
    }
    
    static func songs(for query: String) -> PublicEndpoint<Void, SongsResponse> {
        let encodedTerm = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return .endpoint(.GET, "search?term=\(encodedTerm)&entity=song")
    }
    
}

struct SongResponse: Codable {
    let results: [Song]
}

struct Song: Codable {
    let trackName: String
    let artistName: String
}

```

```swift
// to be called once, perhaps in AppDelegate.swift:
SampleSongsAPI.configure()

// calling an Endpoint
SampleSongsAPI.songs(for: "Earth, Wind, & Fire").call().then { response in

    // SongsResponse
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

### Example API from Window.app

I'm using Jetway as the networking layer in [Window.app](https://itunes.apple.com/us/app/window-fasting-tracker/id1112765909?mt=8):

```swift
import Jetway

public enum SocialAPI {
    
    public static func configure() {
        BaseURL.default = "https://api.windowfasting.app/"
        
        RequestCredentialsStore.global.registerCredentialsProvider({
            return try UserManager.currentSession()
        })
    }
    
}

public typealias AuthenticatedEndpoint<RequestType, ResponseType>
    = Endpoint<RequestType, ResponseType, Requires<AuthenticatedSession>>


// MARK: - User Endpoints

public extension SocialAPI {
    
    public static func createNewUser() -> PublicEndpoint<User.Registration, User> {
        return .endpoint(.POST, "/users")
    }
    
    public static func getUser(with id: User.ID) -> Endpoint<Void, User, Requires<AuthorizationToken>> {
        return .endpoint(.GET, "/users/\(id)")
    }
    
    public static func updateProfile(for user: User) -> AuthenticatedEndpoint<User.Profile, User> {
        return .endpoint(.PUT, "/users/\(user.id)/profile")
    }
    
    public static func updateProfilePicture(for user: User) -> AuthenticatedEndpoint<CodableImage, User> {
        return .endpoint(.PUT, "/users/\(user.id)/profile/picture", additionalRequestConfiguring: { request in
            request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        })
    }
    
    public static func getProfilePicture(for user: User) -> PublicEndpoint<Void, CodableImage> {
        return .endpoint(.GET, "/users/\(user.id)/profile/picture")
    }
    
    public static func registerDevice(for user: User) -> AuthenticatedEndpoint<Device, Void> {
        return .endpoint(.POST, "/users/\(user.id)/devices")
    }
    
}

...

```
