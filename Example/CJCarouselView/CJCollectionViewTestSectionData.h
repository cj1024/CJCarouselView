//
//  CJCollectionViewTestSectionData.h
//  CJCarouselView
//
//  Created by cj1024 on 2020/12/16.
//  Copyright © 2020 cj1024. All rights reserved.
//

#import <CJCollectionViewAdapter/CJCollectionViewSectionData.h>

@class CJCarouselViewController;

@interface CJCollectionViewTestSectionData : CJCollectionViewFlowLayoutSectionData

@property(nonatomic, copy, readonly) NSString *title;
@property(nonatomic, copy, readonly) NSString *desc;
@property(nonatomic, copy, readonly) dispatch_block_t actionBlock;

- (instancetype)initWithTitle:(NSString *)title desc:(NSString *)desc actionBlock:(dispatch_block_t)actionBlock;

@end
