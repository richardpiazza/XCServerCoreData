//===----------------------------------------------------------------------===//
//
// Filter.swift
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

public class Filter: SerializableManagedObject {
    
    public convenience init?(managedObjectContext: NSManagedObjectContext, deviceSpecification: DeviceSpecification) {
        self.init(managedObjectContext: managedObjectContext)
        self.deviceSpecification = deviceSpecification
        
        Logger.info("Created `Filter` entity for `DeviceSpecification` '\(deviceSpecification.objectID)'", callingClass: self.dynamicType)
    }
    
    override public func serializedObject(forPropertyName propertyName: String, withData data: NSObject) -> NSObject? {
        switch propertyName {
        case "deviceSpecification":
            return nil
        default:
            return super.serializedObject(forPropertyName: propertyName, withData: data)
        }
    }
    
    func update(withFilter filter: FilterJSON) {
        guard let moc = self.managedObjectContext else {
            Logger.warn("\(#function) failed; MOC is nil", callingClass: self.dynamicType)
            return
        }
        
        self.filterType = filter.filterType
        self.architectureType = filter.architectureType
        
        if let filterPlatform = filter.platform {
            if self.platform == nil {
                self.platform = Platform(managedObjectContext: moc, filter: self)
            }
            
            if let platform = self.platform {
                platform.update(withPlatform: filterPlatform)
            }
        }
    }
}
