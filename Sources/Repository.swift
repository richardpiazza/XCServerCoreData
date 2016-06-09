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
    
    func update(withRepository repository: RepositoryJSON) {
        self.identifier = repository.identifier
        self.branchIdentifier = repository.branchIdentifier
        self.branchOptions = repository.branchOptions
        self.locationType = repository.locationType
        self.system = repository.system
        self.url = repository.url
        self.workingCopyPath = repository.workingCopyPath
        self.workingCopyState = repository.workingCopyState
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
