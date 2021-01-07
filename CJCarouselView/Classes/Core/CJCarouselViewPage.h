//
//  CJCarouselViewPage.h
//  CJCarouselView
//
//  Created by cj1024 on 2020/12/2.
//  Copyright © 2020 cj1024. All rights reserved.
//

#ifndef CJCarouselViewPage_h
#define CJCarouselViewPage_h

#import <UIKit/UIKit.h>

/**
 *  类似于UITableViewCell之于UITableView
 */
@interface CJCarouselViewPage : UIView

@property(nonatomic, strong, readonly) UIView *contentView;
@property(nonatomic, strong, readonly) UIView *backgroundView;
@property(nonatomic, strong, readonly) UIView *selectedBackgroundView;
@property(nonatomic, strong, readonly) UIImageView *imageView;
@property(nonatomic, strong, readonly) UILabel *contentLabel;

@property(nonatomic, strong, readwrite) UIView *customContentView; // 位于contentView上，会被默认拉伸为自身的尺寸

@property (nonatomic, getter=isPageViewHighlighted) BOOL pageViewHighlighted;

@property(nonatomic, assign, readwrite) BOOL enableRippleHighlightStyle; // 默认NO
@property(nonatomic, assign, readwrite) NSTimeInterval rippleDuration; // 默认0.3s
@property(nonatomic, strong, readwrite) UIColor *rippleColor; // 默认0.3黑度
@property(nonatomic, assign, readonly) CGPoint rippleTouchLocation; // 位置记录

- (void)prepareForReuse;

@end

#endif /* CJCarouselViewPage_h */
