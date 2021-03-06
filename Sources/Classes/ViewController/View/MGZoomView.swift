//
//  MGZoomView.swift
//  MogoRenter
//
//  Created by song on 16/8/8.
//  Copyright © 2016年 MogoRoom. All rights reserved.
//

/**
    预览cell中的控件 主要功能：缩放
 */

import UIKit

open class MGZoomView: UIControl, UIScrollViewDelegate {
    
    fileprivate let screenWidth: CGFloat = UIScreen.main.bounds.size.width
    fileprivate let screenHeight: CGFloat = UIScreen.main.bounds.size.height
    fileprivate let maxScale: CGFloat = 3.0 // 最大的缩放比例
    fileprivate let minScale: CGFloat = 1.0 // 最小的缩放比例
    
    fileprivate let animDuration: TimeInterval = 0.0 // 动画时长
    
    // MARK: - Public property
    
    // 图片开始时的frame
    open var originFrame: CGRect = CGRect.zero
    // 要显示的图片
    open var image: UIImage? {
        didSet {
            if let _image = image {
                if self.originFrame == CGRect.zero {
                    let imageViewH = _image.size.height / _image.size.width * screenWidth
                    self.imageView?.bounds = CGRect(x: 0, y: 0, width: screenWidth, height: imageViewH)
                    self.imageView?.center = (scrollView?.center)!
                } else {
                    self.imageView?.frame = self.originFrame
                }
                self.imageView?.image = image
            }
        }
    }
    
    /*! 点击背景后的回调 */
    var tapImageBlock : (() ->())!
    
    // MARK: - Private property
    
    fileprivate var scrollView: UIScrollView?
    var imageView: UIImageView?
    
    fileprivate var scale: CGFloat = 1.0 // 当前的缩放比例
    fileprivate var touchX: CGFloat = 0.0 // 双击点的X坐标
    fileprivate var touchY: CGFloat = 0.0 // 双击点的Y坐标
    
    fileprivate var isDoubleTapingForZoom: Bool = false // 是否是双击缩放
    
    // MARK: - Life cycle
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        // 初始化View
        self.initAllView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIScrollViewDelegate
    
    open func scrollViewDidZoom(_ scrollView: UIScrollView) {
        //当捏或移动时，需要对center重新定义以达到正确显示位置
        var centerX = scrollView.center.x
        var centerY = scrollView.center.y
        centerX = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width / 2 : centerX
        centerY = scrollView.contentSize.height > scrollView.frame.size.height ?scrollView.contentSize.height / 2 : centerY
        
        self.imageView?.center = CGPoint(x: centerX, y: centerY)
        
        // ****************双击放大图片关键代码*******************
        
        if isDoubleTapingForZoom {
            let contentOffset = self.scrollView?.contentOffset
            let center = self.center
            let offsetX = center.x - self.touchX
            //            let offsetY = center.y - self.touchY
            self.scrollView?.contentOffset = CGPoint(x: (contentOffset?.x)! - offsetX * 2.2, y: (contentOffset?.y)!)
        }
        
        // ****************************************************
        
    }
    
    open func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.scale = scale
    }
    
    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView!
    }
    
    // MARK: - Event response
    // 单击手势事件
    @objc func singleTapClick(_ tap: UITapGestureRecognizer) {
        if tapImageBlock != nil {
            tapImageBlock()
        }
    }
    
    // 双击手势事件
    @objc func doubleTapClick(_ tap: UITapGestureRecognizer) {
        self.touchX = tap.location(in: tap.view).x
        self.touchY = tap.location(in: tap.view).y
        
        if self.scale > 1.0 {
            self.scale = 1.0
            self.scrollView?.setZoomScale(self.scale, animated: true)
        } else {
            self.scale = maxScale
            self.isDoubleTapingForZoom = true
            self.scrollView?.setZoomScale(maxScale, animated: true)
        }
        self.isDoubleTapingForZoom = false
        
    }
    
    // MARK: - Private methods
    
    fileprivate func initAllView() {
        self.alpha = 0.0
        // UIScrollView
        self.scrollView = UIScrollView()
        self.scrollView?.showsVerticalScrollIndicator = false
        self.scrollView?.showsHorizontalScrollIndicator = false
        self.scrollView?.maximumZoomScale = maxScale // scrollView最大缩放比例
        self.scrollView?.minimumZoomScale = minScale // scrollView最小缩放比例
        self.scrollView?.backgroundColor = UIColor.black
        self.scrollView?.delegate = self
        self.scrollView?.frame = self.bounds
        self.addSubview(self.scrollView!)
        
        // 添加手势
        // 1.单击手势
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(MGZoomView.singleTapClick(_:)))
        singleTap.numberOfTapsRequired = 1
        self.scrollView?.addGestureRecognizer(singleTap)
        // 2.双击手势
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(MGZoomView.doubleTapClick(_:)))
        doubleTap.numberOfTapsRequired = 2
        self.scrollView?.addGestureRecognizer(doubleTap)
        // 必须加上这句，否则双击手势不管用
        singleTap.require(toFail: doubleTap)
        
        // UIImageView
        self.imageView = UIImageView()
        self.scrollView?.addSubview(self.imageView!)
    }
    
    // MARK: - Public methods
    
    open func show() {
        self.scrollView?.backgroundColor = UIColor.black
        UIView.animate(withDuration: self.animDuration, delay: 0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
            let imageSize = self.image?.size ?? CGSize(width: 50, height: 50)
            self.imageView?.bounds = CGRect(x: 0, y: 0, width: self.screenWidth, height: imageSize.height / imageSize.width * self.screenWidth)
            self.imageView?.center = (self.scrollView?.center)!
            self.alpha = 1.0
            self.scrollView?.zoomScale = 1.0
        }) { (finished) in
        }
    }
    
}
