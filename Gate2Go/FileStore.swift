import Foundation
import UIKit

enum FileStore {
    static func documentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    static func writeData(_ data: Data, fileName: String, subdirectory: String) throws -> String {
        let dir = documentsDirectory().appendingPathComponent(subdirectory, isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let url = dir.appendingPathComponent(fileName)
        try data.write(to: url, options: [.atomic])
        return url.path
    }

    static func writeJPEG(_ image: UIImage, fileName: String, subdirectory: String, quality: CGFloat = 0.9) throws -> String {
        guard let data = image.jpegData(compressionQuality: quality) else {
            throw NSError(domain: "Gate2Go.FileStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to encode JPEG"])
        }
        return try writeData(data, fileName: fileName, subdirectory: subdirectory)
    }

    static func readUIImage(path: String) -> UIImage? {
        UIImage(contentsOfFile: path)
    }
}

