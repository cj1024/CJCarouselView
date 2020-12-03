//
//  CJCarouselViewPage.m
//  CJ
//
//  Created by cj1024 on 2020/12/2.
//  Copyright © 2020 cj1024. All rights reserved.
//

#import "CJCarouselViewPage.h"

@interface CJCarouselViewPage ()

@property(nonatomic, strong, readwrite) UIImageView *imageView;

@property(nonatomic, strong, readwrite) UIView *rippleHolder;
@property(nonatomic, assign, readwrite) CGPoint rippleTouchLocation;

@end

@implementation CJCarouselViewPage

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    {
        UIView *aView = [[UIView alloc] initWithFrame:CGRectZero];
        aView.backgroundColor = [UIColor clearColor];
        [self insertSubview:aView atIndex:0];
        _backgroundView = aView;
    }
    {
        UIView *aView = [[UIView alloc] initWithFrame:CGRectZero];
        aView.backgroundColor = [UIColor clearColor];
        aView.hidden = YES;
        [self insertSubview:aView atIndex:0];
        _selectedBackgroundView = aView;
    }
    {
        UIView *aView = [[UIView alloc] initWithFrame:CGRectZero];
        aView.backgroundColor = [UIColor clearColor];
        [self addSubview:aView];
        _contentView = aView;
    }
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.clipsToBounds = YES;
        [_contentView addSubview:imageView];
        _imageView = imageView;
    }
    {
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        contentLabel.backgroundColor = [UIColor clearColor];
        [_contentView addSubview:contentLabel];
        _contentLabel = contentLabel;
    }
    _enableRippleHighlightStyle = NO;
    _rippleDuration = 0.3;
    _rippleColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    self.backgroundColor = [UIColor clearColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundView.frame = self.bounds;
    self.selectedBackgroundView.frame = self.bounds;
    self.contentView.frame = self.bounds;
    self.imageView.frame = self.contentView.bounds;
    self.contentLabel.frame = self.contentView.bounds;
    if ([self.customContentView isKindOfClass:[UIView class]]) {
        self.customContentView.frame = self.bounds;
    }
    [self layoutAndroidStyleHighlightHolder];
}

- (void)layoutAndroidStyleHighlightHolder {
    if (self.rippleHolder == nil) {
        self.rippleHolder = [[UIView alloc] initWithFrame:self.contentView.bounds];
        self.rippleHolder.backgroundColor = [UIColor clearColor];
        self.rippleHolder.clipsToBounds = YES;
        self.rippleHolder.userInteractionEnabled = NO;
        [self.contentView addSubview:self.rippleHolder];
    }
    self.rippleHolder.frame = self.bounds;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch) {
        self.rippleTouchLocation = [touch locationInView:self];
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch) {
        self.rippleTouchLocation = [touch locationInView:self];
    }
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch) {
        self.rippleTouchLocation = [touch locationInView:self];
    }
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch) {
        self.rippleTouchLocation = [touch locationInView:self];
    }
    [super touchesCancelled:touches withEvent:event];
}

- (void)setPageViewHighlighted:(BOOL)pageViewHighlighted {
    _pageViewHighlighted = pageViewHighlighted;
    self.backgroundView.hidden = pageViewHighlighted;
    self.selectedBackgroundView.hidden = !pageViewHighlighted;
    if (pageViewHighlighted && self.enableRippleHighlightStyle) {
        CGFloat maxX = MAX(fabs(self.rippleTouchLocation.x), fabs(CGRectGetWidth(self.frame) - self.rippleTouchLocation.x));
        CGFloat maxY = MAX(fabs(self.rippleTouchLocation.y), fabs(CGRectGetHeight(self.frame) - self.rippleTouchLocation.y));
        UIBezierPath *path0 = [UIBezierPath bezierPathWithArcCenter:self.rippleTouchLocation
                                                             radius:10.0
                                                         startAngle:-M_PI
                                                           endAngle:M_PI
                                                          clockwise:YES];
        UIBezierPath *path1 = [UIBezierPath bezierPathWithArcCenter:self.rippleTouchLocation
                                                             radius:ceilf(sqrt(maxX * maxX + maxY * maxY))
                                                         startAngle:-M_PI
                                                           endAngle:M_PI
                                                          clockwise:YES];
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.path = path0.CGPath;
        layer.opacity = 1.0;
        layer.fillColor = self.rippleColor.CGColor;
        self.clipsToBounds = YES;
        [self.rippleHolder.layer insertSublayer:layer atIndex:0];
        CABasicAnimation *animationPath = [CABasicAnimation animation];
        [animationPath setKeyPath:@"path"];
        [animationPath setFromValue:(id)path0.CGPath];
        [animationPath setToValue:(id)path1.CGPath];
        CABasicAnimation *animationOpacity = [CABasicAnimation animation];
        [animationOpacity setKeyPath:@"opacity"];
        [animationOpacity setFromValue:@(1.0)];
        [animationOpacity setToValue:@(0.1)];
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[ animationPath, animationOpacity ];
        group.duration = self.rippleDuration;
        group.fillMode = kCAFillModeForwards;
        group.removedOnCompletion = NO;
        [layer addAnimation:group forKey:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [layer removeFromSuperlayer];
        });
    }
}

- (void)prepareForReuse {
    NSArray <CALayer *> *sublayers = [self.rippleHolder.layer.sublayers copy];
    [sublayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperlayer];
    }];
    [self setNeedsLayout];
}

- (void)setCustomContentView:(UIView *)customContentView {
    if ([_customContentView isKindOfClass:[UIView class]] && _customContentView != customContentView && _customContentView.superview == self) {
        [_customContentView removeFromSuperview];
    }
    [self insertSubview:customContentView aboveSubview:self.contentView];
    customContentView.frame = self.bounds;
    _customContentView = customContentView;
}

@end
