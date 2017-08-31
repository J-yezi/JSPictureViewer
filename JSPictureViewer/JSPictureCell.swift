//
//  PictureCell.swift
//  PictureBrowser
//
//  Created by jesse on 2017/6/13.
//  Copyright © 2017年 jesse. All rights reserved.
//

import UIKit
import Kingfisher

protocol JSPictureCellDelegate: class {
    /// 关闭图片浏览器
    func closeDisplay(cell: JSPictureCell)
    /// 处理滑动过程的逻辑处理
    func processOffset(_ alpha: CGFloat)
}

class JSPictureCell: UICollectionViewCell {
    
    // MARK: - Data
    
    /// 超过closePercent后振动一次
    fileprivate var isVibration: Bool = false
    fileprivate var isClose: Bool = true
    /// 拖动关闭的临界值
    fileprivate let closePercent: CGFloat = 0.1
    /// scrollView滚动的比例
    fileprivate var _scale: CGFloat = 0
    weak var delegate: JSPictureCellDelegate?
    /// scrollView的偏移
    var offset: CGPoint = .zero
    var finalImage: UIImage? {
        didSet {
            guard let image = finalImage else { return }
            pictureSize = image.size
            imageView.image = image
        }
    }
    var placeholderImage: UIImage? {
        didSet {
            /// 大图已经有的情况下，就不乣设置占位图
            guard let image = placeholderImage, finalImage == nil else { return }
            pictureSize = image.size
            imageView.image = image
        }
    }
    var indexPath: IndexPath!
    var url: String? {
        didSet {
            /// 让进度条有一点显示
            progressView.isHidden = false
            progressView.progress = 0.05
            
            imageView.kf.cancelDownloadTask()
            imageView.kf.setImage(with: URL(string: url!), placeholder: placeholderImage, options: nil, progressBlock: { [weak self] (receivedSize, totalSize) in
                self?.progressView.progress = max(CGFloat(receivedSize) / CGFloat(totalSize), 0.05)
            }) { [weak self] (image, error, _, _) in
                if let _ = error {
                    self?.progressView.showError()
                }else {
                    guard let `self` = self else { return }
                    if image != nil {
                        self.progressView.isHidden = true
                        self.finalImage = self.imageView.image
                        self.progressView.progress = 1
                    }else {
                        self.progressView.showError()
                    }
                }
            }
        }
    }
    /// 图片的size
    var pictureSize: CGSize! {
        didSet {
            let rect = adaptationRect(size: pictureSize)
            imageView.frame = rect
            scrollView.contentSize = imageView.bounds.size
        }
    }
    
    // MARK: - UI
    
    lazy var imageView: AnimatedImageView = {
        let imageView: AnimatedImageView = AnimatedImageView(frame: self.bounds)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var scrollView: UIScrollView = {
        let scrollView: UIScrollView = UIScrollView(frame: self.bounds)
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.maximumZoomScale = 2
//        if #available(iOS 11.0, *) {
//            scrollView.contentInsetAdjustmentBehavior = .never
//        }
        return scrollView
    }()
    fileprivate lazy var progressView: JSPictureProgress = {
        let progressView: JSPictureProgress = JSPictureProgress(center: CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2))
        progressView.isHidden = true
        return progressView
    }()
    fileprivate lazy var doubleTap: UITapGestureRecognizer = {
        let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(zoomPicture(gesture:)))
        doubleTap.numberOfTapsRequired = 2
        return doubleTap
    }()
    fileprivate lazy var singleTap: UITapGestureRecognizer = {
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        singleTap.require(toFail: self.doubleTap)
        return singleTap
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        scrollView.delegate = self
        uiSet()
        configSet()
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

extension JSPictureCell {
    
    fileprivate func configSet() {
        addGestureRecognizer(singleTap)
        addGestureRecognizer(doubleTap)
    }
    
    fileprivate func uiSet() {
        clipsToBounds = true
        backgroundColor = UIColor.clear
        contentView.addSubview(scrollView)
        scrollView.addSubview(imageView)
        contentView.addSubview(progressView)
    }
    
    @objc fileprivate func zoomPicture(gesture: UITapGestureRecognizer) {
        if finalImage != nil {
            let point = gesture.location(in: gesture.view!)
            if scrollView.zoomScale == scrollView.minimumZoomScale {
                let width = bounds.width / scrollView.maximumZoomScale
                let height = bounds.height / scrollView.maximumZoomScale
                scrollView.zoom(to: CGRect(x: point.x - width / 2, y: point.y - height / 2, width: width, height: height), animated: true)
                scrollView.setZoomScale(2, animated: false)
            }else {
                scrollView.setZoomScale(1.0, animated: true)
            }
        }
    }
    
    @objc fileprivate func close() {
        offset = .zero
        if let _ = url {
            progressView.isHidden = true
            imageView.kf.cancelDownloadTask()
        }
        delegate?.closeDisplay(cell: self)
    }
    
    fileprivate func setOffset(offset: CGPoint) {
        /// scrollView在停止拖动的时候会弹一下，这样做主要避免弹那一下
        if scrollView.isDragging == true || _scale < closePercent {
            self.offset = offset
        }
    }
    
    func doProgress(hidden: Bool) {
        if !hidden {
            if progressView.progress < 1 {
                progressView.isHidden = hidden
            }
        }else {
            progressView.isHidden = hidden
        }
    }
    
    func reset() {
        finalImage = nil
        placeholderImage = nil
    }
}

extension JSPictureCell: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setOffset(offset: scrollView.contentOffset)
        /// 双击的时候图片放大
        if imageView.layer.animation(forKey: "transform") != nil { return }

        /// 手动正在进行缩放
        if scrollView.isZooming || scrollView.isZoomBouncing { return }

        /// 滚动视图的内容超过屏幕，滚动视图内容的上边出现在屏幕中，或者视图内容没有超过屏幕，上滑或者下滑
        _scale = fabs(offset.y) / UIScreen.main.bounds.height
        /// 滚动视图的内容超过屏幕
        if scrollView.contentSize.height > UIScreen.main.bounds.height {
            if offset.y > 0, offset.y <= scrollView.contentSize.height - UIScreen.main.bounds.height {
                /// 滚动视图内容的两边一直在屏幕之外
                return
            }else if offset.y > scrollView.contentSize.height - UIScreen.main.bounds.height {
                /// 滚动视图内容的下边出现屏幕中
                _scale = (offset.y - scrollView.contentSize.height + UIScreen.main.bounds.height) / UIScreen.main.bounds.height
            }
        }

        /// 长图
        if scrollView.contentSize.height > UIScreen.main.bounds.height {
            if offset.y > 0 || offset.y < scrollView.contentSize.height - UIScreen.main.bounds.height {
                if placeholderImage != nil || finalImage != nil {
                    delegate?.processOffset(_scale)
                }
            }
        }else {
            if placeholderImage != nil || finalImage != nil {
                delegate?.processOffset(_scale)
            }
        }
        
        /// 一张图都没有的情况下，拖动是没有反应的
        if placeholderImage != nil || finalImage != nil {
            /// 添加振动
            if _scale > closePercent {
                if !isVibration {
                    isVibration = true
                    if #available(iOS 10.0, *) {
                        (generator as! UIImpactFeedbackGenerator).impactOccurred()
                    }
                }
            }else {
                isVibration = false
            }
            
            if !scrollView.isDragging, _scale > closePercent {
                /// 这个地方会触发多次调用
                if isClose {
                    isClose = false
                    if let _ = url {
                        progressView.isHidden = true
                        imageView.kf.cancelDownloadTask()
                    }
                    scrollView.setContentOffset(offset, animated: false)
                    delegate?.closeDisplay(cell: self)
                }
            }
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        /// 没有大图是不允许点击的
        if finalImage != nil {
            let offsetX = scrollView.bounds.width > scrollView.contentSize.width ? (scrollView.bounds.width - scrollView.contentSize.width) / 2 : 0
            let offsetY = scrollView.bounds.height > scrollView.contentSize.height ? (scrollView.bounds.height - scrollView.contentSize.height) / 2 : 0
            imageView.center = CGPoint(x: self.scrollView.contentSize.width / 2 + offsetX, y: scrollView.contentSize.height / 2 + offsetY)
        }
    }
}
