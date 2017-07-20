//===----------------------------------------------------------------------===//
//
// Repository.swift
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

public class Repository: NSManagedObject {
    
    public convenience init?(managedObjectContext: NSManagedObjectContext, identifier: String) {
        self.init(managedObjectContext: managedObjectContext)
        self.identifier = identifier
    }
    
    internal func update(withRevisionBlueprint blueprint: XCServerAPI.RepositoryBlueprint, integration: Integration? = nil) {
        guard let moc = self.managedObjectContext else {
            Log.warn("\(#function) failed; MOC is nil")
            return
        }
        
        guard blueprint.repositoryIds.contains(self.identifier) else {
            return
        }
        
        if let workingCopyStates = blueprint.workingCopyStates, let state = workingCopyStates[self.identifier] {
            self.workingCopyState = state as NSNumber?
        }
        
        if let workingCopyPaths = blueprint.workingCopyPaths, let path = workingCopyPaths[self.identifier] {
            self.workingCopyPath = path
        }
        
        if let remoteRepositorys = blueprint.remoteRepositories {
            if let remoteRepository = remoteRepositorys.filter({ (repo: XCServerAPI.RemoteRepository) -> Bool in
                return repo.identifier == self.identifier
            }).first {
                self.system = remoteRepository.system
                self.url = remoteRepository.url
            }
        }
        
        guard let blueprintLocation = blueprint.locations?[self.identifier] else {
            return
        }
        
        self.branchIdentifier = blueprintLocation.branchIdentifier
        self.branchOptions = blueprintLocation.branchOptions as NSNumber?
        self.locationType = blueprintLocation.locationType
        
        guard let integration = integration else {
            return
        }
        
        guard let commitHash = blueprintLocation.locationRevision else {
            return
        }
        
        var commit: Commit?
        if let c = moc.commit(withHash: commitHash) {
            commit = c
        } else if let c = Commit(managedObjectContext: moc, identifier: commitHash, repository: self) {
            commit = c
        }
        
        if let commit = commit {
            guard moc.revisionBlueprint(withCommit: commit, andIntegration: integration) == nil else {
                return
            }
            
            let _ = RevisionBlueprint(managedObjectContext: moc, commit: commit, integration: integration)
        }
    }
    
    internal func update(withIntegrationCommits commits: [XCServerAPI.CommitDocument], integration: Integration? = nil) {
        for integrationCommit in commits {
            if let integrationCommits = integrationCommit.commits {
                for (key, value) in integrationCommits {
                    guard key == self.identifier else {
                        continue
                    }
                    
                    self.update(withCommits: value, integration: integration)
                }
            }
        }
    }
    
    internal func update(withCommits commits: [XCServerAPI.Commit], integration: Integration? = nil) {
        guard let moc = self.managedObjectContext else {
            Log.warn("\(#function) failed; MOC is nil")
            return
        }
        
        for commitsCommit in commits {
            guard let hash = commitsCommit.hash else {
                continue
            }
            
            var commit: Commit?
            if let c = moc.commit(withHash: hash) {
                commit = c
            } else if let c = Commit(managedObjectContext: moc, identifier: hash, repository: self) {
                commit = c
            }
            
            if let commit = commit {
                commit.update(withCommit: commitsCommit, integration: integration)
            }
        }
    }
}
