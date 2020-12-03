//
//  CJCarouselView.m
//  CJ
//
//  Created by cj1024 on 2020/12/2.
//  Copyright © 2020 cj1024. All rights reserved.
//

#import "CJCarouselView.h"
#import "CJCarouselCollectionView.h"
#import "CJCarouselCollectionViewCell.h"
#import "CJCarouselCollectionViewLayout.h"

#define kCJCarouselViewCellReuseableIdentifier @"CJCarouselViewUICollectionViewCellReuseableIdentifier"

typedef NS_ENUM(NSInteger, eCJCarouselViewPageOption) {
    eCJCarouselViewPageOptionNone,
    eCJCarouselViewPageOptionNext,
    eCJCarouselViewPageOptionPre
};

@interface CJCarouselView () <UICollectionViewDataSource, UICollectionViewDelegate, CJCarouselCollectionViewManipulationDelegate>

@property(nonatomic, assign, readwrite) NSUInteger currentPageIndex;

@property(nonatomic, strong, readwrite) NSMutableDictionary *reuseableViewsQueue; // 重用View队列
@property(nonatomic, strong, readwrite) CJCarouselCollectionView *collectionView; // 实际呈现使用UICollectionView
@property(nonatomic, strong, readwrite) CJCarouselCollectionViewLayout *collectionViewLayout; //实际呈现使用UICollectionViewLayout
@property(nonatomic, assign, readwrite) NSUInteger numberOfPages; // 页面数量记录
@property(nonatomic, strong, readwrite) NSTimer *timer; // 自动滚动定时器
@property(nonatomic, assign, readwrite) BOOL autoScroll; // 是否开启自动滚动

@end

@implementation CJCarouselView

#pragma mark -
#pragma mark Init & Layout

- (void)dealloc {
    if ([_collectionView isKindOfClass:[UICollectionView class]]) {
        _collectionView.delegate = nil;
    }
    if ([_timer isKindOfClass:[NSTimer class]]) {
        [_timer invalidate];
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _autoScrollInterval = 1.0;
    _reuseableViewsQueue = [NSMutableDictionary dictionary];
    _collectionViewLayout = [[CJCarouselCollectionViewLayout alloc] init];
    _collectionViewLayout.fadeoutAlpha = 1.0;
    _collectionViewLayout.layoutDirection = eCJCarouselViewLayoutDirectionHorizontal;
    _collectionView = [[CJCarouselCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_collectionViewLayout];
    _collectionView.clipsToBounds = NO;
    _collectionView.scrollsToTop = NO;
    [_collectionView registerClass:[CJCarouselCollectionViewCell class] forCellWithReuseIdentifier:kCJCarouselViewCellReuseableIdentifier];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.pagingEnabled = YES;
    _collectionView.draggingEnabled = YES;
    _collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.manipulationDelegate = self;
    [self addSubview:_collectionView];
    self.clipsToBounds = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(-self.holderLayoutInset.bottom, -self.holderLayoutInset.right, -self.holderLayoutInset.top, -self.holderLayoutInset.left));
    [self.collectionViewLayout invalidateLayout];
    [self scrollToPageAtIndex:self.currentPageIndex animated:NO];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (UIEdgeInsetsEqualToEdgeInsets(self.collectionViewLayout.holderLayoutInset, UIEdgeInsetsZero)) {
        return [super hitTest:point withEvent:event];
    }
    UIView *result = [super hitTest:point withEvent:event];
    if (result == nil || result == self) {
        for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
            UIView *temp = [cell hitTest:[self convertPoint:point toView:cell] withEvent:event];
            if (temp) {
                result = temp;
                break;
            }
        }
        if (result == nil || result == self) {
            result = [self.collectionView hitTest:[self convertPoint:point toView:self.collectionView] withEvent:event];
            if ((result == nil || result == self) && CGRectContainsPoint(self.bounds, point)) {
                result = self.collectionView;
            }
        }
    }
    return result;
}

#pragma mark -
#pragma mark UICollectionView DataSource & Delegate

- (NSUInteger)wrappedIndex:(NSUInteger)originalIndex {
    if ([self.collectionViewLayout unsafeLayout] && (self.numberOfPages > 0 && self.numberOfPages < 4) && originalIndex >= self.numberOfPages) {
        return originalIndex % self.numberOfPages;
    }
    return originalIndex;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.collectionViewLayout unsafeLayout] && (self.numberOfPages > 0 && self.numberOfPages < 4)) {
        NSUInteger numberOfPage = self.numberOfPages;
        do {
            numberOfPage *= 2;
        } while (numberOfPage < 4);
        return numberOfPage;
    }
    return self.numberOfPages;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CJCarouselCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCJCarouselViewCellReuseableIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        // 应该是不可能发生
        cell = [[CJCarouselCollectionViewCell alloc] init];
    }
    cell.contentLayoutInset = self.contentLayoutInset;
    cell.backgroundColor = [UIColor clearColor];
    if ([self.dataSource respondsToSelector:@selector(carouselView:pageViewAtIndex:reuseableView:)]) {
        CJCarouselViewPage *pageView = [self.dataSource carouselView:self pageViewAtIndex:[self wrappedIndex:indexPath.item] reuseableView:cell.pageView];
        cell.pageView = pageView;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if ([self.delegate respondsToSelector:@selector(carouselView:didSelectPageAtIndex:)]) {
        [self.delegate carouselView:self didSelectPageAtIndex:[self wrappedIndex:indexPath.item]];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(CJCarouselCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(carouselView:willDisplayPage:atIndex:)]) {
        [self.delegate carouselView:self willDisplayPage:cell.pageView atIndex:[self wrappedIndex:indexPath.item]];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(CJCarouselCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(carouselView:didEndDisplayPage:atIndex:)]) {
        [self.delegate carouselView:self didEndDisplayPage:cell.pageView atIndex:[self wrappedIndex:indexPath.item]];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        if ([self.scrollViewDelegateBridge respondsToSelector:@selector(scrollViewInCarouselViewDidScroll:)]) {
            [self.scrollViewDelegateBridge scrollViewInCarouselViewDidScroll:self];
        }
        CGFloat targetOffset = 0.0;
        CGFloat ITEM_SIZE = 0.0;
        switch (self.layoutDirection) {
            case eCJCarouselViewLayoutDirectionVertial: {
                targetOffset = self.collectionView.contentOffset.y;
                ITEM_SIZE = self.collectionView.frame.size.height;
                if (!self.loopingDisabled) {
                    // 无限循环
                    if (targetOffset <= 0) {
                        [self.collectionView setContentOffset:CGPointMake(0, targetOffset + ITEM_SIZE * self.numberOfPages)];
                    } else if (targetOffset >= ITEM_SIZE + ITEM_SIZE * self.numberOfPages - (self.collectionView.isDragging ? 0.0 : 1.0 / [UIScreen mainScreen].scale)) {
                        [self.collectionView setContentOffset:CGPointMake(0, targetOffset - ITEM_SIZE * self.numberOfPages)];
                    }
                }
            }
                break;
            default: {
                targetOffset = self.collectionView.contentOffset.x;
                ITEM_SIZE = self.collectionView.frame.size.width;
                if (!self.loopingDisabled) {
                    // 无限循环
                    if (targetOffset <= 0) {
                        [self.collectionView setContentOffset:CGPointMake(targetOffset + ITEM_SIZE * self.numberOfPages, 0)];
                    } else if (targetOffset >= ITEM_SIZE + ITEM_SIZE * self.numberOfPages - (self.collectionView.isDragging ? 0.0 : 1.0 / [UIScreen mainScreen].scale)) {
                        [self.collectionView setContentOffset:CGPointMake(targetOffset - ITEM_SIZE * self.numberOfPages, 0)];
                    }
                }
            }
                break;
        }
        if (ITEM_SIZE > 0) {
            CGFloat indexRatio = targetOffset / ITEM_SIZE;
            if (!self.loopingDisabled) {
                indexRatio -= 1.0;
                if (indexRatio < 0) {
                    indexRatio += self.numberOfPages;
                }
            }
            while (indexRatio >= self.numberOfPages) {
                indexRatio -= self.numberOfPages;
            }
            if ([self.delegate respondsToSelector:@selector(carouselView:didScrollToPageIndexRatio:)]) {
                [self.delegate carouselView:self didScrollToPageIndexRatio:indexRatio];
            }
        }
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    return NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        if ([self.scrollViewDelegateBridge respondsToSelector:@selector(scrollViewInCarouselViewWillBeginDragging:)]) {
            [self.scrollViewDelegateBridge scrollViewInCarouselViewWillBeginDragging:self];
        }
        if (self.timer) {
            [self.timer invalidate];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        [self setupTimer];
        NSInteger realIndex = 0;
        switch (self.layoutDirection) {
            case eCJCarouselViewLayoutDirectionVertial:
                realIndex = round(scrollView.contentOffset.y / scrollView.frame.size.height);
                break;
            default:
                realIndex = round(scrollView.contentOffset.x / scrollView.frame.size.width);
                break;
        }
        if (!self.loopingDisabled) {
            if (realIndex == 0) {
                realIndex = self.numberOfPages - 1;
            } else if (realIndex == self.numberOfPages + 1) {
                realIndex = 0;
            } else {
                realIndex = realIndex - 1;
            }
        }
        [self updateCurrentPageIndex:realIndex];
    }
}

#pragma mark -
#pragma mark CJCarouselCollectionViewManipulationDelegate

- (void)carouselViewCollectionViewTouchBegan:(CJCarouselCollectionView *)collectionView {
    if (collectionView == self.collectionView) {
        if (self.timer) {
            [self.timer invalidate];
        }
        if ([self.scrollViewDelegateBridge respondsToSelector:@selector(scrollViewInCarouselViewTouchBegan:)]) {
            [self.scrollViewDelegateBridge scrollViewInCarouselViewTouchBegan:self];
        }
    }
}

- (void)carouselViewCollectionViewTouchEnded:(CJCarouselCollectionView *)collectionView {
    if (collectionView == self.collectionView) {
        [self setupTimer];
        if ([self.scrollViewDelegateBridge respondsToSelector:@selector(scrollViewInCarouselViewTouchEnded:)]) {
            [self.scrollViewDelegateBridge scrollViewInCarouselViewTouchEnded:self];
        }
    }
}

- (void)carouselViewCollectionViewTouchCancelled:(CJCarouselCollectionView *)collectionView {
    if (collectionView == self.collectionView) {
        [self setupTimer];
        if ([self.scrollViewDelegateBridge respondsToSelector:@selector(scrollViewInCarouselViewTouchCancelled:)]) {
            [self.scrollViewDelegateBridge scrollViewInCarouselViewTouchCancelled:self];
        }
    }
}

#pragma mark -
#pragma mark Private Method

- (void)setupTimer {
    if (self.timer) {
        [self.timer invalidate];
    }
    if (self.autoScroll) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollInterval
                                                          target:self
                                                        selector:@selector(autoScrollTimerFired:)
                                                        userInfo:nil
                                                         repeats:YES];
    }
}

- (void)autoScrollTimerFired:(id)sender {
    if (self.autoScrollDirectionReversed) {
        [self scrollToPrePage];
    } else {
        [self scrollToNextPage];
    }
}

- (void)updateCurrentPageIndex:(NSUInteger)index {
    [self willChangeValueForKey:@"currentPageIndex"];
    if (self.currentPageIndex != index) {
        self.currentPageIndex = index;
        if ([self.delegate respondsToSelector:@selector(carouselView:didScrollToPageAtIndex:)]) {
            [self.delegate carouselView:self didScrollToPageAtIndex:index];
        }
    }
    [self didChangeValueForKey:@"currentPageIndex"];
}

- (void)didScrollToNextPage {
    if ([self.delegate respondsToSelector:@selector(carouselViewDidScrollToNextPage:)] ) {
        [self.delegate carouselViewDidScrollToNextPage:self];
    }
}

- (void)didScrollToPrePage {
    if ([self.delegate respondsToSelector:@selector(carouselViewDidScrollToPrePage:)] ) {
        [self.delegate carouselViewDidScrollToPrePage:self];
    }
}

- (void)scrollToOffset:(CGPoint)offset
              animated:(BOOL)animated
                 index:(NSUInteger)index
                option:(eCJCarouselViewPageOption)option {
    [self.collectionView setContentOffset:offset animated:animated];
    [self updateCurrentPageIndex:index];
    switch (option) {
        case eCJCarouselViewPageOptionNext:
            [self didScrollToNextPage];
            break;
        case eCJCarouselViewPageOptionPre:
            [self didScrollToPrePage];
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark Public Method

- (CJCarouselViewPage *)dequeueReusableViewWithIdentifier:(NSString *)identifier {
    if (identifier && self.reuseableViewsQueue) {
        if ([self.reuseableViewsQueue.allKeys containsObject:identifier]) {
            NSMutableArray *array = self.reuseableViewsQueue[identifier];
            if (array.count > 0) {
                CJCarouselViewPage *view = [array lastObject];
                [array removeLastObject];
                return view;
            }
        }
    }
    return nil;
}

- (void)reloadData {
    BOOL autoScroll = self.autoScroll;
    [self stopAutoScroll];
    if ([self.dataSource respondsToSelector:@selector(carouselViewNumberOfPages:)]) {
        self.numberOfPages = [self.dataSource carouselViewNumberOfPages:self];
    } else {
        self.numberOfPages = 0;
    }
    [self.collectionView setScrollEnabled:self.numberOfPages > 1 || self.enableScrollOnSinglePage];
    [self.collectionView reloadData];
    [self scrollToPageAtIndex:self.currentPageIndex animated:NO];
    if (autoScroll) {
        [self startAutoScroll];
    }
}

- (void)setEnableScrollOnSinglePage:(BOOL)enableScrollOnSinglePage {
    _enableScrollOnSinglePage = enableScrollOnSinglePage;
    [self.collectionView setScrollEnabled:self.numberOfPages > 1 || enableScrollOnSinglePage];
}

@dynamic layoutDirection;

- (eCJCarouselViewLayoutDirection)layoutDirection {
    return self.collectionViewLayout.layoutDirection;
}

- (void)setLayoutDirection:(eCJCarouselViewLayoutDirection)layoutDirection {
    self.collectionViewLayout.layoutDirection = layoutDirection;
}

@dynamic loopingDisabled;

- (BOOL)loopingDisabled {
    return self.collectionViewLayout.loopingDisabled;
}

- (void)setLoopingDisabled:(BOOL)loopingDisabled {
    self.collectionViewLayout.loopingDisabled = loopingDisabled;
}

@dynamic bouncesDisabled;

- (BOOL)bouncesDisabled {
    return !self.collectionView.bounces;
}

- (void)setBouncesDisabled:(BOOL)bouncesDisabled {
    self.collectionView.bounces = !bouncesDisabled;
}

- (void)setAutoScrollInterval:(CFTimeInterval)autoScrollInterval {
    if (self.timer) {
        [self.timer invalidate];
    }
    _autoScrollInterval = autoScrollInterval;
    [self setupTimer];
}

@dynamic fadeoutAlpha;

- (CGFloat)fadeoutAlpha {
    return self.collectionViewLayout.fadeoutAlpha;
}

- (void)setFadeoutAlpha:(CGFloat)fadeoutAlpha {
    CGFloat uniformedFadeoutAlpha = fadeoutAlpha;
    if (uniformedFadeoutAlpha < 0.0) {
        uniformedFadeoutAlpha = 0.0;
    } else if (uniformedFadeoutAlpha > 1.0) {
        uniformedFadeoutAlpha = 1.0;
    }
    self.collectionViewLayout.fadeoutAlpha = uniformedFadeoutAlpha;
}

@dynamic draggingEnabled;

- (BOOL)draggingEnabled {
    return _collectionView.draggingEnabled;
}

- (void)setDraggingEnabled:(BOOL)draggingEnabled {
    _collectionView.draggingEnabled = draggingEnabled;
}

- (void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated {
    if (self.numberOfPages == 0) {
        // 无数据时直接滚动
        [self scrollToOffset:CGPointZero animated:animated index:0 option:eCJCarouselViewPageOptionNone];
    } else {
        // 计算要移动到的位置的index（非实际index）
        if (index >= self.numberOfPages) {
            index = self.numberOfPages - 1;
        } else if (index < 0) {
            index = 0;
        }
        if (!self.loopingDisabled) {
            index++;
        }
        CGPoint offset;
        switch (self.layoutDirection) {
            case eCJCarouselViewLayoutDirectionVertial:
                offset = CGPointMake(0, index * self.collectionView.frame.size.height);
                break;
            default:
                offset = CGPointMake(index * self.collectionView.frame.size.width, 0);
                break;
        }
        // 恢复实际index
        if (!self.loopingDisabled) {
            index--;
        }
        [self scrollToOffset:offset animated:animated index:index option:eCJCarouselViewPageOptionNone];
    }
}

- (void)scrollToNextPage {
    if (self.numberOfPages > 1) {
        // 计算要移动到的位置的index（非实际index）
        NSInteger index = self.currentPageIndex + 1;
        if (self.loopingDisabled) {
            if (index >= self.numberOfPages) {
                index = 0;
            }
        } else {
            if (index > self.numberOfPages) {
                index = self.numberOfPages;
            }
            index++;
        }
        CGPoint offset;
        switch (self.layoutDirection) {
            case eCJCarouselViewLayoutDirectionVertial:
                offset = CGPointMake(0, index * self.collectionView.frame.size.height);
                break;
            default:
                offset = CGPointMake(index * self.collectionView.frame.size.width, 0);
                break;
        }
        // 恢复实际index
        if (!self.loopingDisabled) {
            index--;
            if (index == self.numberOfPages) {
                index = 0;
            }
        }
        [self scrollToOffset:offset animated:YES index:index option:eCJCarouselViewPageOptionNext];
    }
}

- (void)scrollToPrePage {
    if (self.numberOfPages > 1) {
        // 计算要移动到的位置的index（非实际index）
        NSInteger index = self.currentPageIndex - 1;
        if (self.loopingDisabled) {
            if (index <= -1) {
                index = self.numberOfPages -1;
            }
        } else {
            if (index < -1) {
                index = -1;
            }
            index++;
        }
        CGPoint offset;
        switch (self.layoutDirection) {
            case eCJCarouselViewLayoutDirectionVertial:
                offset = CGPointMake(0, index * self.collectionView.frame.size.height);
                break;
            default:
                offset = CGPointMake(index * self.collectionView.frame.size.width, 0);
                break;
        }
        // 恢复实际index
        if (!self.loopingDisabled) {
            index--;
            if (index == -1) {
                index = self.numberOfPages - 1;
            }
        }
        [self scrollToOffset:offset animated:YES index:index option:eCJCarouselViewPageOptionPre];
    }
}

- (void)startAutoScroll {
    self.autoScroll = YES;
    [self setupTimer];
}

- (void)stopAutoScroll {
    self.autoScroll = NO;
    if (self.timer) {
        [self.timer invalidate];
    }
}

@end

@implementation CJCarouselView (LayoutInset)

@dynamic holderLayoutInset;

- (UIEdgeInsets)holderLayoutInset {
    return self.collectionViewLayout.holderLayoutInset;
}

- (void)setHolderLayoutInset:(UIEdgeInsets)holderLayoutInset {
    self.collectionViewLayout.holderLayoutInset = holderLayoutInset;
    [self setNeedsLayout];
}

@dynamic contentLayoutInset;

- (UIEdgeInsets)contentLayoutInset {
    return self.collectionViewLayout.contentLayoutInset;
}

- (void)setContentLayoutInset:(UIEdgeInsets)contentLayoutInset {
    self.collectionViewLayout.contentLayoutInset = contentLayoutInset;
}

- (void)smartUpdateLayoutInsetForPrePageExposed:(CGFloat)prePageExposed
                                nextPageExposed:(CGFloat)nextPageExposed
                                        pageGap:(CGFloat)pageGap {
    CGFloat gap = pageGap * 0.5f;
    if (self.layoutDirection == eCJCarouselViewLayoutDirectionHorizontal) {
        self.holderLayoutInset = UIEdgeInsetsMake(0, -nextPageExposed - gap, 0, -prePageExposed - gap);
        self.contentLayoutInset = UIEdgeInsetsMake(0, nextPageExposed + pageGap, 0, prePageExposed + pageGap);
    } else {
        self.holderLayoutInset = UIEdgeInsetsMake(-nextPageExposed - gap, 0, -prePageExposed - gap, 0);
        self.contentLayoutInset = UIEdgeInsetsMake(nextPageExposed + pageGap, 0, prePageExposed + pageGap, 0);
    }
}

@end
