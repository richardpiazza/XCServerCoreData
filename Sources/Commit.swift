//===----------------------------------------------------------------------===//
//
// Commit.swift
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
import CoreData
import CodeQuickKit
import XCServerAPI

public class Commit: NSManagedObject {
    
    public convenience init?(managedObjectContext: NSManagedObjectContext, identifier: String, repository: Repository) {
        self.init(managedObjectContext: managedObjectContext)
        self.commitHash = identifier
        self.repository = repository
    }
    
    internal func update(withCommit commit: XCServerAPI.Commit, integration: Integration? = nil) {
        guard let moc = self.managedObjectContext else {
            Log.warn("\(#function) failed; MOC is nil")
            return
        }
        
        self.message = commit.message
        if let commitTimestamp = commit.timestamp {
            // TODO: Commit Timestamp should be a DATE!
            self.timestamp = XCServerJSONDecoder.dateFormatter.string(from: commitTimestamp)
        }
        
        if let contributor = commit.contributor {
            if self.commitContributor == nil {
                self.commitContributor = CommitContributor(managedObjectContext: moc, commit: self)
            }
            
            self.commitContributor?.update(withCommitContributor: contributor)
        }
        
        if let filePaths = commit.commitChangeFilePaths {
            for commitChange in filePaths {
                guard self.commitChanges?.contains(where: { (cc: CommitChange) -> Bool in return cc.filePath == commitChange.filePath }) == false else {
                    continue
                }
                
                if let change = CommitChange(managedObjectContext: moc, commit: self) {
                    change.update(withCommitChange: commitChange)
                }
            }
        }
        
        if let integration = integration {
            guard moc.revisionBlueprint(withCommit: self, andIntegration: integration) == nil else {
                return
            }
            
            let _ = RevisionBlueprint(managedObjectContext: moc, commit: self, integration: integration)
        }
    }
    
    public var commitTimestamp: Date? {
        guard let timestamp = self.timestamp else {
            return nil
        }
        
        return DateFormatter.xcodeServerDateFormatter.date(from: timestamp)
    }
}
