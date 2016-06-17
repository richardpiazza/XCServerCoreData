//===----------------------------------------------------------------------===//
//
// DeviceSpecification.swift
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

class DeviceSpecification: SerializableManagedObject {
    convenience init?(managedObjectContext: NSManagedObjectContext, configuration: Configuration) {
        self.init(managedObjectContext: managedObjectContext)
        self.configuration = configuration
    }
    
    override func serializedObject(forPropertyName propertyName: String, withData data: NSObject) -> NSObject? {
        switch propertyName {
        case "configuration":
            return nil
        default:
            return super.serializedObject(forPropertyName: propertyName, withData: data)
        }
    }
    
    func update(withDeviceSpecification specification: DeviceSpecificationJSON) {
        guard let moc = self.managedObjectContext else {
            Logger.warn("\(#function) failed; MOC is nil", callingClass: self.dynamicType)
            return
        }
        
        if let specificationFilters = specification.filters {
            if let filters = self.filters as? Set<Filter> {
                for filter in filters {
                    filter.deviceSpecification = nil
                    moc.deleteObject(filter)
                }
            }
            
            for specificationFilter in specificationFilters {
                if let filter = Filter(managedObjectContext: moc, deviceSpecification: self) {
                    filter.update(withFilter: specificationFilter)
                }
            }
        }
        
        if let specificationDeviceIdentifiers = specification.deviceIdentifers {
            if let devices = self.devices as? Set<Device> {
                for device in devices {
                    device.deviceSpecifications = device.deviceSpecifications?.setByRemovingObject(device)
                }
            }
            
            for specificationDeviceIdentifier in specificationDeviceIdentifiers {
                var device = moc.device(withIdentifier: specificationDeviceIdentifier)
                if device == nil {
                    device = Device(managedObjectContext: moc)
                    device?.identifier = specificationDeviceIdentifier
                }
                
                if let d = device {
                    d.deviceSpecifications = d.deviceSpecifications?.setByAddingObject(d)
                }
            }
        }
    }
}
