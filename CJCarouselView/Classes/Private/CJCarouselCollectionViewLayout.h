//
//  CJCarouselCollectionViewLayout.h
//  CJ
//
//  Created by cj1024 on 2020/12/2.
//  Copyright © 2020 cj1024. All rights reserved.
//

#ifndef CJCarouselCollectionViewLayout_h
#define CJCarouselCollectionViewLayout_h

#import "CJCarouselView.h"

/**
 *  用于实现循环滚动（看起来）的UICollectionView的Layout
 *  假设共有n个Page，实现机理为
 *  将所有Page按  Page_n-1循环预留位置，Page_0，Page_1，…，Page_n-1，Page_0循环预留位置  布局
 *  当滚动到Page_0时，将Page_n-1移到Page_n-1循环预留位置，反之当滚动到Page_n-1是，将Page_0移到Page_0循环预留位置
 *  当滚动到Page_0循环预留位置时，自动滚动到Page_0的位置，反之当滚动到Page_n-1循环预留位置时，自动滚动到Page_n-1的
 *  以此实现循环滚动（看起来）
 *  非循环滚动则按正常方式布局
 */
@interface CJCarouselCollectionViewLayout : UICollectionViewLayout

@property(nonatomic, assign, readwrite) eCJCarouselViewLayoutDirection layoutDirection; // 布局方向

@property(nonatomic, assign, readwrite) BOOL loopingDisabled; // 是否禁用循环滚动

@property(nonatomic, assign, readwrite) CGFloat fadeoutAlpha; // [0.0 - 1.0]，渐隐的最终alpha值，默认1.0，表示不渐隐

@property(nonatomic, assign, readwrite) UIEdgeInsets holderLayoutInset; // 慎用，默认UIEdgeInsetsZero

@property(nonatomic, assign, readwrite) UIEdgeInsets contentLayoutInset; // 慎用，默认UIEdgeInsetsZero，重设会触发reloadData

@property(nonatomic, assign, readonly) BOOL unsafeLayout;

@end

#endif /* CJCarouselCollectionViewLayout_h */
