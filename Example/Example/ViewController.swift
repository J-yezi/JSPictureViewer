 //
 //  ViewController.swift
 //  PictureBrowser
 //
 //  Created by jesse on 2017/6/13.
 //  Copyright © 2017年 jesse. All rights reserved.
 //
 
import UIKit
import Kingfisher
import JSPictureViewer
 
class ViewController: UIViewController {
    
    var isHidden: Bool = false
    
    fileprivate var indexPath: IndexPath!
    var imageSource = Array<JSPictureConfig>()
    
    lazy var collectionView: UICollectionView = {
        let lendth: CGFloat = (UIScreen.main.bounds.size.width - 4.0) / 3.0
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: lendth, height: lendth)
        layout.minimumLineSpacing = 2.0
        layout.minimumInteritemSpacing = 2.0
        layout.scrollDirection = .vertical
        
        let collectionView: UICollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.register(CustomCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        return collectionView
    }()
    var a: JSPictureViewer?
    fileprivate lazy var bar: UINavigationBar = {
        let bar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 64))
        let item = UINavigationItem(title: "消息")
        bar.pushItem(item, animated: false)
        return bar
    }()
    var urlSource = ["http://cdn.ruguoapp.com/Fv73y0Z9rOQyDxZay4GOJfmJ84ew.jpg?imageView/2/w/100/h/100/q/100",
                     "http://cdn.ruguoapp.com/FsZAUtf8serLpkdTJIh0mqUmpTeN.jpg?imageView/2/w/100/h/100/q/100",
                     "http://cdn.ruguoapp.com/FoIgIUnx09by-vCxZZpIE1IRhr5c.jpg?imageView/2/w/100/h/100/q/100",
                     "http://cdn.ruguoapp.com/o_1aoqqug3d1hu91v567ut17upbem0.jpeg?imageView/2/w/100/h/100/q/100",
                     "http://cdn.ruguoapp.com/o_1aoqquia41mjj9a0bro15rotlo1.jpeg?imageView/2/w/100/h/100/q/100",
                     "http://cdn.ruguoapp.com/o_1aoqqukm6ghrq7t1eoffms1gj42.jpeg?imageView/2/w/100/h/100/q/100",
                     "http://cdn.ruguoapp.com/o_1aoqqupediv2pgsb3it8hah3.jpeg?imageView/2/w/100/h/100/q/100",
                     "http://cdn.ruguoapp.com/FsC-_BF4adWI6UGHK2IjP-uxUWjU.jpg?imageView/2/w/100/h/100/q/100",
                     "http://cdn.ruguoapp.com/FvSxYwKkYnnhNhMshNZFdp6ZHfxK?imageView/2/w/100/h/100/q/100",
                     "http://cdn.ruguoapp.com/FmeHiEaillGfSi_qgnp2rM12s3T4?imageView/2/w/100/h/100/q/100",
                     "http://cdn.ruguoapp.com/FnfXm5YjJpDVzIXISNYT6-tTmd-E?imageView/2/w/100/h/100/q/100",
                     "http://cdn.ruguoapp.com/o_1ak2n0vnrpl3jhdcv01s7cuta1.jpeg?imageView/2/w/100/h/100/q/100"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.brown
        view.addSubview(collectionView)
        automaticallyAdjustsScrollViewInsets = false
        imageSource = [
            JSPictureConfig(url: "http://cdn.ruguoapp.com/Fv73y0Z9rOQyDxZay4GOJfmJ84ew.jpg?imageView2/0/h/1000/interlace/0", image: nil),
            JSPictureConfig(url: "http://cdn.ruguoapp.com/FsZAUtf8serLpkdTJIh0mqUmpTeN.jpg?imageView2/0/h/1000/interlace/0", image: nil),
            JSPictureConfig(url: "http://cdn.ruguoapp.com/FoIgIUnx09by-vCxZZpIE1IRhr5c.jpg?imageView2/0/h/1000/interlace/0", image: nil),
            JSPictureConfig(url: "http://cdn.ruguoapp.com/o_1aoqqug3d1hu91v567ut17upbem0.jpeg?imageView2/0/h/1000/interlace/0", image: nil),
            JSPictureConfig(url: "http://cdn.ruguoapp.com/o_1aoqquia41mjj9a0bro15rotlo1.jpeg?imageView2/0/h/1000/interlace/0", image: nil),
            JSPictureConfig(url: "http://cdn.ruguoapp.com/o_1aoqqukm6ghrq7t1eoffms1gj42.jpeg?imageView2/0/h/1000/interlace/0", image: nil),
            JSPictureConfig(url: "http://cdn.ruguoapp.com/o_1aoqqupediv2pgsb3it8hah3.jpeg?imageView2/0/h/1000/interlace/0", image: nil),
            JSPictureConfig(url: "http://cdn.ruguoapp.com/FsC-_BF4adWI6UGHK2IjP-uxUWjU.jpg?imageView2/0/h/1000/interlace/0", image: nil),
            JSPictureConfig(url: "http://cdn.ruguoapp.com/FvSxYwKkYnnhNhMshNZFdp6ZHfxK?imageView2/0/h/1000/interlace/0", image: nil),
            JSPictureConfig(url: "http://cdn.ruguoapp.com/FmeHiEaillGfSi_qgnp2rM12s3T4?imageView2/0/h/1000/interlace/0", image: nil),
            JSPictureConfig(url: "http://cdn.ruguoapp.com/FnfXm5YjJpDVzIXISNYT6-tTmd-E?imageView2/0/h/1000/interlace/0", image: nil),
            JSPictureConfig(url: "http://cdn.ruguoapp.com/o_1ak2n0vnrpl3jhdcv01s7cuta1.jpeg?imageView2/0/h/1000/interlace/0", image: nil)]
        
//            imageSource = (1...29).map {
//                JSPictureConfig(image: UIImage(contentsOfFile: Bundle.main.path(forResource: "\($0).JPG", ofType: nil)!)!)
//            }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .default
//    }
//    
//    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
//        return .slide
//    }
//    
//    override var prefersStatusBarHidden: Bool {
//        return isHidden
//    }
    
 }
 
 extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CustomCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        cell.contentView.backgroundColor = UIColor.lightGray
//        cell.imageView.image = imageSource[indexPath.row].image
        cell.imageView.kf.setImage(with: URL(string: urlSource[indexPath.row]))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.indexPath = indexPath
        a = JSPictureViewer(index: indexPath.row, source: .url, data: imageSource, delegate: self)
            .display(view)
        
        isHidden = true
        UIView.animate(withDuration: a!.duration) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
 }
 
 class CustomCell: UICollectionViewCell {
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(frame: bounds)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 }
 
 extension ViewController: JSPictureViewerDelegate {
    
    func viewerWillAnimation(index: Int, isAppear: Bool) {
        if isAppear {
            guard let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) else { return }
            cell.isHidden = true
        }else {
            isHidden = false
            UIView.animate(withDuration: a!.duration) {
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    func viewerDidAnimation(index: Int, isAppear: Bool, image: UIImage?) {
        if !isAppear {
            guard let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? CustomCell else { return }
            cell.isHidden = false
            if let image = image {
                cell.imageView.image = image
            }
            a = nil
        }
    }
    
    func changeViewerImage(old: Int, new: Int) {
        guard let oldCell = collectionView.cellForItem(at: IndexPath(row: old, section: 0)) else { return }
        oldCell.isHidden = false
        
        guard let newCell = collectionView.cellForItem(at: IndexPath(row: new, section: 0)) else { return }
        newCell.isHidden = true
    }
    
    func placeholderImage(_ index: Int) -> UIImage? {
        guard let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? CustomCell else { return nil }
        return cell.imageView.image
    }
    
    func animationRect(index: Int) -> CGRect? {
        guard let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) else { return nil }
        return collectionView.convert(cell.frame, to: view)
    }
    
    func animationSize(index: Int) -> CGSize? {
        guard let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? CustomCell else { return nil }
        return cell.imageView.image?.size
    }
    
 }
