//===----------------------------------------------------------------------===//
//
// Device+CoreDataProperties.swift
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

extension Device {

    @NSManaged var architecture: String?
    @NSManaged var connected: NSNumber?
    @NSManaged var deviceID: String?
    @NSManaged var deviceType: String?
    @NSManaged var enabledForDevelopment: NSNumber?
    @NSManaged var identifier: String
    @NSManaged var isServer: NSNumber?
    @NSManaged var modelCode: String?
    @NSManaged var modelName: String?
    @NSManaged var modelUTI: String?
    @NSManaged var name: String?
    @NSManaged var osVersion: String?
    @NSManaged var platformIdentifier: String?
    @NSManaged var retina: NSNumber?
    @NSManaged var simulator: NSNumber?
    @NSManaged var supported: NSNumber?
    @NSManaged var trusted: NSNumber?
    @NSManaged var activeProxiedDevice: Device?
    @NSManaged var integrations: NSSet?
    @NSManaged var inverseActiveProxiedDevice: Device?
    @NSManaged var deviceSpecifications: NSSet?

}
