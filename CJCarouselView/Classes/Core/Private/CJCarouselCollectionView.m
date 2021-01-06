//
//  CJCarouselCollectionView.m
//  CJCarouselView
//
//  Created by cj1024 on 2020/12/2.
//  Copyright © 2020 cj1024. All rights reserved.
//

#import "CJCarouselCollectionView.h"

@interface CJCarouselCollectionViewGestureRecognizer : UIPinchGestureRecognizer

@end

@protocol CJCarouselCollectionViewGestureRecognizerDelegate <NSObject>

- (void)carousel_gestureRecognizerTouchBegan:(CJCarouselCollectionViewGestureRecognizer *)gestureRecognizer;
- (void)carousel_gestureRecognizerTouchEnded:(CJCarouselCollectionViewGestureRecognizer *)gestureRecognizer;
- (void)carousel_gestureRecognizerTouchCancelled:(CJCarouselCollectionViewGestureRecognizer *)gestureRecognizer;

@end

@interface CJCarouselCollectionViewGestureRecognizer ()

@property(nonatomic, weak, readwrite) id <CJCarouselCollectionViewGestureRecognizerDelegate> manipulationDelegate;

@end

@implementation CJCarouselCollectionViewGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if ([self.manipulationDelegate respondsToSelector:@selector(carousel_gestureRecognizerTouchBegan:)]) {
        [self.manipulationDelegate carousel_gestureRecognizerTouchBegan:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if ([self.manipulationDelegate respondsToSelector:@selector(carousel_gestureRecognizerTouchEnded:)]) {
        [self.manipulationDelegate carousel_gestureRecognizerTouchEnded:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    if ([self.manipulationDelegate respondsToSelector:@selector(carousel_gestureRecognizerTouchCancelled:)]) {
        [self.manipulationDelegate carousel_gestureRecognizerTouchCancelled:self];
    }
}

- (void)ignoreTouch:(UITouch*)touch forEvent:(UIEvent*)event {
    [super ignoreTouch:touch forEvent:event];
    if ([self.manipulationDelegate respondsToSelector:@selector(carousel_gestureRecognizerTouchCancelled:)]) {
        [self.manipulationDelegate carousel_gestureRecognizerTouchCancelled:self];
    }
}

@end

@interface CJCarouselCollectionView () <CJCarouselCollectionViewGestureRecognizerDelegate>

@end

@implementation CJCarouselCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        // 如果页面上存在诸如UIButton的控件，会导致CollectionView的TouchBegan等事件不会被触发，所以还要用GestureRecognizer来处理
        CJCarouselCollectionViewGestureRecognizer *gesture = [[CJCarouselCollectionViewGestureRecognizer alloc] initWithTarget:nil action:nil];
        gesture.manipulationDelegate = self;
        [self addGestureRecognizer:gesture];
        self.scrollsToTop = NO;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        if (@available(iOS 13.0, *)) {
            self.automaticallyAdjustsScrollIndicatorInsets = NO;
        }
    }
    return self;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if (!self.delaysContentTouches && ([view isKindOfClass:[UIControl class]] || [view isKindOfClass:[UIScrollView class]])) {
        return YES;
    }
    return [super touchesShouldCancelInContentView:view];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if ([self.manipulationDelegate respondsToSelector:@selector(carouselViewCollectionViewTouchBegan:)]) {
        [self.manipulationDelegate carouselViewCollectionViewTouchBegan:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if ([self.manipulationDelegate respondsToSelector:@selector(carouselViewCollectionViewTouchEnded:)]) {
        [self.manipulationDelegate carouselViewCollectionViewTouchEnded:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    if ([self.manipulationDelegate respondsToSelector:@selector(carouselViewCollectionViewTouchCancelled:)]) {
        [self.manipulationDelegate carouselViewCollectionViewTouchCancelled:self];
    }
}

- (void)carousel_gestureRecognizerTouchBegan:(CJCarouselCollectionViewGestureRecognizer *)gestureRecognizer {
    if ([self.manipulationDelegate respondsToSelector:@selector(carouselViewCollectionViewTouchBegan:)]) {
        [self.manipulationDelegate carouselViewCollectionViewTouchBegan:self];
    }
}

- (void)carousel_gestureRecognizerTouchEnded:(CJCarouselCollectionViewGestureRecognizer *)gestureRecognizer {
    if ([self.manipulationDelegate respondsToSelector:@selector(carouselViewCollectionViewTouchEnded:)]) {
        [self.manipulationDelegate carouselViewCollectionViewTouchEnded:self];
    }
}

- (void)carousel_gestureRecognizerTouchCancelled:(CJCarouselCollectionViewGestureRecognizer *)gestureRecognizer {
    if ([self.manipulationDelegate respondsToSelector:@selector(carouselViewCollectionViewTouchCancelled:)]) {
        [self.manipulationDelegate carouselViewCollectionViewTouchCancelled:self];
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    [super setScrollEnabled:scrollEnabled && self.draggingEnabled];
}

- (void)setDraggingEnabled:(BOOL)draggingEnabled {
    _draggingEnabled = draggingEnabled;
    self.scrollEnabled = draggingEnabled;
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    
}

- (void)carousel_setContentInset:(UIEdgeInsets)contentInset {
    [super setContentInset:contentInset];
}

@end
