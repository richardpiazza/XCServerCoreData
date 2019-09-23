# XCServerCoreData
[![Version](https://img.shields.io/cocoapods/v/XCServerCoreData.svg?style=flat)](http://cocoadocs.org/docsets/XCServerCoreData)
[![Platform](https://img.shields.io/cocoapods/p/XCServerCoreData.svg?style=flat)](http://cocoadocs.org/docsets/XCServerCoreData)

An CoreData Storage framework for working with Xcode Server.
Depends on the XCServerAPI project for interacting with the API.

## NOTICE

This project is being deprecated, and the work is being folded into a new framework. Checkout the 'XcodeServer' framework [here](https://github.com/richardpiazza/XcodeServer)

---

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
        
        // Perform post sync actions; A save() will have been performed on the MOC.
    })
    
Other methods for the `XcodeServer` entity include:

    XCServerCoreData.ping(xcodeServer:, completion:)
    XCServerCoreData.syncVersionData(xcodeServer:, completion:)

Methods for the `Bot` entity include:

    XCServerCoreData.syncBot(bot:, completion:)
    XCServerCoreData.syncStats(bot:, completion:)
    XCServerCoreData.triggerIntegration(bot:, completion:)
    XCServerCoreData.syncIntegrations(bot:, completion:)

Methods for the `Integration` entity include:

    XCServerCoreData.syncIntegration(integration:, completion:)
    XCServerCoreData.syncCommits(forIntegration:, completion:)
    XCServerCoreData.syncIssues(forIntegration:, completion:)

