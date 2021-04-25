# CJCarouselView

[![CI Status](https://img.shields.io/travis/cj1024/CJCarouselView.svg?style=flat)](https://travis-ci.org/cj1024/CJCarouselView)
[![Version](https://img.shields.io/cocoapods/v/CJCarouselView.svg?style=flat)](https://cocoapods.org/pods/CJCarouselView)
[![License](https://img.shields.io/cocoapods/l/CJCarouselView.svg?style=flat)](https://cocoapods.org/pods/CJCarouselView)
[![Platform](https://img.shields.io/cocoapods/p/CJCarouselView.svg?style=flat)](https://cocoapods.org/pods/CJCarouselView)

## Brief

* 支持真无限滚动（非传统设置超大ContentSize方式）
* 支持横向、纵向滚动
* 支持设置页间距，或者露出前后一页部分
* 支持简单的页切换渐隐渐显过渡
* 每一页都可定制
* 支持定时自动翻页
* 未集成图片管理、PageIndicator等第三方库，可按需自行集成其他库
* API设计类似UITableView
* 基于UICollectionView实现重用机制

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 8+

## Installation

CJCarouselView is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CJCarouselView'
```

## Basic Usage

1. Init

``` objective-c
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
}
```

1. Implement DataSource Methods

``` objective-c
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
```

1. Implement Delegate Methods If Necessary

``` objective-c
- (void)carouselView:(CJCarouselView *)carouselView didScrollToPageIndexRatio:(CGFloat)pageIndexRatio {
    self.ratioIndicator.text = [NSString stringWithFormat:@"%.8f/%ld", pageIndexRatio + 1, carouselView.numberOfPages];
}

- (void)carouselView:(CJCarouselView *)carouselView didSelectPageAtIndex:(NSUInteger)index {
    [self.view makeToast:[NSString stringWithFormat:@"Selected Page %ld", index]];
}
```

## ScreenShot

![ScreenShot1](https://ftp.bmp.ovh/imgs/2020/12/68011dc7fba03ec0.gif)

## Author

cj1024, jianchen1024@gmail.com

## License

CJCarouselView is available under the MIT license. See the LICENSE file for more info.
