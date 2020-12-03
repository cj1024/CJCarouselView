//
//  CJCarouselCollectionView.h
//  CJ
//
//  Created by cj1024 on 2020/12/2.
//  Copyright © 2020 cj1024. All rights reserved.
//

#ifndef CJCarouselCollectionView_h
#define CJCarouselCollectionView_h

#import <UIKit/UIKit.h>

@protocol CJCarouselCollectionViewManipulationDelegate;

/**
 *  为截取到touchBegan、touchEnded事件封装一层UICollectionView
 */
@interface CJCarouselCollectionView : UICollectionView

@property(nonatomic, weak, readwrite) id <CJCarouselCollectionViewManipulationDelegate> manipulationDelegate;
@property(nonatomic, assign, readwrite) BOOL draggingEnabled;

- (void)carousel_setContentInset:(UIEdgeInsets)contentInset; // 为防止vc没有禁用automaticallyAdjustsScrollViewInsets产生的问题，原setContentInset将变成空函数，调用此函数进行实际设置

@end

@protocol CJCarouselCollectionViewManipulationDelegate <NSObject>

@required

@optional

- (void)carouselViewCollectionViewTouchBegan:(CJCarouselCollectionView *)collectionView;

- (void)carouselViewCollectionViewTouchEnded:(CJCarouselCollectionView *)collectionView;

- (void)carouselViewCollectionViewTouchCancelled:(CJCarouselCollectionView *)collectionView;

@end

#endif /* CJCarouselCollectionView_h */
