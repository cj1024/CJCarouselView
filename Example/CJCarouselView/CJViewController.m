//
//  CJViewController.m
//  CJCarouselView
//
//  Created by cj1024 on 12/03/2020.
//  Copyright (c) 2020 cj1024. All rights reserved.
//

#import "CJViewController.h"
#import <CJCarouselView/CJCarouselView.h>
#import <CJCollectionViewAdapter/CJCollectionViewAdapter.h>
#import <SDWebImage/SDImageCache.h>
#import <FTIndicator/FTProgressIndicator.h>
#import "CJCollectionViewTestSectionData.h"
#import "CJCarouselViewController.h"

@interface CJViewController ()

@property(nonatomic, strong, readwrite) UICollectionView *collectionView;
@property(nonatomic, strong, readwrite) CJCollectionViewAdapter *adapter;

@end

@implementation CJViewController

- (void)dealloc {
    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
}

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
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = [UIColor systemBackgroundColor];
        self.collectionView.backgroundColor = [UIColor secondarySystemBackgroundColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
        self.collectionView.backgroundColor = [UIColor lightGrayColor];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clean Img Cache" style:(UIBarButtonItemStylePlain) target:self action:@selector(handleCleanImageCache:)];
    [self viewControllerReloadData];
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    [self layoutCollectionView];
}

- (void)layoutCollectionView {
    if (self.collectionView.superview != self.view) {
        [self.view addSubview:self.collectionView];
    }
    self.collectionView.frame = self.view.bounds;
    if (@available(iOS 11.0, *)) {
        self.adapter.stickyContentInset = [NSValue valueWithUIEdgeInsets:self.view.safeAreaInsets];
        self.collectionView.scrollIndicatorInsets = self.view.safeAreaInsets;
        self.collectionView.contentInset = self.view.safeAreaInsets;
    }
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionView *aView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.adapter.wrappedCollectionViewLayout];
        [self.adapter attachCollectionView:aView];
        aView.alwaysBounceVertical = YES;
        aView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        if (@available(iOS 11.0, *)) {
            aView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        if (@available(iOS 13.0, *)) {
            aView.automaticallyAdjustsScrollIndicatorInsets = NO;
        }
        _collectionView = aView;
    }
    return _collectionView;
}

- (CJCollectionViewAdapter *)adapter {
    if (_adapter == nil) {
        CJCollectionViewAdapter *adapter = [[CJCollectionViewAdapter alloc] init];
        _adapter = adapter;
    }
    return _adapter;
}

- (void)viewControllerReloadData {
    [self.adapter updateSections:@[
        [[CJCollectionViewTestSectionData alloc] initWithTitle:@"case 1"
                                                          desc:@"PrePageExposed:20\nNextPageExposed:20\nPageGap:10"
                                                   actionBlock:^{
            CJCarouselViewController *vc = [[CJCarouselViewController alloc] initWithNibName:nil bundle:nil];
            [vc.carouselView smartUpdateLayoutInsetForPrePageExposed:20 nextPageExposed:20 pageGap:10];
            [self.navigationController pushViewController:vc animated:YES];
        }],
        [[CJCollectionViewTestSectionData alloc] initWithTitle:@"case 2"
                                                              desc:@"PrePageExposed:0\nNextPageExposed:40\nPageGap:10"
                                                       actionBlock:^{
            CJCarouselViewController *vc = [[CJCarouselViewController alloc] initWithNibName:nil bundle:nil];
            [vc.carouselView smartUpdateLayoutInsetForPrePageExposed:0 nextPageExposed:40 pageGap:10];
            [self.navigationController pushViewController:vc animated:YES];
        }],
        [[CJCollectionViewTestSectionData alloc] initWithTitle:@"case 3"
                                                              desc:@"SpecialPagingMode:On\nPrePageExposed:30\nNextPageExposed:30\nPageGap:10"
                                                       actionBlock:^{
            CJCarouselViewController *vc = [[CJCarouselViewController alloc] initWithNibName:nil bundle:nil];
            vc.carouselView.loopingDisabled = YES;
            vc.carouselView.specialPagingMode = YES;
            vc.carouselView.specialPagingModeFirstPageOffsetAdjust = 30;
            vc.carouselView.specialPagingModeLastPageOffsetAdjust = -30;
            [vc.carouselView smartUpdateLayoutInsetForPrePageExposed:30 nextPageExposed:30 pageGap:10];
            [self.navigationController pushViewController:vc animated:YES];
        }],
        [[CJCollectionViewTestSectionData alloc] initWithTitle:@"case 4"
                                                              desc:@"PrePageExposed:0\nNextPageExposed:200\nPageGap:10"
                                                       actionBlock:^{
            CJCarouselViewController *vc = [[CJCarouselViewController alloc] initWithNibName:nil bundle:nil];
            [vc.carouselView smartUpdateLayoutInsetForPrePageExposed:0 nextPageExposed:200 pageGap:10];
            [self.navigationController pushViewController:vc animated:YES];
        }]
    ]];
}

- (void)handleCleanImageCache:(id)sender {
    [FTProgressIndicator showProgressWithMessage:@"cleaning…"];
    [[SDImageCache sharedImageCache] clearWithCacheType:SDImageCacheTypeAll
                                             completion:^{
        [FTProgressIndicator dismiss];
    }];
}

@end
