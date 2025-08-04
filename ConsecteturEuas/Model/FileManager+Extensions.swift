import Foundation

extension FileManager {
    var documentsDirectory: URL {
        let paths = self.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}


