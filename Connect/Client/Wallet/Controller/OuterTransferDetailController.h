//
//  OuterTransferDetailController.h
//  Connect
//
//  Created by MoHuilin on 2016/11/15.
//  Copyright © 2016年 Connect.  All rights reserved.
//

#import "LMBaseViewController.h"
#import "Protofile.pbobjc.h"

@interface OuterTransferDetailController : LMBaseViewController

- (instancetype)initWithHashId:(NSString *)hashId;

- (instancetype)initWithExternalBillInfo:(ExternalBillingInfo *)billInfo;

@end
