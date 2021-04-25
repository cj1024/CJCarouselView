//
//  CJCarouselViewController.m
//  CJCarouselView
//
//  Created by cj1024 on 2020/12/16.
//  Copyright © 2020 cj1024. All rights reserved.
//

#import "CJCarouselViewController.h"
#import <CJCarouselView/CJCarouselView.h>
#import <CJCollectionViewAdapter/CJCollectionViewAdapter.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import <Toast/Toast.h>

@interface CJCarouselViewController () <CJCarouselViewDataSource, CJCarouselViewDelegate>

@property(nonatomic, copy, readwrite) NSArray <NSString *> *imageUrls;

@property(nonatomic, strong, readwrite) CJCarouselView *carouselView;
@property(nonatomic, strong, readwrite) UILabel *ratioIndicator;

@end

@implementation CJCarouselViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = @"Demo";
        self.hidesBottomBarWhenPushed = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }
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
        aView.autoScrollInterval = 3.0;
        _carouselView = aView;
    }
    return _carouselView;
}

- (UILabel *)ratioIndicator {
    if (!_ratioIndicator) {
        UILabel *aView = [[UILabel alloc] init];
        aView.textAlignment = NSTextAlignmentCenter;
        if (@available(iOS 13.0, *)) {
            aView.textColor = [UIColor labelColor];
        } else {
            aView.textColor = [UIColor darkTextColor];
        }
        _ratioIndicator = aView;
    }
    return _ratioIndicator;
}

- (void)viewControllerReloadData {
    long long timestamp = (long long)[NSDate date].timeIntervalSince1970;
    self.imageUrls = @[
        [NSString stringWithFormat:@"https://bing.ioliu.cn/v1/rand/?w=800&h=600&t=%lld&i=0", timestamp],
        [NSString stringWithFormat:@"https://bing.ioliu.cn/v1/rand/?w=800&h=600&t=%lld&i=1", timestamp],
        [NSString stringWithFormat:@"https://bing.ioliu.cn/v1/rand/?w=800&h=600&t=%lld&i=2", timestamp],
        [NSString stringWithFormat:@"https://bing.ioliu.cn/v1/rand/?w=800&h=600&t=%lld&i=3", timestamp],
        [NSString stringWithFormat:@"https://bing.ioliu.cn/v1/rand/?w=800&h=600&t=%lld&i=4", timestamp],
        [NSString stringWithFormat:@"https://bing.ioliu.cn/v1/rand/?w=800&h=600&t=%lld&i=5", timestamp]
    ];
    [self.carouselView reloadData];
    [self.carouselView startAutoScroll];
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
        reuseableView.imageView.layer.masksToBounds = YES;
        if (@available(iOS 13.0, *)) {
            reuseableView.imageView.backgroundColor = [[UIColor secondaryLabelColor] colorWithAlphaComponent:0.1];
        } else {
            reuseableView.imageView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
        }
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

- (void)updateDataSource:(NSArray <NSString *> *)imageUrls {
    self.imageUrls = imageUrls;
    [self.carouselView reloadData];
    [self.carouselView scrollToPageAtIndex:0 animated:NO];
}

@end
