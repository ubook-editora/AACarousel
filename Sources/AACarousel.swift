//
//  AACarousel.swift
//  AACarousel
//
//  Created by Alan on 2017/6/11.
//  Copyright © 2017年 Alan. All rights reserved.
//

import UIKit

public protocol AACarouselDelegate {
    func didSelectCarouselView(_ view:AACarousel, _ index:Int)
    func callBackFirstDisplayView(_ imageView:UIImageView, _ url:[String], _ index:Int)
    func downloadImages(_ url:String, _ index:Int)
}

let needDownload = "http"

public class AACarousel: UIView,UIScrollViewDelegate {
    
    public var delegate:AACarouselDelegate?
    public var images = [UIImage]()
    public enum direction: Int {
        case left = -1, none, right
    }
    public enum pageControlPosition:Int {
        case top = 0, center = 1, bottom = 2, topLeft = 3, bottomLeft = 4, topRight = 5, bottomRight = 6
    }
    public enum displayModel:Int {
        case full = 0, halfFull = 1, banner = 2
    }
    //MARK:- private property
    private var scrollView:UIScrollView!
    private var describedLabel:UILabel!
    private var layerView:UIView!
    private var pageControl:UIPageControl!
    
    private var beforeImageView:UIImageView!
    private var currentImageView:UIImageView!
    private var afterImageView:UIImageView!
    
    private var beforeImageViewShadow:UIView!
    private var currentImageViewShadow:UIView!
    private var afterImageViewShadow:UIView!
    
    private var currentIndex:NSInteger!
    private var describedString = [String]()
    private var timer:Timer?
    private var defaultImg:String?
    private var timerInterval:Double?
    private var indicatorPosition:pageControlPosition = pageControlPosition.bottom
    private var carouselMode:displayModel = displayModel.full
    
    private var showShadow: Bool = false
    private var shadowCornerRadius: CGFloat = 10
    
    private var shadowOffset: CGSize = CGSize(width: 0, height: 1)
    private var shadowColor: UIColor = UIColor.black
    private var shadowRadius: CGFloat = 7
    private var shadowOpacity: Float = 0.4
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        initWithScrollView()
        initWithImageViewShadow()
        initWithImageView()
        initWithLayerView()
        initWithLabel()
        initWithPageControl()
        initWithGestureRecognizer()
        setNeedsDisplay()
        
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        setScrollViewFrame()
        setImageViewFrame()
        setImageViewShadowFrame()
        setLayerViewFrame()
        setLabelFrame()
        setPageControlFrame()
        
        
    }
    
    //MARK:- Interface Builder(Xib,StoryBoard)
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        initWithScrollView()
        initWithImageViewShadow()
        initWithImageView()
        initWithLayerView()
        initWithLabel()
        initWithPageControl()
        initWithGestureRecognizer()
        setNeedsDisplay()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK:- initialize method
    fileprivate func initWithScrollView() {
        
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.delegate = self
        addSubview(scrollView)
        
    }
    
    fileprivate func initWithLayerView() {
        
        layerView = UIView()
        layerView.backgroundColor = UIColor.black
        layerView.alpha = 0.6
        scrollView.addSubview(layerView)
    }
    
    
    fileprivate func initWithLabel() {
        
        describedLabel = UILabel()
        describedLabel.textAlignment = NSTextAlignment.left
        describedLabel.font = UIFont.boldSystemFont(ofSize: 18)
        describedLabel.numberOfLines = 2
        describedLabel.textColor = UIColor.white
        layerView.addSubview(describedLabel)
    }
    
    fileprivate func initWithPageControl() {
        
        pageControl = UIPageControl()
        pageControl.hidesForSinglePage = true
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.pageIndicatorTintColor = UIColor.gray
        addSubview(pageControl)
    }
    
    fileprivate func initWithImageView() {
        
        beforeImageView = UIImageView()
        currentImageView = UIImageView()
        afterImageView = UIImageView()
        beforeImageView.contentMode = UIView.ContentMode.scaleToFill
        currentImageView.contentMode = UIView.ContentMode.scaleToFill
        afterImageView.contentMode = UIView.ContentMode.scaleToFill
        beforeImageView.clipsToBounds = true
        currentImageView.clipsToBounds = true
        afterImageView.clipsToBounds = true
        scrollView.addSubview(beforeImageView)
        scrollView.addSubview(currentImageView)
        scrollView.addSubview(afterImageView)
        
    }
    
    fileprivate func initWithImageViewShadow() {
        beforeImageViewShadow = UIView()
        currentImageViewShadow = UIView()
        afterImageViewShadow = UIView()
        
        beforeImageViewShadow.backgroundColor = .clear
        beforeImageViewShadow.layer.shadowOffset = shadowOffset
        beforeImageViewShadow.layer.shadowColor = shadowColor.cgColor
        beforeImageViewShadow.layer.shadowRadius = shadowRadius
        beforeImageViewShadow.layer.shadowOpacity = shadowOpacity
        beforeImageViewShadow.layer.masksToBounds = false
        beforeImageViewShadow.clipsToBounds = false
        beforeImageViewShadow.isHidden = !showShadow
        
        currentImageViewShadow.backgroundColor = .clear
        currentImageViewShadow.layer.shadowOffset = shadowOffset
        currentImageViewShadow.layer.shadowColor = shadowColor.cgColor
        currentImageViewShadow.layer.shadowRadius = shadowRadius
        currentImageViewShadow.layer.shadowOpacity = shadowOpacity
        currentImageViewShadow.layer.masksToBounds = false
        currentImageViewShadow.clipsToBounds = false
        currentImageViewShadow.isHidden = !showShadow
        
        afterImageViewShadow.backgroundColor = .clear
        afterImageViewShadow.layer.shadowOffset = shadowOffset
        afterImageViewShadow.layer.shadowColor = shadowColor.cgColor
        afterImageViewShadow.layer.shadowRadius = shadowRadius
        afterImageViewShadow.layer.shadowOpacity = shadowOpacity
        afterImageViewShadow.layer.masksToBounds = false
        afterImageViewShadow.clipsToBounds = false
        afterImageViewShadow.isHidden = !showShadow
        
        scrollView.addSubview(beforeImageViewShadow)
        scrollView.addSubview(currentImageViewShadow)
        scrollView.addSubview(afterImageViewShadow)
    }
    
    fileprivate func initWithGestureRecognizer() {
        
        let singleFinger = UITapGestureRecognizer(target: self, action: #selector(didSelectImageView(_:)))
        
        addGestureRecognizer(singleFinger)
    }
    
    fileprivate func initWithData(_ paths:[String],_ describedTitle:[String]) {
        
        currentIndex = 0
        images.removeAll()
        images.reserveCapacity(paths.count)
        
        //default image
        for _ in 0..<paths.count {
            images.append(UIImage(named: defaultImg ?? "") ?? UIImage())
        }
        
        //get all image
        for i in 0..<paths.count {
            if paths[i].contains(needDownload) {
                downloadImages(paths[i], i)
            } else {
                images[i] = UIImage(named: paths[i]) ?? UIImage()
            }
        }
        
        //get all describeString
        var copyDescribedTitle:[String] = describedTitle
        if describedTitle.count < paths.count {
            let count = paths.count - describedTitle.count
            for _ in 0..<count {
                copyDescribedTitle.append("")
            }
        }
        describedString = copyDescribedTitle
    }
    
    
    //MARK:- frame method
    fileprivate func setScrollViewFrame() {
        
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.frame = CGRect.init(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        scrollView.contentSize = CGSize.init(width: frame.size.width * 5, height:0)
        scrollView.contentOffset = CGPoint.init(x: frame.size.width * 2, y: 0)
        
    }
    
    fileprivate func setLayerViewFrame() {
        
        layerView.frame = CGRect.init(x: 0 , y: scrollView.frame.size.height - 80, width: scrollView.frame.size.width * 5, height: 80)
        layerView.isUserInteractionEnabled = false
    }
    
    fileprivate func setImageViewFrame() {
        
        switch carouselMode {
        case .full:
            beforeImageView.frame = CGRect.init(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            currentImageView.frame = CGRect.init(x: scrollView.frame.size.width * 2, y: 0, width: scrollView.frame.size.width , height: scrollView.frame.size.height)
            afterImageView.frame = CGRect.init(x: scrollView.frame.size.width * 3, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            break
        case .halfFull:
            handleHalfFullImageViewFrame(false)
            beforeImageView.alpha = 0.6
            afterImageView.alpha = 0.6
            break
        case .banner:
            handleBannerImageViewFrame(false)
            handleBannerImageViewShadowFrame(false)
            break
        }
    }
    
    fileprivate func setImageViewShadowFrame() {
        handleBannerImageViewShadowFrame(false)
    }
    
    fileprivate func setLabelFrame() {
        
        describedLabel.frame = CGRect.init(x: scrollView.frame.size.width * 2 + 10 , y: layerView.frame.size.height - 75, width: scrollView.frame.size.width - 20, height: 70)
        
    }
    
    
    fileprivate func setPageControlFrame() {
        
        
        switch indicatorPosition {
        case .top:
            pageControl.center = CGPoint.init(x: scrollView.frame.size.width / 2, y: 10)
            break
        case .center:
            pageControl.center = CGPoint.init(x: scrollView.frame.size.width / 2, y: scrollView.frame.size.height / 2)
            break
        case .topLeft:
            pageControl.frame = CGRect.init(x: 8 * images.count, y: 5, width: 0, height: 10)
            break
        case .bottomLeft:
            pageControl.frame = CGRect.init(x: 8 * images.count, y: Int(scrollView.frame.size.height - 10), width: 0, height: 0)
            break
        case .topRight:
            pageControl.frame = CGRect.init(x: Int(scrollView.frame.size.width) - 8 * images.count, y: 5, width: 0, height: 10)
            break
        case .bottomRight:
            pageControl.frame = CGRect.init(x: Int(scrollView.frame.size.width) - 8 * images.count, y: Int(scrollView.frame.size.height - 10), width: 0, height: 0)
            break
        default:
            pageControl.center = CGPoint.init(x: scrollView.frame.size.width / 2, y: scrollView.frame.size.height - 10)
            break
        }
    }
    
    //MARK:- set subviews layout method
    public func setCarouselLayout(displayStyle:Int, pageIndicatorPositon:Int, pageIndicatorColor:UIColor?, describedTitleColor:UIColor?, layerColor:UIColor?) {
        
        carouselMode = displayModel.init(rawValue: displayStyle) ?? .full
        
        if (carouselMode == .banner) {
            setShowShadown(true)
        }
        
        indicatorPosition = pageControlPosition.init(rawValue: pageIndicatorPositon) ?? .bottom
        pageControl.currentPageIndicatorTintColor = pageIndicatorColor ?? .white
        describedLabel.textColor = describedTitleColor ?? .white
        layerView.backgroundColor = layerColor ?? .black
        setNeedsLayout()
    }
    
    //MARK:- set subviews show method
    public func setCarouselOpaque(layer:Bool, describedTitle:Bool, pageIndicator:Bool) {
        
        layerView.isHidden = layer
        describedLabel.isHidden = describedTitle
        pageControl.isHidden = pageIndicator
    }
    
    
    //MARK:- set data method
    public func setCarouselData(paths:[String],describedTitle:[String],isAutoScroll:Bool,timer:Double?,defaultImage:String?) {
        
        if paths.count == 0 {
            return
        }
        timerInterval = timer
        defaultImg = defaultImage
        initWithData(paths,describedTitle)
        setImage(paths, currentIndex)
        setLabel(describedTitle, currentIndex)
        setScrollEnabled(paths, isAutoScroll)
    }
    
    //MARK:- set scroll method
    fileprivate func setScrollEnabled(_ url:[String],_ isAutoScroll:Bool) {
        
        stopAutoScroll()
        //setting auto scroll & more than one
        if isAutoScroll && url.count > 1 {
            scrollView.isScrollEnabled = true
            startAutoScroll()
        } else if url.count == 1 {
            scrollView.isScrollEnabled = false
        }
    }
    
    //MARK:- set first display view
    fileprivate func setImage(_ imageUrl:[String], _ curIndex:NSInteger) {
        
        if imageUrl.count == 0 {
            return
        }
        
        var beforeIndex = curIndex - 1
        let currentIndex = curIndex
        var afterIndex = curIndex + 1
        if beforeIndex < 0 {
            beforeIndex = imageUrl.count - 1
        }
        if afterIndex > imageUrl.count - 1 {
            afterIndex = 0
        }
        
        handleFirstImageView(currentImageView, imageUrl, curIndex)
        //more than one
        if imageUrl.count > 1 {
            handleFirstImageView(beforeImageView, imageUrl, beforeIndex)
            handleFirstImageView(afterImageView, imageUrl, afterIndex)
        }
        pageControl.numberOfPages = imageUrl.count
        pageControl.currentPage = currentIndex
        layoutSubviews()
        
    }
    
    
    fileprivate func handleFirstImageView(_ imageView:UIImageView,_ imageUrl:[String], _ curIndex:NSInteger) {
        
        delegate?.callBackFirstDisplayView(imageView, imageUrl, curIndex)
    }
    
    fileprivate func setLabel(_ describedTitle:[String], _ curIndex:NSInteger) {
        
        if describedTitle.count == 0 {
            return
        }
        
        describedLabel.text = describedTitle[curIndex]
    }
    
    //MARK:- change display view
    fileprivate func scrollToImageView(_ scrollDirect:direction) {
        
        if images.count == 0  {
            return
        }
        
        switch scrollDirect {
        case .none:
            
            break
        //right direct
        case .right:
            //change ImageView
            beforeImageView.image = currentImageView.image
            currentImageView.image = images[currentIndex]
            
            if currentIndex + 1 > images.count - 1 {
                afterImageView.image = images[0]
            } else {
                afterImageView.image = images[currentIndex + 1]
            }
            break
        //left direct
        case .left:
            //change ImageView
            afterImageView.image = currentImageView.image
            currentImageView.image =  images[currentIndex]
            
            if currentIndex - 1 < 0 {
                beforeImageView.image = images[images.count - 1]
            }else {
                beforeImageView.image = images[currentIndex - 1]
            }
            break
        }
        //chage Label
        describedLabel.text = describedString[currentIndex]
        
        switch carouselMode {
        case .full:
            break
        case .halfFull:
            UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseInOut, animations: {
                self.handleHalfFullImageViewFrame(false)
            }, completion: nil)
            
            break
        case .banner:
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.handleBannerImageViewFrame(false)
                self.handleBannerImageViewShadowFrame(false)
            }, completion: nil)
            break
        }
        
        scrollView.contentOffset = CGPoint.init(x: frame.size.width * 2, y: 0)
    }
    
    //MARK:- set auto scroll
    fileprivate func startAutoScroll() {
        
        timer = Timer()
        timer = Timer.scheduledTimer(timeInterval: timerInterval ?? 5, target: self, selector: #selector(autoScrollToNextImageView), userInfo: nil, repeats: true)
        
    }
    
    fileprivate func stopAutoScroll() {
        
        timer?.invalidate()
        timer = nil
    }
    
    @objc fileprivate func autoScrollToNextImageView() {
        
        switch carouselMode {
        case .full:
            break
        case .halfFull:
            handleHalfFullImageViewFrame(true)
            break
        case .banner:
            handleBannerImageViewFrame(true)
            handleBannerImageViewShadowFrame(true)
            break
        }
        scrollView.setContentOffset(CGPoint.init(x: frame.size.width * 3, y: 0), animated: true)
        
    }
    
    @objc fileprivate func autoScrollToBeforeImageView() {
        
        switch carouselMode {
        case .full:
            break
        case .halfFull:
            handleHalfFullImageViewFrame(true)
            break
        case .banner:
            handleBannerImageViewFrame(true)
            handleBannerImageViewShadowFrame(true)
            break
        }
        scrollView.setContentOffset(CGPoint.init(x: frame.size.width * 1, y: 0), animated: true)
        
    }
    
    
    //MARK:- UITapGestureRecognizer
    @objc fileprivate func didSelectImageView(_ sender: UITapGestureRecognizer) {
        
        delegate?.didSelectCarouselView(self, currentIndex)
    }
    
    
    //MARK:- UIScrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if images.count == 0  {
            return
        }
        
        let width = scrollView.frame.width
        let currentPage = ((scrollView.contentOffset.x - width / 2) / width) - 1.5
        let scrollDirect = direction.init(rawValue: Int(currentPage))
        
        switch scrollDirect! {
        case .none:
            break
        default:
            handleIndex(scrollDirect!)
            scrollToImageView(scrollDirect!)
            break
        }
        
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        switch carouselMode {
        case .full:
            break
        case .halfFull:
            handleHalfFullImageViewFrame(true)
            break
        case .banner:
            handleBannerImageViewFrame(true)
            handleBannerImageViewShadowFrame(true)
            break
        }
        stopAutoScroll()
    }
    
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        startAutoScroll()
        
    }
    
    public func setImageViewContentMode(contentMode: UIView.ContentMode) {
        beforeImageView.contentMode = contentMode
        currentImageView.contentMode = contentMode
        afterImageView.contentMode = contentMode
    }
    
    public func setImageViewCornerRadius(radius: CGFloat) {
        beforeImageView.layer.cornerRadius = radius
        currentImageView.layer.cornerRadius = radius
        afterImageView.layer.cornerRadius = radius
    }
    
    public func setShadownCornerRadius(radius: CGFloat) {
        shadowCornerRadius = radius
    }
    
    public func setShowShadown(_ show : Bool) {
        showShadow = show
        
        beforeImageViewShadow.isHidden = !showShadow
        currentImageViewShadow.isHidden = !showShadow
        afterImageViewShadow.isHidden = !showShadow
    }
    
    public func setShadowOffset(offset: CGSize) {
        shadowOffset = offset
        beforeImageViewShadow.layer.shadowOffset = shadowOffset
    }
    
    public func setShadowColor(color: UIColor) {
        shadowColor = color
        beforeImageViewShadow.layer.shadowColor = shadowColor.cgColor
    }
    
    public func setShadowRadius(radius: CGFloat) {
        shadowRadius = radius
        beforeImageViewShadow.layer.shadowRadius = shadowRadius
    }
    
    public func setShadowOpacity(opacity: Float) {
        shadowOpacity = opacity
        beforeImageViewShadow.layer.shadowOpacity = shadowOpacity
    }
    
    //MARK:- handle scroll imageview frame
    fileprivate func handleHalfFullImageViewFrame(_ isScroll:Bool) {
        
        switch isScroll {
        case true:
            beforeImageView.frame = CGRect.init(x: scrollView.frame.size.width + 30, y: 0, width: scrollView.frame.size.width - 60, height: scrollView.frame.size.height)
            afterImageView.frame = CGRect.init(x: scrollView.frame.size.width * 3 + 30, y: 0, width: scrollView.frame.size.width - 60, height: scrollView.frame.size.height)
            break
        default:
            beforeImageView.frame = CGRect.init(x: scrollView.frame.size.width + 80, y: 20, width: scrollView.frame.size.width - 60, height: scrollView.frame.size.height - 60)
            currentImageView.frame = CGRect.init(x: scrollView.frame.size.width * 2 + 30, y: 0, width: scrollView.frame.size.width - 60, height: scrollView.frame.size.height)
            afterImageView.frame = CGRect.init(x: scrollView.frame.size.width * 3 - 20, y: 20, width: scrollView.frame.size.width - 60, height: scrollView.frame.size.height - 60)
            break
        }
        
    }
    
    fileprivate func handleBannerImageViewFrame(_ isScroll:Bool) {
        let heightOffset: CGFloat = (showShadow ? -26 : 0)
        let originYOffset: CGFloat = (showShadow ? 12 : 0)
        
        switch isScroll {
        case true:
            beforeImageView.frame = CGRect.init(x: scrollView.frame.size.width + 20, y: originYOffset, width: scrollView.frame.size.width - 40, height: (scrollView.frame.size.height + heightOffset))
            afterImageView.frame = CGRect.init(x: scrollView.frame.size.width * 3 + 20, y: originYOffset, width: scrollView.frame.size.width - 40, height: (scrollView.frame.size.height + heightOffset))
            break
        default:
            beforeImageView.frame = CGRect.init(x: scrollView.frame.size.width + 70, y: originYOffset, width: scrollView.frame.size.width - 60, height: (scrollView.frame.size.height + heightOffset))
            currentImageView.frame = CGRect.init(x: scrollView.frame.size.width * 2 + 20, y: originYOffset, width: scrollView.frame.size.width - 40, height: (scrollView.frame.size.height + heightOffset))
            afterImageView.frame = CGRect.init(x: scrollView.frame.size.width * 3 - 10, y: originYOffset, width: scrollView.frame.size.width - 60, height: (scrollView.frame.size.height + heightOffset))
            break
        }
        
    }
    
    
    fileprivate func handleBannerImageViewShadowFrame(_ isScroll:Bool) {
        let heightOffset: CGFloat = (showShadow ? 0 : 0)
        let originYOffset: CGFloat = (showShadow ? 0 : 0)
        
        beforeImageViewShadow.frame = CGRect(x: beforeImageView.frame.origin.x, y: beforeImageView.frame.origin.y + originYOffset, width: beforeImageView.frame.width, height: beforeImageView.frame.height + heightOffset)
        currentImageViewShadow.frame = CGRect(x: currentImageView.frame.origin.x, y: currentImageView.frame.origin.y + originYOffset, width: currentImageView.frame.width, height: currentImageView.frame.height + heightOffset)
        afterImageViewShadow.frame = CGRect(x: afterImageView.frame.origin.x, y: afterImageView.frame.origin.y + originYOffset, width: afterImageView.frame.width, height: afterImageView.frame.height + heightOffset)
        
        beforeImageViewShadow.layer.shadowPath = UIBezierPath(roundedRect: beforeImageView.bounds, cornerRadius: shadowCornerRadius).cgPath
        currentImageViewShadow.layer.shadowPath = UIBezierPath(roundedRect: currentImageView.bounds, cornerRadius: shadowCornerRadius).cgPath
        afterImageViewShadow.layer.shadowPath = UIBezierPath(roundedRect: afterImageView.bounds, cornerRadius: shadowCornerRadius).cgPath
    }
    
    
    //MARK:- handle current index
    fileprivate func handleIndex(_ scrollDirect:direction) {
        
        switch scrollDirect {
        case .none:
            break
        case .right:
            currentIndex = currentIndex + 1
            if currentIndex == images.count {
                currentIndex = 0
            }
            break
        case .left:
            currentIndex = currentIndex - 1
            if currentIndex < 0 {
                currentIndex = images.count - 1
            }
            break
        }
        pageControl.currentPage = currentIndex
    }
    
    //MARK:- download all images
    fileprivate func downloadImages(_ url:String, _ index:Int) {
        
        delegate?.downloadImages(url, index)
    }
    
    
    //MARK:- public control method
    public func startScrollImageView() {
        
        startAutoScroll()
    }
    
    public func stopScrollImageView() {
        
        stopAutoScroll()
    }
    
    
    
}

extension AACarouselDelegate {
    
    func didSelectCarouselView(_ view:AACarousel, _ index:Int) {
    }
    
    func callBackFirstDisplayView(_ imageView:UIImageView, _ url:[String], _ index:Int) {
    }
}
