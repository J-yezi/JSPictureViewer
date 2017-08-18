//
//  JSPictureConfig.swift
//  PictureBrowser
//
//  Created by jesse on 2017/8/16.
//  Copyright © 2017年 jesse. All rights reserved.
//

import UIKit

public struct JSPictureConfig {
    public var url: String?
    public var image: UIImage?
    
    /// url和image是互斥的
    public init(url: String? = nil, image: UIImage? = nil) {
        self.url = url
        self.image = image
    }
    
}
