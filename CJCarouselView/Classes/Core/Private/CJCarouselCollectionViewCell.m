//
//  CJCarouselCollectionViewCell.m
//  CJ
//
//  Created by cj1024 on 2020/12/2.
//  Copyright © 2020 cj1024. All rights reserved.
//

#import "CJCarouselCollectionViewCell.h"
#import "CJCarouselViewPage.h"

@implementation CJCarouselCollectionViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.pageView) {
        self.pageView.frame = UIEdgeInsetsInsetRect(self.contentView.bounds, self.contentLayoutInset);
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (UIEdgeInsetsEqualToEdgeInsets(self.contentLayoutInset, UIEdgeInsetsZero)) {
        return [super pointInside:point withEvent:event];
    }
    CGRect rect = UIEdgeInsetsInsetRect(self.bounds, self.contentLayoutInset);
    return CGRectContainsPoint(rect, point);
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if ([self.pageView isKindOfClass:[CJCarouselViewPage class]]) {
        [self.pageView setPageViewHighlighted:highlighted];
    }
}

- (void)setPageView:(CJCarouselViewPage *)pageView {
    if (_pageView != pageView) {
        if (_pageView) {
            [_pageView removeFromSuperview];
        }
        _pageView = pageView;
        if (_pageView) {
            _pageView.frame = self.bounds;
            [self.contentView addSubview:_pageView];
        }
    }
}

- (void)setContentLayoutInset:(UIEdgeInsets)contentLayoutInset {
    _contentLayoutInset = contentLayoutInset;
    [self setNeedsLayout];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    if ([self.pageView isKindOfClass:[CJCarouselViewPage class]]) {
        [self.pageView prepareForReuse];
    }
}

@end
