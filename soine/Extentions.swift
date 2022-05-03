//
//  Extentions.swift
//  soine
//
//  Created by 倉知諒 on 2022/04/23.
//

import UIKit
//画像の向きを制御
extension UIImage{
    func reSizeImage(size: CGSize) -> UIImage?{

        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()

        let originalWidth = image.size.width
        let originalHeight = image.size.height

        let resizeSize = CGSize(width: originalWidth, height: originalHeight)
        UIGraphicsBeginImageContext(resizeSize)

        image.draw(in: CGRect(x: 0, y: 0, width: originalWidth, height: originalHeight))

        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizeImage
        }
}

extension NSFileCoordinator {

    func coordinate(readingItemAt url: URL, options: NSFileCoordinator.ReadingOptions = []) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            var error: NSError?
            NSFileCoordinator().coordinate(readingItemAt: url, options: options, error: &error) { url in
                continuation.resume(returning: url)
            }
            if let error = error { continuation.resume(throwing: error) } // This works because the closure is not invoked in case of an error
        }
    }
    
    func coordinate(writingItemAt url: URL, options: NSFileCoordinator.WritingOptions = []) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            var error: NSError?
            NSFileCoordinator().coordinate(writingItemAt: url, options: options, error: &error) { url in
                continuation.resume(returning: url)
            }
            if let error = error { continuation.resume(throwing: error) } // This works because the closure is not invoked in case of an error
        }
    }
}
