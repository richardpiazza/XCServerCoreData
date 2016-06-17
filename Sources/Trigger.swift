//===----------------------------------------------------------------------===//
//
// Trigger.swift
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

class Trigger: SerializableManagedObject {
    
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
    
    func update(withTrigger trigger: TriggerJSON) {
        guard let moc = self.managedObjectContext else {
            Logger.warn("\(#function) failed; MOC is nil", callingClass: self.dynamicType)
            return
        }
        
        self.name = trigger.name
        self.type = trigger.type
        self.phase = trigger.phase
        self.scriptBody = trigger.scriptBody
        
        if let triggerConditions = trigger.conditions {
            if self.conditions == nil {
                self.conditions = Conditions(managedObjectContext: moc, trigger: self)
            }
            
            if let conditions = self.conditions {
                conditions.update(withConditions: triggerConditions)
            }
        }
        
        if let triggerEmail = trigger.emailConfiguration {
            if self.emailConfiguration == nil {
                self.emailConfiguration = EmailConfiguration(managedObjectContext: moc, trigger: self)
            }
            
            if let emailConfiguration = self.emailConfiguration {
                emailConfiguration.update(withEmailConfiguration: triggerEmail)
            }
        }
    }
}
