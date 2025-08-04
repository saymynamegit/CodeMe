import Foundation

import UIKit
import SwiftUI


// MARK: . File-Based Image Storage Manager
class ImageFileManager {
    static let shared = ImageFileManager()
    
    private let imagesDirectory: URL
    private let fileManager = FileManager.default
    
    private init() {
        imagesDirectory = fileManager.documentsDirectory.appendingPathComponent("images")
        createImageDirectoryIfNeeded()
    }
    
    private func createImageDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: imagesDirectory.path) {
            try? fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Image Types Enum
    enum ImageType: String, CaseIterable {
        case main = ""
        case original = "_original"
        case background = "_background"
        case removedBg = "_removed_bg"
        case imageForPrewiew = "_image_for_preview"
    }
    
    func saveImage(_ image: UIImage, with uuid: UUID?, type: ImageType = .main, asJPEG: Bool = false, quality: CGFloat = 0.8) -> Bool {
        guard let uuid = uuid else {
            print("Cannot save image: UUID is nil")
            return false
        }

        let ext = asJPEG ? "jpg" : "png"
        let filename = "\(uuid.uuidString)\(type.rawValue).\(ext)"
        let fileURL = imagesDirectory.appendingPathComponent(filename)

        let imageData: Data?
        if asJPEG {
            imageData = image.jpegData(compressionQuality: quality)
        } else {
            imageData = image.pngData()
        }

        guard let data = imageData else { return false }

        do {
            try data.write(to: fileURL)
            return true
        } catch {
            print("Failed to save image: \(error)")
            return false
        }
    }
    
    func loadImage(with uuid: UUID?, type: ImageType = .main, asJPEG: Bool = false) -> UIImage? {
            guard let uuid = uuid else { return nil }
            
            let ext = asJPEG ? "jpg" : "png"
            let filename = "\(uuid.uuidString)\(type.rawValue).\(ext)"
            let fileURL = imagesDirectory.appendingPathComponent(filename)
            
            guard fileManager.fileExists(atPath: fileURL.path),
                  let data = try? Data(contentsOf: fileURL) else { return nil }
            
            return UIImage(data: data)
        }
    
    func deleteImage(with uuid: UUID?, type: ImageType? = nil, asJPEG: Bool = false) {
            guard let uuid = uuid else { return }
            
            if let specificType = type {
                let ext = asJPEG ? "jpg" : "png"
                let filename = "\(uuid.uuidString)\(specificType.rawValue).\(ext)"
                let fileURL = imagesDirectory.appendingPathComponent(filename)
                try? fileManager.removeItem(at: fileURL)
            } else {
                // Delete all image types for this UUID (both PNG and JPEG versions)
                ImageType.allCases.forEach { imageType in
                    // Delete PNG version
                    let pngFilename = "\(uuid.uuidString)\(imageType.rawValue).png"
                    let pngFileURL = imagesDirectory.appendingPathComponent(pngFilename)
                    try? fileManager.removeItem(at: pngFileURL)
                    
                    // Delete JPEG version
                    let jpgFilename = "\(uuid.uuidString)\(imageType.rawValue).jpg"
                    let jpgFileURL = imagesDirectory.appendingPathComponent(jpgFilename)
                    try? fileManager.removeItem(at: jpgFileURL)
                }
            }
        }
    
    private func compressImage(_ image: UIImage) -> Data? {
        // Limit maximum image size
        let maxSize: CGFloat = 2048
        let resizedImage = image.size.width > maxSize || image.size.height > maxSize
            ? image.resizedProportionally(toFit: CGSize(width: maxSize, height: maxSize))
            : image
        
        // Compress with quality
        return resizedImage.jpegData(compressionQuality: 0.8)
    }
    
    func deleteAllImages() -> Bool {
            do {
                let contents = try fileManager.contentsOfDirectory(at: imagesDirectory, includingPropertiesForKeys: nil)
                
                for fileURL in contents {
                    try fileManager.removeItem(at: fileURL)
                }
                
                print("Successfully deleted all images from storage")
                return true
            } catch {
                print("Failed to delete all images: \(error)")
                return false
            }
        }
}

extension ImageFileManager {
    func getLinkToImage(with uuid: UUID?, type: ImageType = .main, asJPEG: Bool = false) -> URL? {
        guard let uuid = uuid else { return nil }
        let ext = asJPEG ? "jpg" : "png"
        let filename = "\(uuid.uuidString)\(type.rawValue).\(ext)"
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        return fileManager.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
}

extension UIImage {
    func resizedProportionally(toFit targetSize: CGSize) -> UIImage {
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)

        let newSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
