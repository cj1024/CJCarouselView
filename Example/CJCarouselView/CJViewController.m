//
//  CJViewController.m
//  CJCarouselView
//
//  Created by cj1024 on 12/03/2020.
//  Copyright (c) 2020 cj1024. All rights reserved.
//

#import "CJViewController.h"
#import <CJCarouselView/CJCarouselView.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import <Toast/Toast.h>

@interface CJViewController () <CJCarouselViewDataSource, CJCarouselViewDelegate>

@property(nonatomic, copy, readwrite) NSArray <NSString *> *imageUrls;
@property(nonatomic, strong, readwrite) CJCarouselView *carouselView;
@property(nonatomic, strong, readwrite) UILabel *ratioIndicator;

@end

@implementation CJViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.carouselView];
    [self.carouselView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(self.view.mas_width).multipliedBy(28. / 75.);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.view.mas_centerY);
    }];
    [self.view addSubview:self.ratioIndicator];
    [self.ratioIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view.mas_width);
        make.top.mas_equalTo(self.carouselView.mas_bottom).offset(10.f);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(30);
    }];
    [self viewControllerReloadData];
}

- (CJCarouselView *)carouselView {
    if (_carouselView == nil) {
        CJCarouselView *aView = [[CJCarouselView alloc] init];
        aView.dataSource = self;
        aView.delegate = self;
        aView.fadeoutAlpha = 0.2;
        aView.enableScrollOnSinglePage = YES;
        [aView smartUpdateLayoutInsetForPrePageExposed:30 nextPageExposed:30 pageGap:20];
        _carouselView = aView;
    }
    return _carouselView;
}

- (UILabel *)ratioIndicator {
    if (!_ratioIndicator) {
        UILabel *aView = [[UILabel alloc] init];
        aView.textAlignment = NSTextAlignmentCenter;
        aView.textColor = [UIColor darkTextColor];
        _ratioIndicator = aView;
    }
    return _ratioIndicator;
}

- (void)viewControllerReloadData {
    self.imageUrls = @[
        @"https://uploadbeta.com/api/pictures/random/?i=0",
        @"https://uploadbeta.com/api/pictures/random/?i=1",
        @"https://uploadbeta.com/api/pictures/random/?i=2",
        @"https://uploadbeta.com/api/pictures/random/?i=3",
        @"https://uploadbeta.com/api/pictures/random/?i=4",
        @"https://uploadbeta.com/api/pictures/random/?i=5",
    ];
    [self.carouselView reloadData];
}

- (NSUInteger)carouselViewNumberOfPages:(CJCarouselView *)pageView {
    return [self.imageUrls isKindOfClass:[NSArray class]] ? self.imageUrls.count : 0;
}

- (CJCarouselViewPage *)carouselView:(CJCarouselView *)pageView pageViewAtIndex:(NSUInteger)index reuseableView:(CJCarouselViewPage *)reuseableView {
    if (!reuseableView) {
        reuseableView = [[CJCarouselViewPage alloc] init];
        reuseableView.contentLabel.textColor = [UIColor whiteColor];
        reuseableView.contentLabel.textAlignment = NSTextAlignmentCenter;
        reuseableView.imageView.layer.cornerRadius = 8.f;
        [reuseableView.imageView setContentMode:UIViewContentModeScaleAspectFill];
        reuseableView.enableRippleHighlightStyle = YES;
    }
    [reuseableView.imageView sd_setImageWithURL:[NSURL URLWithString:self.imageUrls[index]]];
    reuseableView.contentLabel.text = [NSString stringWithFormat:@"%ld", index];
    return reuseableView;
}

- (void)carouselView:(CJCarouselView *)carouselView didScrollToPageIndexRatio:(CGFloat)pageIndexRatio {
    self.ratioIndicator.text = [NSString stringWithFormat:@"%.8f/%ld", pageIndexRatio + 1, carouselView.numberOfPages];
}

- (void)carouselView:(CJCarouselView *)carouselView didSelectPageAtIndex:(NSUInteger)index {
    [self.view makeToast:[NSString stringWithFormat:@"Selected Page %ld", index]];
}

@end
