//
//  PictureBrowser.swift
//  PictureBrowser
//
//  Created by jesse on 2017/6/13.
//  Copyright © 2017年 jesse. All rights reserved.
//

import UIKit

public enum JSPictureSource {
    case url
    case image
}

var generator: Any!

/// 计算图片的size适配了屏幕后的rect
func adaptationRect(size: CGSize) -> CGRect {
    var rect: CGRect = .zero
    let height = UIScreen.main.bounds.width / size.width * size.height
    rect.size = CGSize(width: UIScreen.main.bounds.width, height: height)
    var origin = CGPoint.zero
    if rect.height < UIScreen.main.bounds.height {
        origin.y = (UIScreen.main.bounds.height - rect.height) / 2
    }
    rect.origin = origin
    return rect
}

public protocol JSPictureViewerDelegate: class {
    /// 设置最初始状态的图片，可以自己提供小图
    func placeholderImage(_ index: Int) -> UIImage?
    /// 点击时候图片的位置或者退出浏览器后图片的位置
    func animationRect(index: Int) -> CGRect?
    /// 点击时候图片的size
    func animationSize(index: Int) -> CGSize?
    /// 浏览器切换的时候触发，并且如果出现切换的item并没有显示，这个时候可以在这个方法控制contentOffset的变化
    func changeViewerImage(old: Int, new: Int)
    /// 图片浏览器即将推出，进入或退出动画执行之前
    func viewerWillAnimation(index: Int, isAppear: Bool)
    /// 图片浏览器完全进入或退出，当下载好了大图的时候，这个大图是带回去了
    func viewerDidAnimation(index: Int, isAppear: Bool, image: UIImage?)
}

/// 因为现在默认是实现了这些方法都表明这些方法是可选的
public extension JSPictureViewerDelegate {
    func animationRect(index: Int) -> CGRect? { return nil }
    func animationSize(index: Int) -> CGSize? { return nil }
    func placeholderImage(_ index: Int) -> UIImage? { return nil }
    func changeViewerImage(old: Int, new: Int) {}
    func viewerWillAnimation(index: Int, isAppear: Bool) {}
    func viewerDidAnimation(index: Int, isAppear: Bool, image: UIImage?) {}
}

public class JSPictureViewer: UIView {
    
    // MARK: - Data
    
    /// 动画执行时间
    public let duration: TimeInterval = 0.3
    fileprivate let identifier = "JSPictureViewerIdentifier"
    fileprivate weak var delegate: JSPictureViewerDelegate?
    fileprivate var dataSource: [JSPictureConfig]!
    fileprivate var source: JSPictureSource = .url
    /// 点击进入浏览器这个动画过程会进行大图的加载，但是不会显示progress
    fileprivate var isFirst: Bool = true
    /// 当前页
    fileprivate var currentPage: Int = -1 {
        didSet {
            guard currentPage != oldValue else { return }
            /// 切换图片的隐藏状态
            delegate?.changeViewerImage(old: oldValue, new: currentPage)
        }
    }
    /// 总页数
    fileprivate var totalPage: Int = 0
    /// cell之间的间距
    fileprivate let space: CGFloat = 10
    /// 图片浏览器是否已经在关闭
    fileprivate var isClose: Bool = false
    
    // MARK: - UI
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = AnimatedCollectionViewLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = UIScreen.main.bounds.size
        layout.sectionInset = UIEdgeInsets(top: 0, left: self.space / 2, bottom: 0, right: self.space / 2)
        layout.minimumLineSpacing = self.space
        let collectionView: UICollectionView = UICollectionView(frame: CGRect(x: -self.space / 2, y: 0, width: self.bounds.width + self.space, height: self.bounds.height), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = UIColor.clear
        collectionView.alwaysBounceHorizontal = true
        collectionView.setContentOffset(CGPoint(x: CGFloat(self.currentPage) * collectionView.frame.width, y: 0), animated: false)
        collectionView.register(JSPictureCell.self, forCellWithReuseIdentifier: self.identifier)
//        if #available(iOS 11.0, *) {
//            collectionView.contentInsetAdjustmentBehavior = .never
//        }
        return collectionView
    }()
    
    // MARK: - LifeCycle
    
    /// source限定于string或者image的数组
    public init(index: Int, source: JSPictureSource, data: [JSPictureConfig], delegate: JSPictureViewerDelegate) {
        self.totalPage = data.count
        super.init(frame: UIScreen.main.bounds)
        self.source = source
        self.dataSource = data
        self.delegate = delegate
        self.currentPage = index
        self.uiSet()
        
        if #available(iOS 10.0, *) {
            generator = UIImpactFeedbackGenerator(style: .light)
            (generator as! UIImpactFeedbackGenerator).prepare()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension JSPictureViewer {
    
    fileprivate func uiSet() {
        backgroundColor = UIColor.clear
        addSubview(collectionView)
        collectionView.layoutIfNeeded()
    }
    
    /// 图片浏览器显示动画，editBlock是对动画过程中的imageView进行处理
    @discardableResult
    public func display(_ superview: UIView) -> Self {
        guard let cell = collectionView.cellForItem(at: IndexPath(row: currentPage, section: 0)) as? JSPictureCell else { return self }
        superview.addSubview(self)
        
        /// 即将进入浏览器的回调
        delegate?.viewerWillAnimation(index: currentPage, isAppear: true)
        
        switch source {
        case .image:
            cell.finalImage = dataSource[currentPage].image
            animation(cell: cell, image: dataSource[currentPage].image!)
        case .url:
            if let image = delegate!.placeholderImage(currentPage) {
                cell.placeholderImage = image
                animation(cell: cell, image: image, complete: {
                    cell.doProgress(hidden: false)
                    self.isFirst = false
                })
            }else {
                /// 没有默认图的时候就直接渐隐出来
                cell.alpha = 0
                UIView.animate(withDuration: self.duration, animations: {
                    self.backgroundColor = UIColor.black
                    cell.alpha = 1
                }, completion: { _ in
                    self.delegate?.viewerDidAnimation(index: self.currentPage, isAppear: true, image: nil)
                    cell.doProgress(hidden: false)
                    self.isFirst = false
                })
            }
        }
        
        return self
    }
    
    fileprivate func animation(cell: JSPictureCell, image: UIImage, complete: (() -> Void)? = nil) {
        if let rect = delegate!.animationRect(index: currentPage) {
            cell.imageView.frame = rect
        }else {
            cell.imageView.frame = CGRect.zero
        }
        
        UIView.animate(withDuration: self.duration, animations: {
            cell.imageView.frame = adaptationRect(size: image.size)
            self.backgroundColor = UIColor.black
        }, completion: { _ in
            self.delegate?.viewerDidAnimation(index: self.currentPage, isAppear: true, image: nil)
            complete?()
        })
    }
    
}

extension JSPictureViewer: UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width + 0.5)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalPage
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        /// 避免出现重用
        /// 重用的时候避免之前已经放大过
        (cell as! JSPictureCell).scrollView.zoomScale = 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! JSPictureCell
        cell.indexPath = indexPath
        cell.delegate = self
        cell.reset()
        
        switch source {
        case .url:
            cell.placeholderImage = delegate!.placeholderImage(indexPath.row)
            cell.url = dataSource[indexPath.row].url ?? ""
            if isFirst {
                cell.doProgress(hidden: true)
            }
            break
        case .image:
            cell.finalImage = dataSource[indexPath.row].image
        }
        return cell
    }
    
}

extension JSPictureViewer: JSPictureCellDelegate {
    
    func processOffset(_ alpha: CGFloat) {
        /// closeDisplay调用之后，就不能再对backgroundColor进行设置，不然动画中的效果就不会执行
        if !isClose {
            backgroundColor = UIColor.black.withAlphaComponent(1 - alpha)
        }
    }
    
    func closeDisplay(cell: JSPictureCell) {
        /// 只有当前页的cell才能进行关闭操作
        guard cell.indexPath.row == currentPage else { return }

        isClose = true
        delegate?.viewerWillAnimation(index: currentPage, isAppear: false)
        
        /// 计算最后view的frame
        if let rect = delegate!.animationRect(index: cell.indexPath.row) {
            let finalRect = CGRect(origin: CGPoint(x: cell.offset.x + rect.origin.x, y: cell.offset.y + rect.origin.y), size: rect.size)
            
            UIView.animate(withDuration: duration, animations: {
                cell.imageView.frame = finalRect
                self.backgroundColor = UIColor.clear
            }) { _ in
                self.delegate?.viewerDidAnimation(index: self.currentPage, isAppear: false, image: cell.imageView.image)
                self.removeFromSuperview()
            }
        }else {
            /// 当cell不可见的时候，直接就渐隐消失
            UIView.animate(withDuration: duration, animations: {
                self.alpha = 0
            }, completion: { _ in
                self.delegate?.viewerDidAnimation(index: self.currentPage, isAppear: false, image: cell.imageView.image)
                self.removeFromSuperview()
            })
        }
    }
    
}




