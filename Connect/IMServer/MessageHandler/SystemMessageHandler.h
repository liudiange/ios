//
//  SystemMessageHandler.h
//  Connect
//
//  Created by MoHuilin on 16/9/27.
//  Copyright © 2016年 Connect.  All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protofile.pbobjc.h"
#import "RecentChatDBManager.h"
#import "MessageDBManager.h"
#import "LMSocketHandleDelegate.h"

@interface SystemMessageHandler : NSObject

+ (SystemMessageHandler *)instance;

@property(nonatomic, strong) NSHashTable *getNewMessageObservers;

/**
 * add GetNewMessage Observer
 * @param oberver
 */
- (void)addGetNewMessageObserver:(id <MessageHandlerGetNewMessage>)oberver;

/**
 * remove GetNewMessage Observer
 * @param oberver
 */
- (void)removeGetNewMessageObserver:(id <MessageHandlerGetNewMessage>)oberver;

/**
 * handleMessage
 * @param sysMsg
 * @return
 */
- (BOOL)handleMessage:(MSMessage *)sysMsg;

/**
 * handleBatchMessages
 * @param sysMsgs
 * @return
 */
- (BOOL)handleBatchMessages:(NSArray *)sysMsgs;

@end
