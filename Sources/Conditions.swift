//===----------------------------------------------------------------------===//
//
// Conditions.swift
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

public class Conditions: NSManagedObject {
    
    public convenience init?(managedObjectContext: NSManagedObjectContext, trigger: Trigger) {
        self.init(managedObjectContext: managedObjectContext)
        self.trigger = trigger
    }
    
    internal func update(withConditions conditions: XCServerAPI.Conditions) {
        self.status = conditions.status as NSNumber?
        self.onWarnings = conditions.onWarnings as NSNumber?
        self.onBuildErrors = conditions.onBuildErrors as NSNumber?
        // TODO: Verify?
//        self.onInternalErrors = conditions.onInternalErrors as NSNumber?
        self.onAnalyzerWarnings = conditions.onAnalyzerWarnings as NSNumber?
        self.onFailingTests = conditions.onFailingTests as NSNumber?
        self.onSucess = conditions.onSuccess as NSNumber?
    }
}
