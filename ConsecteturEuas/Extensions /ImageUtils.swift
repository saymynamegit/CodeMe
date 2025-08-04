
import UIKit
import ImageIO

func compressedImage(from image: UIImage, maxSize: CGSize = CGSize(width: 500, height: 500)) -> UIImage? {
    guard let data = image.pngData() else { return nil }
    return downsample(imageData: data, to: maxSize)
}

func downsample(imageData: Data, to size: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
    let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
    guard let source = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else { return nil }

    let maxDimensionInPixels = max(size.width, size.height) * scale

    let options = [
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceShouldCacheImmediately: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
    ] as CFDictionary

    guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else { return nil }

    return UIImage(cgImage: cgImage)
}
