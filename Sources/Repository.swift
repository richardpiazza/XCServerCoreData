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

class Repository: SerializableManagedObject {
    
    convenience init?(managedObjectContext: NSManagedObjectContext, identifier: String) {
        self.init(managedObjectContext: managedObjectContext)
        self.identifier = identifier
    }
    
    override func serializedObject(forPropertyName propertyName: String, withData data: NSObject) -> NSObject? {
        switch propertyName {
        case "configurations":
            return nil
        default:
            return super.serializedObject(forPropertyName: propertyName, withData: data)
        }
    }
    
    func update(withRevisionBlueprint blueprint: RevisionBlueprintJSON, integration: Integration? = nil) {
        guard let moc = self.managedObjectContext else {
            Logger.warn("\(#function) failed; MOC is nil", callingClass: self.dynamicType)
            return
        }
        
        guard blueprint.repositoryIds.contains(self.identifier) else {
            return
        }
        
        // Remote Repository
        if let remoteRepositorys = blueprint.DVTSourceControlWorkspaceBlueprintRemoteRepositoriesKey {
            if let remoteRepository = remoteRepositorys.filter({ (repo: RemoteRepositoryJSON) -> Bool in
                return repo.DVTSourceControlWorkspaceBlueprintRemoteRepositoryIdentifierKey == self.identifier
            }).first {
                self.system = remoteRepository.DVTSourceControlWorkspaceBlueprintRemoteRepositorySystemKey
                self.url = remoteRepository.DVTSourceControlWorkspaceBlueprintRemoteRepositoryURLKey
            }
        }
        
        if let blueprintLocation = blueprint.DVTSourceControlWorkspaceBlueprintLocationsKey[self.identifier] {
            self.branchIdentifier = blueprintLocation.DVTSourceControlBranchIdentifierKey
            self.branchOptions = blueprintLocation.DVTSourceControlBranchOptionsKey
            self.locationType = blueprintLocation.DVTSourceControlWorkspaceBlueprintLocationTypeKey
            
            if let integration = integration, commitHash = blueprintLocation.DVTSourceControlLocationRevisionKey {
                var commit = self.commit(withCommitHash: commitHash)
                if commit == nil {
                    commit = Commit(managedObjectContext: moc, repository: self)
                }
                
                if let commit = commit, revisionBlueprints = integration.revisionBlueprints as? Set<RevisionBlueprint> {
                    let existing = revisionBlueprints.filter({ (rb: RevisionBlueprint) -> Bool in
                        return rb.commit == commit
                    }).first
                    
                    if existing == nil {
                        if let revisionBlueprint = RevisionBlueprint(managedObjectContext: moc) {
                            revisionBlueprint.commit = commit
                            revisionBlueprint.integration = integration
                            integration.revisionBlueprints = integration.revisionBlueprints?.setByAddingObject(revisionBlueprint)
                        }
                    }
                }
            }
        }
        
        if let workingCopyStates = blueprint.DVTSourceControlWorkspaceBlueprintWorkingCopyStatesKey, state = workingCopyStates[self.identifier] {
            self.workingCopyState = state
        }
        
        if let workingCopyPaths = blueprint.DVTSourceControlWorkspaceBlueprintWorkingCopyPathsKey, path = workingCopyPaths[self.identifier] {
            self.workingCopyPath = path
        }
    }
    
    func update(withIntegrationCommits commits: [IntegrationCommitJSON]) {
        for integrationCommit in commits {
            for (key, value) in integrationCommit.commits {
                guard key == self.identifier else {
                    continue
                }
                
                self.update(withCommits: value)
            }
        }
    }
    
    func update(withCommits commits: [CommitJSON]) {
        guard let moc = self.managedObjectContext else {
            Logger.warn("\(#function) failed; MOC is nil", callingClass: self.dynamicType)
            return
        }
        
        for commitsCommit in commits {
            var commit = self.commit(withCommitHash: commitsCommit.XCSCommitHash)
            if commit == nil {
                commit = Commit(managedObjectContext: moc, repository: self)
            }
            
            commit?.update(withCommit: commitsCommit)
        }
    }
    
    func commit(withCommitHash hash: String) -> Commit? {
        guard let commits = self.commits as? Set<Commit> else {
            return nil
        }
        
        let commit = commits.filter { (c: Commit) -> Bool in
            return c.commitHash == hash
        }.first
        
        return commit
    }
}
