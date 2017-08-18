//
//  PictureProgress.swift
//  PictureBrowser
//
//  Created by jesse on 2017/6/13.
//  Copyright © 2017年 jesse. All rights reserved.
//

import UIKit

class JSPictureProgress: UIView {
    
    // MARK: - Data
    
    var progress: CGFloat = 0 {
        didSet {
            sectorLayer.isHidden = false
            errorLayer.isHidden = true
            sectorLayer.strokeEnd = progress
        }
    }
    
    // MARK: - UI
    
    fileprivate lazy var circleLayer: CAShapeLayer = {
        let circleLayer: CAShapeLayer = CAShapeLayer()
        circleLayer.strokeColor = UIColor.white.withAlphaComponent(0.8).cgColor
        circleLayer.fillColor = UIColor.black.withAlphaComponent(0.2).cgColor
        let path: UIBezierPath = UIBezierPath(arcCenter: CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2), radius: self.bounds.width / 2, startAngle: -CGFloat.pi / 2, endAngle: -CGFloat.pi / 2 + CGFloat.pi * 2, clockwise: true)
        path.lineWidth = 1
        circleLayer.path = path.cgPath
        return circleLayer
    }()
    fileprivate lazy var sectorLayer: CAShapeLayer = {
        let sectorLayer: CAShapeLayer = CAShapeLayer()
        let path: UIBezierPath = UIBezierPath(arcCenter: CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2), radius: (self.bounds.width / 2 - 2.5) / 2, startAngle: -CGFloat.pi / 2, endAngle: -CGFloat.pi / 2 + CGFloat.pi * 2, clockwise: true)
        sectorLayer.path = path.cgPath
        sectorLayer.lineWidth = self.bounds.width / 2 - 2.5
        sectorLayer.strokeColor = UIColor.white.cgColor
        sectorLayer.fillColor = UIColor.clear.cgColor
        return sectorLayer
    }()
    fileprivate lazy var errorLayer: CAShapeLayer = {
        let errorLayer: CAShapeLayer = CAShapeLayer()
        errorLayer.frame = self.bounds
        errorLayer.isHidden = true
        errorLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(Double.pi / 4)))
        errorLayer.fillColor = UIColor.white.withAlphaComponent(0.8).cgColor
        let width: CGFloat = 30
        let height: CGFloat = 2
        let path1: UIBezierPath = UIBezierPath(rect: CGRect(x: self.frame.width * 0.5 - height * 0.5, y: (self.frame.width - width) * 0.5, width: height, height: width))
        let path2: UIBezierPath = UIBezierPath(rect: CGRect(x: (self.frame.width - width) * 0.5, y: self.frame.width * 0.5 - height * 0.5, width: width, height: height))
        path2.append(path1)
        errorLayer.path = path2.cgPath
        return errorLayer
    }()
    
    init(center: CGPoint) {
        super.init(frame: CGRect(x: center.x - 25, y: center.y - 25, width: 50, height: 50))
        uiSet()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if isNeedLog {
            print("\(self.classForCoder.description()) - deinit")
        }
    }

}

extension JSPictureProgress {
    
    fileprivate func uiSet() {
        layer.addSublayer(circleLayer)
        layer.addSublayer(sectorLayer)
        layer.addSublayer(errorLayer)
    }
    
    func showError() {
        errorLayer.isHidden = false
        sectorLayer.isHidden = true
    }
    
}
