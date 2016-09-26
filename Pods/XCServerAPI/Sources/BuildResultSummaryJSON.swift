//===----------------------------------------------------------------------===//
//
// BuildResultSummaryJSON.swift
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
import CodeQuickKit

public class BuildResultSummaryJSON: SerializableObject {
    public var errorCount: Int = 0
    public var errorChange: Int = 0
    public var warningCount: Int = 0
    public var warningChange: Int = 0
    public var testsCount: Int = 0
    public var testsChange: Int = 0
    public var testFailureCount: Int = 0
    public var testFailureChange: Int = 0
    public var analyzerWarningCount: Int = 0
    public var analyzerWarningChange: Int = 0
    public var regressedPerfTestCount: Int = 0
    public var improvedPerfTestCount: Int = 0
    public var codeCoveragePercentage: Int = 0
    public var codeCoveragePercentageDelta: Int = 0
}
