# YouTubeLiveVideo

This is a sample of using YouTube Live Streaming API (v.3) in Swift 2.2. 

## Requirements

- Xcode 7.3.1
- Swift 2.2

## Install

First of all accept Live Streaming in your YouTube account.

Add new application in your Google account with two thing in the API Manager: API key and OAuth 2.0 client ID.

Add YouTube Data API in the API Library.  

Just one note. When you will create an API key, don't point the iOS apps in the radio box. Don't worry about yellow warning Key restriction. Take the API key and Client ID. They will be used in your Xcode project.

Download or clone the repository.

As you can see I made pod install for you. It is because I had some problems with updating some frameworks (for SwiftyJSON for example). There is now just for Swift above 2.2. So I decided to commit all frameworks for you for having a quick start. After update all frameworks (if you want) you can restore framework SwiftyJSON from the source YouTubeLiveVideo repo.

- replace API key and Client Id in YouTubeLiveStreamingRequest.swift
- replace bundle identifier 
- edit plist.info for the URLs types. Change bundle id for URL Shemes

## Libraries Used

- lf (Camera and Microphone streaming library via RTMP, HLS for iOS, macOS lf.framework https://github.com/shogo4405/lf.swift)
- Alamofire
- AeroGear
- OAuthSwift
- SwiftyJSON
- Moya

Here is a video how it works: https://youtu.be/HwYbvUU2fJo

25-10-2016
