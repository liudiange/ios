//
//  BaseDB.h
//  Connect
//
//  Created by MoHuilin on 16/7/29.
//  Copyright © 2016年 Connect.  All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMGlobal.h"
#import "NSString+Hash.h"
#import "NSDictionary+LMSafety.h"

@interface BaseDB : NSObject

- (void)executeRealmWithBlock:(void (^)())executeBlock;

- (void)executeRealmWithRealmBlock:(void (^)(RLMRealm *realm))executeBlock;

@end
