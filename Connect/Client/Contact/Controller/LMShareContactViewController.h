//
//  LMShareContactViewController.h
//  Connect
//
//  Created by bitmain on 2017/1/10.
//  Copyright © 2017年 Connect. All rights reserved.
//
#import "ReconmandChatListPage.h"
#import "BaseViewController.h"

@interface LMShareContactViewController : BaseViewController
//recommand contact

- (instancetype)initWithRetweetModel:(LMRerweetModel *)retweetModel;
- (instancetype)initWithAccount:(AccountInfo *)contact;
@end
