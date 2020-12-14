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

@property(nonatomic, strong, readwrite) CJCarouselView *carouselView1;
@property(nonatomic, strong, readwrite) UILabel *ratioIndicator1;

@property(nonatomic, strong, readwrite) CJCarouselView *carouselView2;
@property(nonatomic, strong, readwrite) UILabel *ratioIndicator2;

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
    [self.view addSubview:self.carouselView1];
    [self.carouselView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(self.view.mas_width).multipliedBy(28. / 75.);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.view.mas_centerY).multipliedBy(0.5);
    }];
    [self.view addSubview:self.ratioIndicator1];
    [self.ratioIndicator1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view.mas_width);
        make.top.mas_equalTo(self.carouselView1.mas_bottom).offset(10.f);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(30);
    }];
    [self.view addSubview:self.carouselView2];
    [self.carouselView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(self.view.mas_width).multipliedBy(28. / 75.);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.view.mas_centerY).multipliedBy(1.5);
    }];
    [self.view addSubview:self.ratioIndicator2];
    [self.ratioIndicator2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view.mas_width);
        make.top.mas_equalTo(self.carouselView2.mas_bottom).offset(10.f);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(30);
    }];
    [self viewControllerReloadData];
}

- (CJCarouselView *)carouselView1 {
    if (_carouselView1 == nil) {
        CJCarouselView *aView = [[CJCarouselView alloc] init];
        aView.dataSource = self;
        aView.delegate = self;
        aView.fadeoutAlpha = 0.2;
        aView.enableScrollOnSinglePage = YES;
        [aView smartUpdateLayoutInsetForPrePageExposed:20 nextPageExposed:20 pageGap:10];
        _carouselView1 = aView;
    }
    return _carouselView1;
}

- (UILabel *)ratioIndicator1 {
    if (!_ratioIndicator1) {
        UILabel *aView = [[UILabel alloc] init];
        aView.textAlignment = NSTextAlignmentCenter;
        aView.textColor = [UIColor darkTextColor];
        _ratioIndicator1 = aView;
    }
    return _ratioIndicator1;
}

- (CJCarouselView *)carouselView2 {
    if (_carouselView2 == nil) {
        CJCarouselView *aView = [[CJCarouselView alloc] init];
        aView.dataSource = self;
        aView.delegate = self;
        aView.enableScrollOnSinglePage = YES;
        aView.loopingDisabled = YES;
        aView.specialPagingMode = YES;
        [aView smartUpdateLayoutInsetForPrePageExposed:20 nextPageExposed:20 pageGap:20];
        aView.specialPagingModeFirstPageOffsetAdjust = 30;
        aView.specialPagingModeLastPageOffsetAdjust = -30;
        _carouselView2 = aView;
    }
    return _carouselView2;
}

- (UILabel *)ratioIndicator2 {
    if (!_ratioIndicator2) {
        UILabel *aView = [[UILabel alloc] init];
        aView.textAlignment = NSTextAlignmentCenter;
        aView.textColor = [UIColor darkTextColor];
        _ratioIndicator2 = aView;
    }
    return _ratioIndicator2;
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
    [self.carouselView1 reloadData];
    [self.carouselView2 reloadData];
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
    if (carouselView == self.carouselView2) {
        self.ratioIndicator2.text = [NSString stringWithFormat:@"%.8f/%ld", pageIndexRatio + 1, carouselView.numberOfPages];
    } else {
        self.ratioIndicator1.text = [NSString stringWithFormat:@"%.8f/%ld", pageIndexRatio + 1, carouselView.numberOfPages];
    }
}

- (void)carouselView:(CJCarouselView *)carouselView didSelectPageAtIndex:(NSUInteger)index {
    [self.view makeToast:[NSString stringWithFormat:@"Selected Page %ld", index]];
}

@end
