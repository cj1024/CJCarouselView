//
//  CJCarouselCollectionViewCell.h
//  CJ
//
//  Created by cj1024 on 2020/12/2.
//  Copyright © 2020 cj1024. All rights reserved.
//

#ifndef CJCarouselCollectionViewCell_h
#define CJCarouselCollectionViewCell_h

#import <UIKit/UIKit.h>

@class CJCarouselViewPage;

/**
 *  CJCarouselView中UICollectionView所使用的Cell
 */
@interface CJCarouselCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong, readwrite) CJCarouselViewPage *pageView;
@property(nonatomic, assign, readwrite) UIEdgeInsets contentLayoutInset; // 慎用，默认UIEdgeInsetsZero

@end

#endif /* CJCarouselCollectionViewCell_h */
