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

public class Repository: SerializableManagedObject {
    
    public convenience init?(managedObjectContext: NSManagedObjectContext, identifier: String) {
        self.init(managedObjectContext: managedObjectContext)
        self.identifier = identifier
    }
    
    override public func serializedObject(forPropertyName propertyName: String, withData data: NSObject) -> NSObject? {
        switch propertyName {
        case "configurations":
            return nil
        default:
            return super.serializedObject(forPropertyName: propertyName, withData: data)
        }
    }
    
    internal func update(withRevisionBlueprint blueprint: RevisionBlueprintJSON, integration: Integration? = nil) {
        guard let moc = self.managedObjectContext else {
            Logger.warn("\(#function) failed; MOC is nil", callingClass: type(of: self))
            return
        }
        
        guard blueprint.repositoryIds.contains(self.identifier) else {
            return
        }
        
        if let workingCopyStates = blueprint.DVTSourceControlWorkspaceBlueprintWorkingCopyStatesKey, let state = workingCopyStates[self.identifier] {
            self.workingCopyState = state
        }
        
        if let workingCopyPaths = blueprint.DVTSourceControlWorkspaceBlueprintWorkingCopyPathsKey, let path = workingCopyPaths[self.identifier] {
            self.workingCopyPath = path
        }
        
        if let remoteRepositorys = blueprint.DVTSourceControlWorkspaceBlueprintRemoteRepositoriesKey {
            if let remoteRepository = remoteRepositorys.filter({ (repo: RemoteRepositoryJSON) -> Bool in
                return repo.DVTSourceControlWorkspaceBlueprintRemoteRepositoryIdentifierKey == self.identifier
            }).first {
                self.system = remoteRepository.DVTSourceControlWorkspaceBlueprintRemoteRepositorySystemKey
                self.url = remoteRepository.DVTSourceControlWorkspaceBlueprintRemoteRepositoryURLKey
            }
        }
        
        guard let blueprintLocation = blueprint.DVTSourceControlWorkspaceBlueprintLocationsKey[self.identifier] else {
            return
        }
        
        self.branchIdentifier = blueprintLocation.DVTSourceControlBranchIdentifierKey
        self.branchOptions = blueprintLocation.DVTSourceControlBranchOptionsKey as NSNumber?
        self.locationType = blueprintLocation.DVTSourceControlWorkspaceBlueprintLocationTypeKey
        
        guard let integration = integration else {
            return
        }
        
        guard let commitHash = blueprintLocation.DVTSourceControlLocationRevisionKey else {
            return
        }
        
        var commit: Commit?
        if let c = moc.commit(withHash: commitHash) {
            commit = c
            Logger.debug("Found commit with hash '\(commitHash)'", callingClass: Repository.self)
        } else if let c = Commit(managedObjectContext: moc, identifier: commitHash, repository: self) {
            commit = c
            Logger.debug("Created commit with hash '\(commitHash)'", callingClass: Repository.self)
        }
        
        if let commit = commit {
            guard moc.revisionBlueprint(withCommit: commit, andIntegration: integration) == nil else {
                return
            }
            
            let _ = RevisionBlueprint(managedObjectContext: moc, commit: commit, integration: integration)
        }
    }
    
    internal func update(withIntegrationCommits commits: [IntegrationCommitJSON]) {
        for integrationCommit in commits {
            for (key, value) in integrationCommit.commits {
                guard key == self.identifier else {
                    continue
                }
                
                self.update(withCommits: value)
            }
        }
    }
    
    internal func update(withCommits commits: [CommitJSON]) {
        guard let moc = self.managedObjectContext else {
            Logger.warn("\(#function) failed; MOC is nil", callingClass: type(of: self))
            return
        }
        
        for commitsCommit in commits {
            var commit: Commit?
            if let c = moc.commit(withHash: commitsCommit.XCSCommitHash) {
                commit = c
                Logger.debug("Found commit with hash '\(commitsCommit.XCSCommitHash)'", callingClass: Repository.self)
            } else if let c = Commit(managedObjectContext: moc, identifier: commitsCommit.XCSCommitHash, repository: self) {
                commit = c
                Logger.debug("Created commit with hash '\(commitsCommit.XCSCommitHash)'", callingClass: Repository.self)
            }
            
            if let commit = commit {
                commit.update(withCommit: commitsCommit)
            }
        }
    }
}
