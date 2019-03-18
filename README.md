# Jetway
A Swift framework for creating and calling statically-typed API endpoints

⚠️ This framework is currently in `alpha`. Expect frequent changes and additions to the public API.

## Usage

Rigorous documentation will come later. Here's a small sample from [JetwayTests.xctest](https://github.com/calda/Jetway/tree/master/JetwayTests):

```swift
enum SampleSongsAPI {

    private static let api = API(baseUrl: "https://itunes.apple.com")

    static func songs(for query: String) -> PublicEndpoint<Void, SongResponse> {
        return api.endpoint(.GET, "search?term=\(query.percentEncoded)&entity=song")
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

    static let api: API = {
        let api = API(
            baseUrl: "https://api.windowfasting.app",
            requestHeaders: ["API-Key": "..."])

        api.credentialsStore.registerCredentialsProvider({
            return try UserManager.currentSession()
        })

        return api
    }()

}

public typealias AuthenticatedEndpoint<RequestType, ResponseType>
    = Endpoint<RequestType, ResponseType, Requires<AuthenticatedSession>>


// MARK: - User Endpoints

public extension SocialAPI {
    
    public static func createNewUser() -> PublicEndpoint<User.Registration, User> {
        return api.endpoint(.POST, "/users")
    }
    
    public static func getUser(with id: User.ID) -> Endpoint<Void, User, Requires<AuthorizationToken>> {
        return api.endpoint(.GET, "/users/\(id)")
    }
    
    public static func updateProfile(for user: User) -> AuthenticatedEndpoint<User.Profile, User> {
        return api.endpoint(.PUT, "/users/\(user.id)/profile")
    }
    
    public static func updateProfilePicture(for user: User) -> AuthenticatedEndpoint<CodableImage, User> {
        return api.endpoint(.PUT, "/users/\(user.id)/profile/picture", additionalRequestConfiguring: { request in
            request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        })
    }
    
    public static func getProfilePicture(for user: User) -> PublicEndpoint<Void, CodableImage> {
        return api.endpoint(.GET, "/users/\(user.id)/profile/picture")
    }
    
    public static func registerDevice(for user: User) -> AuthenticatedEndpoint<Device, Void> {
        return api.endpoint(.POST, "/users/\(user.id)/devices")
    }
    
}

...

```
