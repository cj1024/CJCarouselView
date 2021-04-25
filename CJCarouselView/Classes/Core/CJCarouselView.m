//
//  CJCarouselView.m
//  CJCarouselView
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

static NSUInteger const kCJCarouselViewMinItemsCountForUnsafeLayout = 4;

@interface CJCarouselViewPage (Internal)

@property(nonatomic, assign, readwrite) NSUInteger pageIndex;

@end

@interface CJCarouselView () <UICollectionViewDataSource, UICollectionViewDelegate, CJCarouselCollectionViewManipulationDelegate>

@property(nonatomic, assign, readwrite) NSUInteger currentPageIndex;

@property(nonatomic, strong, readwrite) NSMutableDictionary *reuseableViewsQueue; // 重用View队列
@property(nonatomic, strong, readwrite) CJCarouselCollectionView *collectionView; // 实际呈现使用UICollectionView
@property(nonatomic, strong, readwrite) CJCarouselCollectionViewLayout *collectionViewLayout; //实际呈现使用UICollectionViewLayout
@property(nonatomic, assign, readwrite) NSUInteger numberOfPages; // 页面数量记录
@property(nonatomic, strong, readwrite) NSTimer *timer; // 自动滚动定时器
@property(nonatomic, assign, readwrite) BOOL autoScroll; // 是否开启自动滚动
@property(nonatomic, assign, readonly) NSUInteger unsafeModeMinItemCount;

@property(nonatomic, copy, readwrite) dispatch_block_t scrollAnimationCompletionCallback;

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
    _unsafeModeMinItemCount = kCJCarouselViewMinItemsCountForUnsafeLayout;
    _autoScrollInterval = 1.0;
    _autoScrollAnimated = YES;
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

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if ([newWindow isKindOfClass:[UIWindow class]]) {
        [self setupTimer];
        [self scrollToPageAtIndex:self.currentPageIndex animated:NO];
    } else {
        if (self.timer) {
            [self.timer invalidate];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(-self.holderLayoutInset.bottom, -self.holderLayoutInset.right, -self.holderLayoutInset.top, -self.holderLayoutInset.left));
    [self.collectionViewLayout invalidateLayout];
    [self scrollToPageAtIndex:self.currentPageIndex animated:NO];
    [self updateUnsafeModeMinItemCount];
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
    if ([self.collectionViewLayout unsafeLayout] && (self.numberOfPages > 0 && self.numberOfPages < self.unsafeModeMinItemCount) && originalIndex >= self.numberOfPages) {
        return originalIndex % self.numberOfPages;
    }
    return originalIndex;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.collectionViewLayout unsafeLayout] && (self.numberOfPages > 0 && self.numberOfPages < self.unsafeModeMinItemCount)) {
        NSUInteger numberOfPage = self.numberOfPages;
        do {
            numberOfPage *= 2;
        } while (numberOfPage < self.unsafeModeMinItemCount);
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
        CJCarouselViewPage *reusePageView = cell.pageView;
        if ([reusePageView isKindOfClass:[CJCarouselViewPage class]]) {
            reusePageView.pageIndex = [self wrappedIndex:indexPath.item];
        }
        CJCarouselViewPage *pageView = [self.dataSource carouselView:self pageViewAtIndex:[self wrappedIndex:indexPath.item] reuseableView:reusePageView];
        pageView.pageIndex = [self wrappedIndex:indexPath.item];
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
                [self notifyScrollRatio:ITEM_SIZE offset:targetOffset];
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
                [self notifyScrollRatio:ITEM_SIZE offset:targetOffset];
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
        NSInteger realIndex = [self preferredPageIndexForOffset:scrollView.contentOffset];
        if (self.currentPageIndex != realIndex) {
            [self updateCurrentPageIndex:realIndex];
        }
        if (self.timer) {
            [self.timer invalidate];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        [self setupTimer];
        NSInteger realIndex = [self preferredPageIndexForOffset:scrollView.contentOffset];
        [self updateCurrentPageIndex:realIndex];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView == self.collectionView) {
        if ([self specialPagingModeEnabled]) {
            NSInteger targetIndex = [self preferredPageIndexForOffset:*targetContentOffset];
            if (targetIndex > self.currentPageIndex) {
                targetIndex = self.currentPageIndex + 1;
            } else if (targetIndex < self.currentPageIndex) {
                targetIndex = self.currentPageIndex - 1;
            }
            if (targetIndex == self.currentPageIndex) {
                CGFloat speed = 0;
                switch (self.layoutDirection) {
                    case eCJCarouselViewLayoutDirectionVertial:
                        speed = velocity.y;
                        break;
                    default:
                        speed = velocity.x;
                        break;
                }
                if (speed > 0.5) {
                    targetIndex = self.currentPageIndex + 1;
                } else if (speed < -0.5) {
                    targetIndex = self.currentPageIndex - 1;
                }
            }
            *targetContentOffset = [self contentOffsetForPage:targetIndex];
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self.scrollAnimationCompletionCallback) {
        self.scrollAnimationCompletionCallback();
    }
    self.scrollAnimationCompletionCallback = nil;
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
        self.timer = [NSTimer timerWithTimeInterval:self.autoScrollInterval
                                             target:self
                                           selector:@selector(autoScrollTimerFired:)
                                           userInfo:nil
                                            repeats:YES];
        NSRunLoopMode mode = NSDefaultRunLoopMode;
        if ([self.dataSource respondsToSelector:@selector(carouselViewAutoScrollRunLoopMode:)]) {
            mode = [self.dataSource carouselViewAutoScrollRunLoopMode:self];
        }
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:mode];
    }
}

- (void)autoScrollTimerFired:(id)sender {
    if (self.autoScrollDirectionReversed) {
        [self scrollToPrePage:self.autoScrollAnimated];
    } else {
        [self scrollToNextPage:self.autoScrollAnimated];
    }
}

- (void)updateCurrentPageIndex:(NSUInteger)index {
    if (self.currentPageIndex != index) {
        self.currentPageIndex = index;
        if ([self.delegate respondsToSelector:@selector(carouselView:didScrollToPageAtIndex:)]) {
            [self.delegate carouselView:self didScrollToPageAtIndex:index];
        }
    }
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
    if (animated && !CGPointEqualToPoint(self.collectionView.contentOffset, offset)) {
        __weak typeof(self) weakSelf = self;
        self.scrollAnimationCompletionCallback = ^{
            [weakSelf updateCurrentPageIndex:index];
            switch (option) {
                case eCJCarouselViewPageOptionNext:
                    [weakSelf didScrollToNextPage];
                    break;
                case eCJCarouselViewPageOptionPre:
                    [weakSelf didScrollToPrePage];
                    break;
                default:
                    break;
            }
        };
        [self.collectionView setContentOffset:offset animated:YES];
    } else {
        [self.collectionView setContentOffset:offset animated:NO];
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
}

- (void)notifyScrollRatio:(CGFloat)itemSize offset:(CGFloat)offset {
    if (itemSize > 0) {
        CGFloat indexRatio = offset / itemSize;
        if (self.loopingDisabled) {
            if (self.collectionViewLayout.positionAdjustEnabled) {
                    if (indexRatio < 1) {
                        if (fabs(itemSize - self.specialPagingModeFirstPageOffsetAdjust) > DBL_EPSILON) {
                            indexRatio = (offset - self.specialPagingModeFirstPageOffsetAdjust) / (itemSize - self.specialPagingModeFirstPageOffsetAdjust);
                        }
                    } else if (indexRatio > self.numberOfPages - 2) {
                        if (fabs(itemSize + self.specialPagingModeLastPageOffsetAdjust) > DBL_EPSILON) {
                            indexRatio = (offset - itemSize * (self.numberOfPages - 2)) / (itemSize + self.specialPagingModeLastPageOffsetAdjust) + (self.numberOfPages - 2);
                        }
                    }
            }
        } else {
            indexRatio -= 1.0;
            while (indexRatio >= self.numberOfPages) {
                indexRatio -= self.numberOfPages;
            }
        }
        if ([self.delegate respondsToSelector:@selector(carouselView:didScrollToPageIndexRatio:)]) {
            [self.delegate carouselView:self didScrollToPageIndexRatio:indexRatio];
        }
    }
}

- (void)updateUnsafeModeMinItemCount {
    NSUInteger oldCount = _unsafeModeMinItemCount;
    NSUInteger count = kCJCarouselViewMinItemsCountForUnsafeLayout;
    CGFloat size = 0;
    CGFloat itemSize = 0;
    switch (self.layoutDirection) {
        case eCJCarouselViewLayoutDirectionVertial: {
            size = CGRectGetHeight(self.bounds);
            itemSize = size;
            if ([self.collectionViewLayout unsafeLayout]) {
                itemSize = itemSize - self.contentLayoutInset.top - self.contentLayoutInset.bottom;
            }
        }
            break;
        default: {
            size = CGRectGetWidth(self.bounds);
            itemSize = size;
            if ([self.collectionViewLayout unsafeLayout]) {
                itemSize = itemSize - self.contentLayoutInset.left - self.contentLayoutInset.right;
            }
        }
            break;
    }
    itemSize = MAX(1, itemSize);
    count = ceil(size / itemSize) + 3;
    _unsafeModeMinItemCount = count;
    if (oldCount != count && [self.collectionViewLayout unsafeLayout]) {
        [self.collectionView reloadData];
    }
}

- (BOOL)specialPagingModeEnabled {
    return self.specialPagingMode && self.loopingDisabled;
}

- (void)updateRealPagingMode {
    self.collectionViewLayout.positionAdjustEnabled = [self specialPagingModeEnabled];
    self.collectionView.pagingEnabled = !self.collectionViewLayout.positionAdjustEnabled;
    if (!self.collectionView.pagingEnabled) {
        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    }
}

- (NSInteger)preferredPageIndexForOffset:(CGPoint)offset {
    NSInteger realIndex = 0;
    switch (self.layoutDirection) {
        case eCJCarouselViewLayoutDirectionVertial:
            realIndex = round(offset.y / self.collectionView.frame.size.height);
            break;
        default:
            realIndex = round(offset.x / self.collectionView.frame.size.width);
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
    return realIndex;
}

- (CGPoint)normalContentOffsetForPage:(NSInteger)pageIndex {
    if (self.numberOfPages == 0) {
        return CGPointZero;
    } else {
        // 计算要移动到的位置的index（非实际index）
        if (self.loopingDisabled) {
            // NSInteger -1 > NSUIntger 0，所以一定要先判 < 0
            if (pageIndex < 0) {
                pageIndex = 0;
            } else if (pageIndex >= self.numberOfPages) {
                pageIndex = self.numberOfPages - 1;
            }
        } else {
            if (pageIndex < -1) {
                pageIndex = -1;
            } else if (pageIndex > self.numberOfPages) {
                pageIndex = self.numberOfPages;
            }
            pageIndex++;
        }
        CGPoint offset;
        switch (self.layoutDirection) {
            case eCJCarouselViewLayoutDirectionVertial:
                offset = CGPointMake(0, pageIndex * self.collectionView.frame.size.height);
                break;
            default:
                offset = CGPointMake(pageIndex * self.collectionView.frame.size.width, 0);
                break;
        }
        return offset;
    }
}

- (CGPoint)contentOffsetForPage:(NSInteger)page {
    if ([self specialPagingModeEnabled]) {
        if (self.numberOfPages >= 2) {
            CGPoint offset = [self normalContentOffsetForPage:page];
            if (page <= 0) {
                switch (self.layoutDirection) {
                    case eCJCarouselViewLayoutDirectionVertial:
                        offset.y += self.specialPagingModeFirstPageOffsetAdjust;
                        break;
                    default:
                        offset.x += self.specialPagingModeFirstPageOffsetAdjust;
                        break;
                }
            } else if (page >= self.numberOfPages - 1) {
                switch (self.layoutDirection) {
                    case eCJCarouselViewLayoutDirectionVertial:
                        offset.y += self.specialPagingModeLastPageOffsetAdjust;
                        break;
                    default:
                        offset.x += self.specialPagingModeLastPageOffsetAdjust;
                        break;
                }
            }
            return offset;
        }
    }
    return [self normalContentOffsetForPage:page];
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
    [self updateRealPagingMode];
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

@dynamic specialPagingMode;

- (BOOL)specialPagingMode {
    return ((CJCarouselCollectionView *)self.collectionView).specialPagingMode;
}

- (void)setSpecialPagingMode:(BOOL)specialPagingMode {
    ((CJCarouselCollectionView *)self.collectionView).specialPagingMode = specialPagingMode;
    [self updateRealPagingMode];
}

@dynamic specialPagingModeFirstPageOffsetAdjust;

- (CGFloat)specialPagingModeFirstPageOffsetAdjust {
    return self.collectionViewLayout.firstItemPositionAdjust;
}

- (void)setSpecialPagingModeFirstPageOffsetAdjust:(CGFloat)specialPagingModeFirstPageOffsetAdjust {
    self.collectionViewLayout.firstItemPositionAdjust = specialPagingModeFirstPageOffsetAdjust;
}

@dynamic specialPagingModeLastPageOffsetAdjust;

- (CGFloat)specialPagingModeLastPageOffsetAdjust {
    return self.collectionViewLayout.lastItemPositionAdjust;
}

- (void)setSpecialPagingModeLastPageOffsetAdjust:(CGFloat)specialPagingModeLastPageOffsetAdjust {
    self.collectionViewLayout.lastItemPositionAdjust = specialPagingModeLastPageOffsetAdjust;
}

- (void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated {
    if (self.numberOfPages == 0) {
        // 无数据时直接滚动
        [self scrollToOffset:CGPointZero animated:animated index:0 option:eCJCarouselViewPageOptionNone];
    } else {
        [self scrollToOffset:[self contentOffsetForPage:index] animated:animated index:index option:eCJCarouselViewPageOptionNone];
    }
}

- (void)scrollToNextPage {
    [self scrollToNextPage:YES];
}

- (void)scrollToNextPage:(BOOL)animated {
    if (self.numberOfPages > 1) {
        // 计算要移动到的位置的index（非实际index）
        NSInteger index = self.currentPageIndex + 1;
        if (self.loopingDisabled) {
            if (index >= self.numberOfPages) {
                index = 0;
            }
            [self scrollToOffset:[self contentOffsetForPage:index] animated:animated index:index option:eCJCarouselViewPageOptionNext];
        } else {
            if (index > self.numberOfPages) {
                index = self.numberOfPages;
            }
            index++;
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
            index--;
            if (index == self.numberOfPages) {
                index = 0;
            }
            [self scrollToOffset:offset animated:animated index:index option:eCJCarouselViewPageOptionNext];
        }
    }
}

- (void)scrollToPrePage {
    [self scrollToPrePage:YES];
}

- (void)scrollToPrePage:(BOOL)animated {
    if (self.numberOfPages > 1) {
        // 计算要移动到的位置的index（非实际index）
        NSInteger index = self.currentPageIndex - 1;
        if (self.loopingDisabled) {
            if (index <= -1) {
                index = self.numberOfPages -1;
            }
            [self scrollToOffset:[self contentOffsetForPage:index] animated:animated index:index option:eCJCarouselViewPageOptionNext];
        } else {
            if (index < -1) {
                index = -1;
            }
            index++;
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
            index--;
            if (index == -1) {
                index = self.numberOfPages - 1;
            }
            [self scrollToOffset:offset animated:animated index:index option:eCJCarouselViewPageOptionPre];
        }
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

- (NSArray <__kindof CJCarouselViewPage *> *)visiblePages {
    NSMutableArray <__kindof CJCarouselViewPage *> *result = [NSMutableArray array];
    NSArray<__kindof UICollectionViewCell *> *visibleCells = [self.collectionView visibleCells];
    [visibleCells enumerateObjectsUsingBlock:^(CJCarouselCollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[CJCarouselCollectionViewCell class]] && [obj.pageView isKindOfClass:[CJCarouselViewPage class]]) {
            [result addObject:obj.pageView];
        }
    }];
    return result.copy;
}

- (NSIndexSet *)visiblePageIndexes {
    NSMutableIndexSet *result = [NSMutableIndexSet indexSet];
    NSArray <__kindof CJCarouselViewPage *> *visiblePages = [self visiblePages];
    [visiblePages enumerateObjectsUsingBlock:^(__kindof CJCarouselViewPage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [result addIndex:obj.pageIndex];
    }];
    return result.copy;
}

- (NSArray <__kindof CJCarouselViewPage *> *)pageAtIndex:(NSUInteger)index {
    NSMutableArray <__kindof CJCarouselViewPage *> *result = [NSMutableArray array];
    NSArray <__kindof CJCarouselViewPage *> *visiblePages = [self visiblePages];
    [visiblePages enumerateObjectsUsingBlock:^(__kindof CJCarouselViewPage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.pageIndex == index) {
            [result addObject:obj];
        }
    }];
    return result.copy;
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
    [self updateUnsafeModeMinItemCount];
}

@dynamic contentLayoutInset;

- (UIEdgeInsets)contentLayoutInset {
    return self.collectionViewLayout.contentLayoutInset;
}

- (void)setContentLayoutInset:(UIEdgeInsets)contentLayoutInset {
    self.collectionViewLayout.contentLayoutInset = contentLayoutInset;
    [self updateUnsafeModeMinItemCount];
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

@implementation CJCarouselViewPage (Internal)

@dynamic pageIndex;

@end
