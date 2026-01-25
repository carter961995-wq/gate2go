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
        guard let resolvedPath = resolvePath(path) else { return nil }
        if FileManager.default.fileExists(atPath: resolvedPath) {
            return UIImage(contentsOfFile: resolvedPath)
        }

        let fallback = documentsDirectory()
            .appendingPathComponent(URL(fileURLWithPath: resolvedPath).lastPathComponent)
            .path
        guard FileManager.default.fileExists(atPath: fallback) else { return nil }
        return UIImage(contentsOfFile: fallback)
    }

    private static func resolvePath(_ path: String) -> String? {
        let trimmed = path.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if trimmed.hasPrefix("file://") {
            if let url = URL(string: trimmed) {
                return url.path
            }
            return trimmed.replacingOccurrences(of: "file://", with: "")
        }
        return trimmed
    }
}

