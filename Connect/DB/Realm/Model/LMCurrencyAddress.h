//
//  LMCurrencyAddress.h
//  Connect
//
//  Created by Connect on 2017/7/11.
//  Copyright © 2017年 Connect. All rights reserved.
//

#import "LMBaseModel.h"

@interface LMCurrencyAddress : LMBaseModel
@property (nonatomic,copy)NSString *currency;
@property (nonatomic,assign)int index;
@property (nonatomic,copy)NSString *address;
@property (nonatomic,assign)long long int balance;
@property (nonatomic,copy)NSString *label;
@property (nonatomic,assign)int status;
@end
RLM_ARRAY_TYPE(LMCurrencyAddress)