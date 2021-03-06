//
//  GJGCRefreshFooterView.h
//  Connect
//
//  Created by KivenLin on 14-11-11.
//  Copyright (c) 2014年 Connect. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GJGCRefreshFooterView;

@protocol GJGCRefreshFooterViewDelegate <NSObject>

- (void)refreshFooterViewDidTriggerLoadMore:(GJGCRefreshFooterView *)footerView;

@end

@interface GJGCRefreshFooterView : UIView

@property(nonatomic, weak) id <GJGCRefreshFooterViewDelegate> delegate;

@property(nonatomic, copy) NSString *pullString;

@property(nonatomic) BOOL isLoading;

@property(nonatomic, copy) NSString *releaseString;

@property(nonatomic, copy) NSString *refreshString;


/**
 *  开始刷新
 */
- (void)startLoadingForScrollView:(UIScrollView *)scrollView;

/**
 *  停止刷新
 */
- (void)stopLoadingForScrollView:(UIScrollView *)scrollView;

- (void)resetFrameWithTableView:(UITableView *)table;

/**
 *  设置成聊天页面得样式
 */
- (void)setupChatFooterStyle;

#pragma mark - scrollView delegate method

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;


@end
