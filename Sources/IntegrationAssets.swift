//===----------------------------------------------------------------------===//
//
// IntegrationAssets.swift
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

class IntegrationAssets: SerializableManagedObject {
    convenience init?(managedObjectContext: NSManagedObjectContext, integration: Integration) {
        self.init(managedObjectContext: managedObjectContext)
        self.integration = integration
    }
    
    override func serializedObject(forPropertyName propertyName: String, withData data: NSObject) -> NSObject? {
        switch propertyName {
        case "integration":
            return nil
        default:
            return super.serializedObject(forPropertyName: propertyName, withData: data)
        }
    }
    
    func update(withIntegrationAssets assets: IntegrationAssetsJSON) {
        guard let moc = self.managedObjectContext else {
            Logger.warn("\(#function) failed; MOC is nil", callingClass: self.dynamicType)
            return
        }
        
        // Archive
        if let archiveAsset = assets.archive {
            if let archive = self.archive {
                moc.deleteObject(archive)
                self.archive = nil
            }
        
            if let asset = Asset(managedObjectContext: moc) {
                asset.inverseArchive = self
                asset.update(withAsset: archiveAsset)
                self.archive = asset
            }
        }
        
        // Build Service Log
        if let logAsset = assets.buildServiceLog {
            if let buildServiceLog = self.buildServiceLog {
                moc.deleteObject(buildServiceLog)
                self.buildServiceLog = nil
            }
            
            if let asset = Asset(managedObjectContext: moc) {
                asset.inverseBuildServiceLog = self
                asset.update(withAsset: logAsset)
                self.buildServiceLog = asset
            }
        }
        
        // Product
        if let productAsset = assets.product {
            if let product = self.product {
                moc.deleteObject(product)
                self.product = nil
            }
            
            if let asset = Asset(managedObjectContext: moc) {
                asset.inverseProduct = self
                asset.update(withAsset: productAsset)
                self.product = asset
            }
        }
        
        // Source Control Log
        if let logAsset = assets.sourceControlLog {
            if let sourceControlLog = self.sourceControlLog {
                moc.deleteObject(sourceControlLog)
                self.sourceControlLog = nil
            }
            
            if let asset = Asset(managedObjectContext: moc) {
                asset.inverseSourceControlLog = self
                asset.update(withAsset: logAsset)
                self.sourceControlLog = asset
            }
        }
        
        // Xcode Build Log
        if let logAsset = assets.xcodebuildLog {
            if let xcodebuildLog = self.xcodebuildLog {
                moc.deleteObject(xcodebuildLog)
                self.xcodebuildLog = nil
            }
            
            if let asset = Asset(managedObjectContext: moc) {
                asset.inverseXcodebuildLog = self
                asset.update(withAsset: logAsset)
                self.xcodebuildLog = asset
            }
        }
        
        // Xcode Build Output
        if let outputAsset = assets.xcodebuildOutput {
            if let xcodebuildOutput = self.xcodebuildOutput {
                moc.deleteObject(xcodebuildOutput)
                self.xcodebuildOutput = nil
            }
            
            if let asset = Asset(managedObjectContext: moc) {
                asset.inverseXcodebuildOutput = self
                asset.update(withAsset: outputAsset)
                self.xcodebuildOutput = asset
            }
        }
        
        // Trigger Assets
        if let triggerAssets = assets.triggerAssets {
            if let set = self.triggerAssets as? Set<Asset> {
                for asset in set {
                    moc.deleteObject(asset)
                }
            }
            
            self.triggerAssets = NSSet()
            
            for triggerAsset in triggerAssets {
                if let asset = Asset(managedObjectContext: moc) {
                    asset.inverseTriggerAssets = self
                    asset.update(withAsset: triggerAsset)
                    self.triggerAssets = self.triggerAssets?.setByAddingObject(asset)
                }
            }
        }
        
    }
}
