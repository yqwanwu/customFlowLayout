//
//  CollectionViewController.swift
//  线程测试
//
//  Created by wanwu on 17/3/21.
//  Copyright © 2017年 wanwu. All rights reserved.
//

import UIKit

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    let layout = WaterfallLayout()//UICollectionViewFlowLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        
        let nib = UINib(nibName: "CollectionReusableView", bundle: Bundle.main)
        collectionView.register(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footer")
        collectionView.register(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        
        //设置布局
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        
        //设置列数
        layout.column = 3
        
        collectionView.setCollectionViewLayout(layout, animated: true)
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        layout.setHeightFotItem { (idx) -> CGFloat in
            return CGFloat(arc4random() % 160 + 50)
        }
    }

}


extension CollectionViewController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
  
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor(red: CGFloat((arc4random() % 100)) / 100.0, green: CGFloat((arc4random() % 100)) / 100.0, blue: CGFloat((arc4random() % 100)) / 100.0, alpha: 1)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: indexPath)
            view.backgroundColor = UIColor.yellow
            return view
        } else {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footer", for: indexPath)
            view.backgroundColor = UIColor.red
            return view
        }
        
    }
}




///瀑布流布局
class WaterfallLayout: UICollectionViewFlowLayout {
    
    var attrArr = [UICollectionViewLayoutAttributes]()
    private var columnHeights = [CGFloat]()
    private var widths = [CGFloat]()
    
    var column = 2
    var supplementaryViewOfKind = ""
    
    var maxY: CGFloat = 0.0
    var ys = [CGFloat]()
    
    typealias heightForItem = (_ indexPath: IndexPath) -> CGFloat
    
    private var blockForHeight: heightForItem?
    
    func setHeightFotItem(closure: @escaping heightForItem) {
        blockForHeight = closure
    }
    
    override func prepare() {
//        super.prepare()
        guard let collectionView = self.collectionView else { return }
        
        for section in 0..<collectionView.numberOfSections {
            let itemCount = collectionView.numberOfItems(inSection: section)
            
            ///添加header
            var headerSize: CGSize = self.headerReferenceSize
            if let delegateLayout = collectionView.dataSource as? UICollectionViewDelegateFlowLayout {
                headerSize = delegateLayout.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: section) ?? self.headerReferenceSize
            }
            let h = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: IndexPath(item: 0, section: section))
            h.frame = CGRect(x: 0, y: maxY, width: headerSize.width, height: headerSize.height)
            attrArr.append(h)
            
            //添加header的高度
            maxY += headerSize.height
            ys.append(maxY)
            
            //保存每一列的高度
            var heightArr = [[CGFloat]]()
            for _ in 0..<column {
                heightArr.append([self.sectionInset.top + maxY])
            }
            
            let itemWidth = (collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right - minimumInteritemSpacing * CGFloat(column - 1) - sectionInset.left - sectionInset.right) / CGFloat(column)
            
            var x: CGFloat = 0.0
            var y: CGFloat = 0.0
            for i in 0..<itemCount {
                let index = IndexPath(item: i, section: section)
                let attr = UICollectionViewLayoutAttributes(forCellWith: index)//
                let height = blockForHeight?(index) ?? 0//
                
                var minHeightIndex = 0
                for i in 0..<heightArr.count {
                    if heightArr[minHeightIndex].last ?? 0 > heightArr[i].last ?? 0 {
                        minHeightIndex = i
                    }
                }
                
                x = self.sectionInset.left + (minimumInteritemSpacing + itemWidth) * CGFloat(minHeightIndex)
                attr.frame = CGRect(x: x, y: heightArr[minHeightIndex].last ?? 0, width: itemWidth, height: height)
                y = (heightArr[minHeightIndex].last ?? 0) + height + self.minimumLineSpacing
                heightArr[minHeightIndex].append(y)
                attr.indexPath = index
                
                maxY = max(y, maxY) - self.minimumLineSpacing + sectionInset.bottom
                attrArr.append(attr)
            }
            
            ///添加footer
            var footerSize: CGSize = self.footerReferenceSize
            if let delegateLayout = collectionView.dataSource as? UICollectionViewDelegateFlowLayout {
                footerSize = delegateLayout.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: section) ?? self.footerReferenceSize
            }
            let f = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, with: IndexPath(item: 0, section: section))
            f.frame = CGRect(x: 0, y: maxY, width: footerSize.width, height: footerSize.height)
            attrArr.append(f)
            
            maxY += footerSize.height
        }
    }
    
    override var collectionViewContentSize: CGSize {
        let size = super.collectionViewContentSize
        return CGSize(width: size.width, height: maxY)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attrArr
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return !newBounds.size.equalTo(self.collectionView!.frame.size)
    }
}





///居左布局
class LeftAlignLayout: UICollectionViewFlowLayout {
    
    var attrArr = [UICollectionViewLayoutAttributes]()
    private var columnHeights = [CGFloat]()
    private var widths = [CGFloat]()
    var supplementaryViewOfKind = ""
    
    var maxY: CGFloat = 0.0
    
    typealias sizeForItem = (_ indexPath: IndexPath) -> CGSize
    
    private var blockForSize: sizeForItem?
    
    func setWidthFotItem(closure: @escaping sizeForItem) {
        blockForSize = closure
    }
    
    override func prepare() {
//        super.prepare()
        guard let collectionView = self.collectionView else { return }
        
        let collectionWidth = (collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right - sectionInset.left - sectionInset.right)
        
        var x: CGFloat = 0.0
        let left = collectionView.contentInset.left + sectionInset.left
        let top = collectionView.contentInset.top + sectionInset.top
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0
        var y: CGFloat = 0
        
        var coordinate = [CGRect]()
        
        for section in 0..<collectionView.numberOfSections {
            ///添加header
            var headerSize: CGSize = self.headerReferenceSize
            if let delegateLayout = collectionView.dataSource as? UICollectionViewDelegateFlowLayout {
                headerSize = delegateLayout.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: section) ?? self.headerReferenceSize
            }
            
            let h = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: IndexPath(item: 0, section: section))
            h.frame = CGRect(x: 0, y: y, width: headerSize.width, height: headerSize.height)
            attrArr.append(h)
            
            let itemCount = collectionView.numberOfItems(inSection: section)
            for i in 0..<itemCount {
                let indexPath = IndexPath(item: i, section: section)
                width = blockForSize?(indexPath).width ?? 0
                height = blockForSize?(indexPath).height ?? 0
                if width > collectionWidth {
                    width = collectionWidth
                }
                if coordinate.count == 0 {
                    x = left
                    y = top + maxY + headerSize.height
                } else {
                    let lastFrame = coordinate.last!
                    x = lastFrame.maxX + minimumInteritemSpacing
                    if x + width > collectionWidth {
                        x = left
                        y += minimumLineSpacing + height
                    }
                }
                let frame = CGRect(x: x, y: y, width: width, height: height)
                coordinate.append(frame)
                let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attr.frame = frame
                attrArr.append(attr)
            }
            coordinate.removeAll(keepingCapacity: true)
            
            ///添加footer
            var footerSize: CGSize = self.footerReferenceSize
            if let delegateLayout = collectionView.dataSource as? UICollectionViewDelegateFlowLayout {
                footerSize = delegateLayout.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: section) ?? self.footerReferenceSize
            }
            let f = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, with: IndexPath(item: 0, section: section))
            f.frame = CGRect(x: 0, y: y + height + sectionInset.bottom, width: footerSize.width, height: footerSize.height)
            attrArr.append(f)
            
            y += footerSize.height + sectionInset.bottom + height
            maxY = y
        }
        
    }
    
    override var collectionViewContentSize: CGSize {
        let size = super.collectionViewContentSize
        return CGSize(width: size.width, height: maxY)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attrArr
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return !newBounds.size.equalTo(self.collectionView!.frame.size)
    }
}
















