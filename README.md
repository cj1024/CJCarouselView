# CJCarouselView

[![CI Status](https://img.shields.io/travis/cj1024/CJCarouselView.svg?style=flat)](https://travis-ci.org/cj1024/CJCarouselView)
[![Version](https://img.shields.io/cocoapods/v/CJCarouselView.svg?style=flat)](https://cocoapods.org/pods/CJCarouselView)
[![License](https://img.shields.io/cocoapods/l/CJCarouselView.svg?style=flat)](https://cocoapods.org/pods/CJCarouselView)
[![Platform](https://img.shields.io/cocoapods/p/CJCarouselView.svg?style=flat)](https://cocoapods.org/pods/CJCarouselView)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

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

[![2020-12-04-1-17-26.gif](https://i.postimg.cc/XqTx1vkr/2020-12-04-1-17-26.gif)](https://postimg.cc/8fmhjN3G)

## Author

cj1024, jianchen1024@gmail.com

## License

CJCarouselView is available under the MIT license. See the LICENSE file for more info.
