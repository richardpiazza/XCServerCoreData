# XCServerCoreData
[![Version](https://img.shields.io/cocoapods/v/XCServerCoreData.svg?style=flat)](http://cocoadocs.org/docsets/XCServerCoreData)
[![Platform](https://img.shields.io/cocoapods/p/XCServerCoreData.svg?style=flat)](http://cocoadocs.org/docsets/XCServerCoreData)

An API and CoreData Storage framework for working with Xcode Server.
No extensive knownledge of the Xcode Server API should be needs.
All API interaction is obfuscated.

#### XCServerCoreData.swift

Provided the main interaction with the `XCServerCoreData` framework.
Using all defaults:

    // Reference the MOC
    let moc = XCServerCoreData.sharedInstance.managedObjectContext
    
    // Create a server reference
    guard let server = XcodeServer(managedObjectContext: moc, fqdn: "test.example.com") else {
        fatalError()
    }
    
    // Retrieve the bots
    XCServerCoreData.syncBots(forXcodeServer: server, completion: { (error) in
        if let e = error {
            // Handle the error
            return
        }
        
        // Perform post sync actions; MOC was already saved.
    })

#### XCServerWebAPI.swift

Wraps an `NSURLSession` for each `XcodeServer` entity.
Two static delegates are available for handling SSL and HTTP Authentication for your server:

    XCServerWebAPI.sessionDelegate: NSURLSessionDelegate
    XCServerWebAPI.credentialDelegate: XCServerWebAPICredentialDelegate
