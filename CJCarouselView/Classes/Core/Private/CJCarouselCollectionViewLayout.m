//
//  CJCarouselCollectionViewLayout.m
//  CJ
//
//  Created by cj1024 on 2020/12/2.
//  Copyright © 2020 cj1024. All rights reserved.
//

#import "CJCarouselCollectionViewLayout.h"

@implementation CJCarouselCollectionViewLayout

- (CGSize)collectionViewContentSize {
    CGFloat width = self.collectionView.frame.size.width;
    CGFloat height= self.collectionView.frame.size.height;
    NSInteger count = [self.collectionView numberOfItemsInSection:0] + (self.loopingDisabled ? 0 : 2);
    switch (self.layoutDirection) {
        case eCJCarouselViewLayoutDirectionVertial:
            height *= count;
            break;
        default:
            width *= count;
            break;
    }
    return CGSizeMake(width, height);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    BOOL unsafeLayout = [self unsafeLayout];
    UICollectionViewLayoutAttributes* attributes = attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    NSInteger index = indexPath.item;
    NSInteger numberOfItems =  [self.collectionView numberOfItemsInSection:0];
    CGFloat pageWidth = self.collectionView.frame.size.width;
    CGFloat pageHeight = self.collectionView.frame.size.height;
    CGFloat pageSize, currentOffset;
    switch (self.layoutDirection) {
        case eCJCarouselViewLayoutDirectionVertial:
            pageSize = pageHeight;
            currentOffset = self.collectionView.contentOffset.y;
            break;
        default:
            pageSize = pageWidth;
            currentOffset = self.collectionView.contentOffset.x;
            break;
    }
    CGFloat alphaRatio = 0.0;
    CGFloat currentPageIndex = currentOffset / pageSize;
    CGFloat insetedCurrentPageIndexForPrePage = currentPageIndex;
    CGFloat insetedCurrentPageIndexForNextPage = currentPageIndex;
    if (self.loopingDisabled) {
        if (self.positionAdjustEnabled) {
            if (currentPageIndex < 1 && index <= 1) {
                if (fabs(pageSize - self.firstItemPositionAdjust) > DBL_EPSILON) {
                    currentPageIndex = (currentOffset - self.firstItemPositionAdjust) / (pageSize - self.firstItemPositionAdjust);
                }
            } else if (currentPageIndex > numberOfItems - 2 && index >= numberOfItems - 2) {
                if (fabs(pageSize + self.lastItemPositionAdjust) > DBL_EPSILON) {
                    currentPageIndex = (currentOffset - pageSize * (numberOfItems - 2)) / (pageSize + self.lastItemPositionAdjust) + (numberOfItems - 2);
                }
            }
        }
        switch (self.layoutDirection) {
            case eCJCarouselViewLayoutDirectionVertial:
                attributes.frame = CGRectMake(0, index * pageSize, pageWidth, pageHeight);
                break;
            default:
                attributes.frame = CGRectMake(index * pageSize, 0, pageWidth, pageHeight);
                break;
        }
        alphaRatio = fabs(index - currentPageIndex);
        if (alphaRatio > 1.0) {
            alphaRatio = 1.0;
        }
    } else {
        if (unsafeLayout) {
            switch (self.layoutDirection) {
                case eCJCarouselViewLayoutDirectionVertial:
                    insetedCurrentPageIndexForPrePage += (self.holderLayoutInset.bottom / pageSize);
                    insetedCurrentPageIndexForNextPage -= (self.holderLayoutInset.top / pageSize);
                    break;
                default:
                    insetedCurrentPageIndexForPrePage += (self.holderLayoutInset.right / pageSize);
                    insetedCurrentPageIndexForNextPage -= (self.holderLayoutInset.left / pageSize);
                    break;
            }
            if (numberOfItems > 1 && insetedCurrentPageIndexForPrePage <= 1 && index + 1 == numberOfItems) {
                // 把Page_n-1移动到Page_0之前
                switch (self.layoutDirection) {
                    case eCJCarouselViewLayoutDirectionVertial:
                        attributes.frame = CGRectMake(0, 0, pageWidth, pageHeight);
                        break;
                    default:
                        attributes.frame = CGRectMake(0, 0, pageWidth, pageHeight);
                        break;
                }
                alphaRatio = fabs(-1 - currentPageIndex + 1);
            } else if (numberOfItems > 1 && insetedCurrentPageIndexForPrePage <= 0 && index + 2 == numberOfItems) {
                // 把Page_n-2移动到Page_n-1之前
                switch (self.layoutDirection) {
                    case eCJCarouselViewLayoutDirectionVertial:
                        attributes.frame = CGRectMake(0, -pageSize, pageWidth, pageHeight);
                        break;
                    default:
                        attributes.frame = CGRectMake(-pageSize, 0, pageWidth, pageHeight);
                        break;
                }
                alphaRatio = fabs(-2 - currentPageIndex + 1);
            } else if (numberOfItems > 1 && insetedCurrentPageIndexForNextPage >= numberOfItems && index == 0) {
                // 把Page_0移动到Page_n-1之后
                switch (self.layoutDirection) {
                    case eCJCarouselViewLayoutDirectionVertial:
                        attributes.frame = CGRectMake(0, (numberOfItems + 1) * pageSize, pageWidth, pageHeight);
                        break;
                    default:
                        attributes.frame = CGRectMake((numberOfItems + 1) * pageSize, 0, pageWidth, pageHeight);
                        break;
                }
                alphaRatio = fabs(numberOfItems - currentPageIndex + 1);
            }  else if (numberOfItems > 1 && insetedCurrentPageIndexForNextPage >= numberOfItems + 1 && index == 1) {
                // 把Page_0移动到Page_n-1之后
                switch (self.layoutDirection) {
                    case eCJCarouselViewLayoutDirectionVertial:
                        attributes.frame = CGRectMake(0, (numberOfItems + 2) * pageSize, pageWidth, pageHeight);
                        break;
                    default:
                        attributes.frame = CGRectMake((numberOfItems + 2) * pageSize, 0, pageWidth, pageHeight);
                        break;
                }
                alphaRatio = fabs(numberOfItems + 1 - currentPageIndex + 1);
            } else {
                // 正常布局
                switch (self.layoutDirection) {
                    case eCJCarouselViewLayoutDirectionVertial:
                        attributes.frame = CGRectMake(0, (index + 1) * pageSize, pageWidth, pageHeight);
                        break;
                    default:
                        attributes.frame = CGRectMake((index + 1) * pageSize, 0, pageWidth, pageHeight);
                        break;
                }
                alphaRatio = fabs(index - currentPageIndex + 1);
            }
        } else {
            if (numberOfItems > 1 && currentPageIndex < 1 && index + 1 == numberOfItems) {
                // 把Page_n-1移动到Page_0之前
                switch (self.layoutDirection) {
                    case eCJCarouselViewLayoutDirectionVertial:
                        attributes.frame = CGRectMake(0, 0, pageWidth, pageHeight);
                        break;
                    default:
                        attributes.frame = CGRectMake(0, 0, pageWidth, pageHeight);
                        break;
                }
                alphaRatio = fabs(-1 - currentPageIndex + 1);
            } else if (numberOfItems > 1 && currentPageIndex > numberOfItems && index == 0) {
                // 把Page_0移动到Page_n-1之后
                switch (self.layoutDirection) {
                    case eCJCarouselViewLayoutDirectionVertial:
                        attributes.frame = CGRectMake(0, (numberOfItems + 1) * pageSize, pageWidth, pageHeight);
                        break;
                    default:
                        attributes.frame = CGRectMake((numberOfItems + 1) * pageSize, 0, pageWidth, pageHeight);
                        break;
                }
                alphaRatio = fabs(numberOfItems - currentPageIndex + 1);
            } else {
                // 正常布局
                switch (self.layoutDirection) {
                    case eCJCarouselViewLayoutDirectionVertial:
                        attributes.frame = CGRectMake(0, (index + 1) * pageSize, pageWidth, pageHeight);
                        break;
                    default:
                        attributes.frame = CGRectMake((index + 1) * pageSize, 0, pageWidth, pageHeight);
                        break;
                }
                alphaRatio = fabs(index - currentPageIndex + 1);
            }
        }
        if (alphaRatio > 1.0) {
            alphaRatio = 1.0;
        }
    }
    attributes.frame = UIEdgeInsetsInsetRect(attributes.frame, self.holderLayoutInset);
    attributes.alpha = 1.0 - (1.0 - self.fadeoutAlpha) * alphaRatio;
    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    // 由于rect参数目前未找到规律，故现在将全部layout信息都重新计算一遍，未来可以继续研究做到只更新需要的部分layout以优化性能
    NSInteger numberOfItems =  [self.collectionView numberOfItemsInSection:0];
    NSMutableArray* attributes = [NSMutableArray array];
    for (NSInteger i = 0; i < numberOfItems; i++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    return attributes;
}

- (void)setLayoutDirection:(eCJCarouselViewLayoutDirection)layoutDirection {
    _layoutDirection = layoutDirection;
    // 更新布局
    [self invalidateLayout];
}

- (void)setLoopingDisabled:(BOOL)loopingDisabled {
    _loopingDisabled = loopingDisabled;
    // 更新布局
    [self invalidateLayout];
}

- (void)setFadeoutAlpha:(CGFloat)fadeoutAlpha {
    _fadeoutAlpha = fadeoutAlpha;
    // 更新布局
    [self invalidateLayout];
}

- (void)setHolderLayoutInset:(UIEdgeInsets)holderLayoutInset {
    _holderLayoutInset = holderLayoutInset;
    // 更新布局
    [self invalidateLayout];
    [self.collectionView reloadData];
}

- (void)setContentLayoutInset:(UIEdgeInsets)contentLayoutInset {
    _contentLayoutInset = contentLayoutInset;
    // 更新布局
    [self invalidateLayout];
    [self.collectionView reloadData];
}

- (BOOL)unsafeLayout {
    return !UIEdgeInsetsEqualToEdgeInsets(self.holderLayoutInset, UIEdgeInsetsZero) && !self.loopingDisabled;
}

@end
