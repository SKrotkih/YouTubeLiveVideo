# YouTubeLiveVideo

This is an sample application of using YouTube Live Streaming API (v.3) on Swift 2.2. 

## Install

First of all you need to have a YouTube account. There need to accept Live Streaming.

Then, in your Google account need to add a new application with two thing. They are API key and OAuth 2.0 client IDs on the API Manager.
Add YouTube Data API in the API Library.  
Just one note. When you will create an API key, don't point the iOS apps in the radio box. Don't worry about yellow warning Key restriction. Take the API key and Client ID. They will use in your Xcode project.

Download or clone repo.

As you can see I made pod install for you. It is because I had some problems with update for SwiftyJSON for example. There is now just for Swift above 2.2. So I decided to commit all frameworks for you to have quick start. After update all frameworks (if you want) you can restore framework SwiftyJSON from the source YouTubeLiveVideo repo. Keep it mind if you will have problem with frameworks, the project builds and works for me. 


Then replace my (wrong) API key and Client Id on yours in the YouTubeLiveStreamingRequest.swift.
Replace bundle identifier. Edit plist.info in URLs types. Change bundle id in URL Shemes.

Hope my work will help you to understand how works YouTube Live Streaming.
I used this approach in my project.

