//===----------------------------------------------------------------------===//
//
// APIResponses.swift
//
// Copyright (c) 2016 Richard Piazza
// https://github.com/richardpiazza/XCServerCoreData
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
//===----------------------------------------------------------------------===//

import Foundation
import CodeQuickKit

enum DocumentType: String {
    case Version = "version"
    case Bot = "bot"
    case Integration = "integration"
    case Device = "device"
    case Commit = "commit"
}

class BotsResponse: SerializableObject {
    var count: Int = 0
    var results: [BotJSON] = [BotJSON]()
    
    override func objectClassOfCollectionType(forPropertyname propertyName: String) -> AnyClass? {
        if propertyName == "results" {
            return BotJSON.self
        }
        
        return super.objectClassOfCollectionType(forPropertyname: propertyName)
    }
}

class IntegrationsResponse : SerializableObject {
    var count: Int = 0
    var results: [IntegrationJSON] = [IntegrationJSON]()
    
    override func objectClassOfCollectionType(forPropertyname propertyName: String) -> AnyClass? {
        if propertyName == "results" {
            return IntegrationJSON.self
        }
        
        return super.objectClassOfCollectionType(forPropertyname: propertyName)
    }
}

class IntegrationCommitsResponse : SerializableObject {
    var count: Int = 0
    var results: [IntegrationCommitJSON] = [IntegrationCommitJSON]()
    
    
    override func objectClassOfCollectionType(forPropertyname propertyName: String) -> AnyClass? {
        if propertyName == "results" {
            return IntegrationCommitJSON.self
        }
        
        return super.objectClassOfCollectionType(forPropertyname: propertyName)
    }
}

class IntegrationIssuesResponse : SerializableObject {
    var errors: IntegrationIssuesJSON?
    var warnings: IntegrationIssuesJSON?
    var analyzerWarnings: IntegrationIssuesJSON?
    var testFailures: IntegrationIssuesJSON?
    var buildServiceErrors: [IssueJSON] = [IssueJSON]()
    var buildServiceWarnings: [IssueJSON] = [IssueJSON]()
}
