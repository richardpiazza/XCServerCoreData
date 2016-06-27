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

public class Commit: SerializableManagedObject {
    
    public convenience init?(managedObjectContext: NSManagedObjectContext, identifier: String, repository: Repository) {
        self.init(managedObjectContext: managedObjectContext)
        self.commitHash = identifier
        self.repository = repository
        
        Logger.verbose("Created entity `Commit` with identifier '\(identifier)'", callingClass: self.dynamicType)
    }
    
    override public func serializedObject(forPropertyName propertyName: String, withData data: NSObject) -> NSObject? {
        switch propertyName {
        case "repository", "revisionBlueprints":
            return nil
        default:
            return super.serializedObject(forPropertyName: propertyName, withData: data)
        }
    }
    
    public func update(withCommit commit: CommitJSON) {
        guard let moc = self.managedObjectContext else {
            Logger.warn("\(#function) failed; MOC is nil", callingClass: self.dynamicType)
            return
        }
        
        self.message = commit.XCSCommitMessage
        if let commitTimestamp = commit.XCSCommitTimestamp {
            self.timestamp = commitTimestamp
        }
        
        if let contributor = commit.XCSCommitContributor {
            if self.commitContributor == nil {
                self.commitContributor = CommitContributor(managedObjectContext: moc, commit: self)
            }
            
            self.commitContributor?.update(withCommitContributor: contributor)
        }
        
        if let commitChanges = self.commitChanges {
            for commitChange in commitChanges {
                commitChange.commit = nil
                moc.deleteObject(commitChange)
            }
        }
        
        for commitChange in commit.XCSCommitCommitChangeFilePaths {
            if let change = CommitChange(managedObjectContext: moc, commit: self) {
                change.update(withCommitChange: commitChange)
            }
        }
    }
}
