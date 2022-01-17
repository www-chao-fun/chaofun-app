//
//  ImageCompressExtension.swift
//  Runner
//
//  Created by Yue Zhang on 2021/1/10.
//

import Foundation

import UIKit

extension Image {
    // MARK: - UIImage+Resize
    func compressImageTo(image: UIImage expectedSizeInMb:Int) -> Data? {
        let sizeInBytes = expectedSizeInMb * 1024 * 1024
        var needCompress:Bool = true
        var imgData:Data?
        var compressingValue:CGFloat = 1.0
        while (needCompress && compressingValue > 0.0) {
        if let data:Data = UIImageJPEGRepresentation(UIImage, compressingValue) {
            if data.count < sizeInBytes {
                needCompress = false
                imgData = data
            } else {
                compressingValue -= 0.1
            }
        }
            
            return data;
    }

    if let data = imgData {
        if (data.count < sizeInBytes) {
            return UIImage(data: data)
        }
    }
        return nil
    }
}
