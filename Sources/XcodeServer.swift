//===----------------------------------------------------------------------===//
//
// XcodeServer.swift
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

class XcodeServer: SerializableManagedObject {
    
    func update(withBots data: [BotJSON]) {
        guard let moc = self.managedObjectContext else {
            Logger.warn("\(#function) failed; MOC is nil", callingClass: self.dynamicType)
            return
        }
        
        guard let botsSet = self.bots as? Set<Bot> else {
            return
        }
        
        var bots = botsSet
        
        var ids: [String] = bots.map({ $0.identifier })
        
        for item in data {
            if let index = ids.indexOf(item._id) {
                ids.removeAtIndex(index)
            }
            
            if let existing = self.bot(withIdentifier: item._id) {
                existing.update(withDictionary: item.dictionary)
            } else {
                if let bot = Bot(managedObjectContext: moc, server: self) {
                    bot.update(withBot: item)
                    bots.insert(bot)
                }
            }
        }
        
        for id in ids {
            if let bot = self.bot(withIdentifier: id) {
                bots.remove(bot)
            }
        }
        
        self.bots = bots
    }
    
    func bot(withIdentifier identifier: String) -> Bot? {
        guard let bots = self.bots as? Set<Bot> else {
            return nil
        }
        
        let results = bots.filter { (bot: Bot) -> Bool in return bot.identifier == identifier }
        
        guard let bot = results.first else {
            return nil
        }
        
        return bot
    }
}
