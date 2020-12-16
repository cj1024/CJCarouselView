//
//  CJCarouselViewController.h
//  CJCarouselView
//
//  Created by cj1024 on 2020/12/16.
//  Copyright © 2020 cj1024. All rights reserved.
//

@import UIKit;

@class CJCarouselView;

@interface CJCarouselViewController : UIViewController

@property(nonatomic, strong, readonly) CJCarouselView *carouselView;

- (void)updateDataSource:(NSArray <NSString *> *)imageUrls;

@end
