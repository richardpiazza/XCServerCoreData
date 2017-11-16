import Foundation
import XCServerAPI

extension XCSRepositoryBlueprint {
    var repositoryIds: [String] {
        var ids = [String]()
        if let keys = self.locations?.keys.sorted() {
            ids.append(contentsOf: keys)
        }
        return ids
    }
}
