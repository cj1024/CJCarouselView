//
//  CJCarouselView.h
//  CJCarouselView
//
//  Created by cj1024 on 2020/12/2.
//  Copyright © 2020 cj1024. All rights reserved.
//

#ifndef CJCarouselView_h
#define CJCarouselView_h

#import <UIKit/UIKit.h>
#import "CJCarouselViewPage.h"

@protocol CJCarouselViewDelegate;
@protocol CJCarouselViewDataSource;
@protocol CJCarouselViewScrollViewDelegateBridge;

/**
 *  Page布局方式
 */
typedef NS_ENUM(NSInteger, eCJCarouselViewLayoutDirection){
    /**
     *  水平滚动
     */
    eCJCarouselViewLayoutDirectionHorizontal,
    /**
     *  垂直滚动
     */
    eCJCarouselViewLayoutDirectionVertial
};

/**
 *  使用UICollectionView实现无限滚动的Page控件，实现逻辑概述可参见CJCarouselCollectionViewLayout.h
 */
@interface CJCarouselView : UIView

@property(nonatomic, strong, readonly) UICollectionView *collectionView;

@property(nonatomic, assign, readwrite) eCJCarouselViewLayoutDirection layoutDirection; // 布局方向
@property(nonatomic, assign, readwrite) BOOL loopingDisabled; // 是否禁用循环滚动
@property(nonatomic, assign, readwrite) BOOL bouncesDisabled; // 是否禁用边缘弹性（loopingDisabled时有效）
@property(nonatomic, assign, readwrite) BOOL enableScrollOnSinglePage; // 单页是否可滚动

@property(nonatomic, weak, readwrite) IBOutlet id <CJCarouselViewDelegate> delegate; // 类似UITableView的delegate
@property(nonatomic, weak, readwrite) IBOutlet id <CJCarouselViewDataSource> dataSource; // 类似UITableView的dataSource
@property(nonatomic, weak, readwrite) IBOutlet id <CJCarouselViewScrollViewDelegateBridge> scrollViewDelegateBridge; // 传递一些ScrollView的事件
@property(nonatomic, assign, readonly) NSUInteger currentPageIndex; // 当前显示的页面index，可以KVO
@property(nonatomic, assign, readonly) NSUInteger numberOfPages; // 页面数量

@property(nonatomic, assign, readwrite) CFTimeInterval autoScrollInterval; // 自动滚动时间间隔，默认并建议大于1s
@property(nonatomic, assign, readwrite) BOOL autoScrollDirectionReversed; // 自动滚动是否反向

@property(nonatomic, assign, readwrite) CGFloat fadeoutAlpha; // [0.0 - 1.0]，渐隐的最终alpha值，默认1.0，表示不渐隐

@property(nonatomic, assign, readwrite) BOOL draggingEnabled; // 默认YES，关闭手势造成的滚动，会在CollectionView的setScrollEnabled时综合起来判断

/**
 * 正常情况下每一页在被滚动到时在屏幕上的相对位置时一样的，但有时候需要在第一页和最后一页采取贴边的布局方式，这时可以开启此组选项
 * 仅loopingDisabled且numberOfPages > 1时有效
 * 触发后将取消scrollview默认的paging，因此体验会略有不同
 * 
 * specialPagingModeFirstPageOffsetAdjust请设置 >= 0，否则将处于弹性状态
 * specialPagingModeLastPageOffsetAdjust请设置 <= 0，否则将处于弹性状态
 */
@property(nonatomic, assign, readwrite) BOOL specialPagingMode;
@property(nonatomic, assign, readwrite) CGFloat specialPagingModeFirstPageOffsetAdjust;
@property(nonatomic, assign, readwrite) CGFloat specialPagingModeLastPageOffsetAdjust;

/**
 *  刷新数据源
 */
- (void)reloadData;

/**
 *  滚动页面到某一页
 *
 *  @param index    index
 *  @param animated 是否使用动效
 */
- (void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated;

/**
 *  滚动到下一页
 */
- (void)scrollToNextPage;

/**
 *  滚动到上一页
 */
- (void)scrollToPrePage;

/**
 *  开始自动滚动
 */
- (void)startAutoScroll;

/**
 *  停止自动滚动
 */
- (void)stopAutoScroll;

/**
 *  获取当前可见的页面
 */
- (NSArray <__kindof CJCarouselViewPage *> *)visiblePages;

/**
 *  获取当前可见的页面Index
 */
- (NSIndexSet *)visiblePageIndexes;

/**
 *  获取第N页视图（如果可见），由于循环滚动，可能出现多页
 */
- (NSArray <__kindof CJCarouselViewPage *> *)pageAtIndex:(NSUInteger)index;

@end

@interface CJCarouselView (LayoutInset)

@property(nonatomic, assign, readwrite) UIEdgeInsets holderLayoutInset; // 慎用，默认UIEdgeInsetsZero，重设会触发reloadData，建议用简便方法设置
@property(nonatomic, assign, readwrite) UIEdgeInsets contentLayoutInset; // 慎用，默认UIEdgeInsetsZero，重设会触发reloadData，建议用简便方法设置

/**
 *  简便的更新holderLayoutInset和contentLayoutInset
 *  layoutDirection更新后需要手动再调用一次
 *
 *  @param prePageExposed  上一页露出
 *  @param nextPageExposed 下一页露出
 *  @param pageGap         页间距
 */
- (void)smartUpdateLayoutInsetForPrePageExposed:(CGFloat)prePageExposed
                                nextPageExposed:(CGFloat)nextPageExposed
                                        pageGap:(CGFloat)pageGap;

@end

@protocol CJCarouselViewDelegate <NSObject>

@required

@optional

/**
 *  滚动到某一页
 *
 *  @param carouselView carouselView
 *  @param index        index
 */
- (void)carouselView:(CJCarouselView *)carouselView didScrollToPageAtIndex:(NSUInteger)index;

/**
 *  点击某一页
 *
 *  @param carouselView carouselView
 *  @param index        index
 */
- (void)carouselView:(CJCarouselView *)carouselView didSelectPageAtIndex:(NSUInteger)index;

/**
 *  滚动到下一页
 *
 *  @param carouselView carouselView
 */
- (void)carouselViewDidScrollToNextPage:(CJCarouselView *)carouselView;

/**
 *  滚动到上一页
 *
 *  @param carouselView carouselView
 */
- (void)carouselViewDidScrollToPrePage:(CJCarouselView *)carouselView;

/**
 *  滚动进度通知
 *
 *  @param carouselView          carouselView
 *  @param pageIndexRatio        滚动进度，比如0.5说明滚动到第一页与第二页之间，开looping时值可能范围为[-1 - numberOfPage]
 */
- (void)carouselView:(CJCarouselView *)carouselView didScrollToPageIndexRatio:(CGFloat)pageIndexRatio;

/**
 *  将要展示某一页
 *
 *  @param carouselView carouselView
 *  @param page         page
 *  @param index        index
 */
- (void)carouselView:(CJCarouselView *)carouselView willDisplayPage:(CJCarouselViewPage *)page atIndex:(NSUInteger)index;

/**
 *  结束展示某一页
 *
 *  @param carouselView carouselView
 *  @param page         page
 *  @param index        index
 */
- (void)carouselView:(CJCarouselView *)carouselView didEndDisplayPage:(CJCarouselViewPage *)page atIndex:(NSUInteger)index;

@end

@protocol CJCarouselViewDataSource <NSObject>

@required

/**
 *  CJCarouselView中的页数
 *
 *  @param carouselView carouselView
 *
 *  @return 页数
 */
- (NSUInteger)carouselViewNumberOfPages:(CJCarouselView *)carouselView;

/**
 *  CJCarouselView中某一页的View
 *
 *  @param carouselView  carouselView
 *  @param index         index
 *  @param reuseableView 重用view，可能为nil，可以直接作为结果return，也可以创建新的
 *
 *  @return 第index个页面的View，会被强制改为PageView的大小
 */
- (CJCarouselViewPage *)carouselView:(CJCarouselView *)carouselView pageViewAtIndex:(NSUInteger)index reuseableView:(CJCarouselViewPage *)reuseableView;

@optional

/**
 *  CJCarouselView自动滚动定时器RunLoopMode
 *
 *  @param carouselView  carouselView
 *
 *  @return 自动滚动定时器RunLoopMode，不实现默认NSDefaultRunLoopMode
 */
- (NSRunLoopMode)carouselViewAutoScrollRunLoopMode:(CJCarouselView *)carouselView;

@end

@protocol CJCarouselViewScrollViewDelegateBridge <NSObject>

@optional

- (void)scrollViewInCarouselViewDidScroll:(CJCarouselView *)carouselView;

- (void)scrollViewInCarouselViewWillBeginDragging:(CJCarouselView *)carouselView;

- (void)scrollViewInCarouselViewTouchBegan:(CJCarouselView *)carouselView;

- (void)scrollViewInCarouselViewTouchEnded:(CJCarouselView *)carouselView;

- (void)scrollViewInCarouselViewTouchCancelled:(CJCarouselView *)carouselView;

@end

#endif /* CJCarouselView_h */
