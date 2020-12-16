//
//  CJCollectionViewTestSectionData.m
//  CJCarouselView
//
//  Created by cj1024 on 2020/12/16.
//  Copyright © 2020 cj1024. All rights reserved.
//

#import "CJCollectionViewTestSectionData.h"
#import <CJCollectionViewAdapter/CJCollectionViewAdapterCell.h>

@implementation CJCollectionViewTestSectionData

- (instancetype)initWithTitle:(NSString *)title desc:(NSString *)desc actionBlock:(dispatch_block_t)actionBlock {
    self = [super init];
    if (self) {
        _title = title;
        _desc = desc;
        _actionBlock = actionBlock;
    }
    return self;
}

- (void)registerReuseIndentifer:(UICollectionView *)collectionView forOriginalSection:(NSUInteger)originalSection {
    [super registerReuseIndentifer:collectionView forOriginalSection:originalSection];
    [collectionView registerClass:[CJNormalContentCollectionViewCell class] forCellWithReuseIdentifier:@"CJCollectionViewTestSectionDataCell"];
}

- (BOOL)hasSectionStickyHeader:(UICollectionView *)collectionView forOriginalSection:(NSUInteger)originalSection {
    return YES;
}

- (CGFloat)sectionStickyHeaderHeight:(UICollectionView *)collectionView forOriginalSection:(NSUInteger)originalSection {
    return 16;
}

- (UIView *)sectionStickyHeader:(UICollectionView *)collectionView forOriginalSection:(NSUInteger)originalSection {
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:12];
    label.text = self.title;
    if (@available(iOS 13.0, *)) {
        label.backgroundColor = [UIColor labelColor];
        label.textColor = [UIColor systemBackgroundColor];
    } else {
        label.backgroundColor = [UIColor blackColor];
        label.textColor = [UIColor whiteColor];
    }
    return label;
}

- (NSUInteger)sectionItemCount:(UICollectionView *)collectionView forOriginalSection:(NSUInteger)originalSection {
    return 1;
}

- (CGFloat)sectionCellHeight:(UICollectionView *)collectionView forItem:(NSUInteger)item originalIndexPath:(NSIndexPath *)originalIndexPath {
    return 24 + [self.desc boundingRectWithSize:CGSizeMake(CGRectGetWidth(collectionView.frame) - 24, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:12]
    } context:nil].size.height;
}

- (__kindof UICollectionViewCell *)sectionCell:(UICollectionView *)collectionView forItem:(NSUInteger)item originalIndexPath:(NSIndexPath *)originalIndexPath {
    CJNormalContentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CJCollectionViewTestSectionDataCell" forIndexPath:originalIndexPath];
    if (@available(iOS 13.0, *)) {
        [cell updateAttributedSummary:[[NSAttributedString alloc] initWithString:self.desc ?: @"" attributes:@{
            NSForegroundColorAttributeName: [UIColor secondaryLabelColor],
            NSFontAttributeName: [UIFont systemFontOfSize:12]
        }]];
        cell.backgroundView.backgroundColor = [UIColor secondarySystemBackgroundColor];
        cell.selectedBackgroundView.backgroundColor = [[UIColor secondaryLabelColor] colorWithAlphaComponent:0.5];
    } else {
        [cell updateAttributedSummary:[[NSAttributedString alloc] initWithString:self.desc ?: @"" attributes:@{
            NSForegroundColorAttributeName: [UIColor darkGrayColor],
            NSFontAttributeName: [UIFont systemFontOfSize:12]
        }]];
        cell.backgroundView.backgroundColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
    }
    cell.enableRippleHighlightStyle = YES;
    [cell updateShowSummaryLabel:YES summaryLabelInset:UIEdgeInsetsMake(12, 12, 12, 12)];
    cell.bottomSeparatorInset = UIEdgeInsetsMake(0, 12, 0, 12);
    return cell;
}

- (void)sectionCellDidSelected:(UICollectionView *)collectionView forItem:(NSUInteger)item originalIndexPath:(NSIndexPath *)originalIndexPath {
    [collectionView deselectItemAtIndexPath:originalIndexPath animated:NO];
    if (self.actionBlock) {
        self.actionBlock();
    }
}

@end
