# YouTubeLiveVideo

This is an sample application of using YouTube Live Streaming API (v.3) in Swift 2.2. 

## Install

First of all you need to have a YouTube account. There need to accept Live Streaming possibility.

Then, in your Google account you need to add a new application with two thing. There are API key and OAuth 2.0 client IDs in the API Manager.
Add YouTube Data API in the API Library.  
Just one note. When you will create an API key, don't point the iOS apps in the radio box. Don't worry about yellow warning Key restriction. Take the API key and Client ID. They will be used in your Xcode project.

Download or clone the repository.

As you can see I made pod install for you. It is because I had some problems with updating some frameworks (for SwiftyJSON for example). There is now just for Swift above 2.2. So I decided to commit all frameworks for you for having a quick start. After update all frameworks (if you want) you can restore framework SwiftyJSON from the source YouTubeLiveVideo repo. Keep it mind if you will have problem with frameworks, the project builds and works for me. 


Then replace my (wrong now) API key and Client Id on yours in the YouTubeLiveStreamingRequest class.
Replace the bundle identifier. Then edit plist.info for the URLs types. Change bundle id for URL Shemes.

Were used follow frameworks:
lf (Camera and Microphone streaming library via RTMP, HLS for iOS, macOS lf.framework https://github.com/shogo4405/lf.swift),
Alamofire,
AeroGear,
OAuthSwift,
SwiftyJSON,
Moya

Look the movie how it works: https://youtu.be/HwYbvUU2fJo

25-10-2016
