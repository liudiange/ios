//
//  LMRecentChat.m
//  Connect
//
//  Created by MoHuilin on 2017/6/19.
//  Copyright © 2017年 Connect. All rights reserved.
//

#import "LMRecentChat.h"

@implementation LMRecentChat

+ (NSString *)primaryKey{
    return @"identifier";
}

- (LMRecentChat *)initWithRecentModel:(RecentChatModel *)model{
    if (self = [super init]) {
        //package bradge model
        self.identifier = model.identifier;
        self.name = model.name;
        self.headUrl = model.headUrl;
        self.time = model.time;
        self.content = model.content;
        self.isTopChat = model.isTopChat;
        self.stranger = model.stranger;
        
        LMRecentChatSetting *setting = [[LMRecentChatSetting alloc] init];
        setting.snapChatDeleteTime = model.snapChatDeleteTime;
        setting.notifyStatus = model.notifyStatus;
        setting.identifier = model.identifier;
        self.chatSetting = setting;
        
        self.groupNoteMyself = model.groupNoteMyself;
        self.unReadCount = model.unReadCount;
        self.talkType = (int)model.talkType;
        self.draft = model.draft;
    }
    return self;
}

- (RecentChatModel *)recentModel{
    RecentChatModel *model = [RecentChatModel new];
    model.identifier = self.identifier;
    model.name = self.name;
    model.headUrl = self.headUrl;
    model.time = self.time;
    model.content = self.content;
    model.isTopChat = self.isTopChat;
    model.stranger = self.stranger;
    model.notifyStatus = self.chatSetting.notifyStatus;
    model.groupNoteMyself = self.groupNoteMyself;
    model.snapChatDeleteTime = self.chatSetting.snapChatDeleteTime;
    model.unReadCount = self.unReadCount;
    model.talkType = self.talkType;
    model.draft = self.draft;
    return model;
}

@end
