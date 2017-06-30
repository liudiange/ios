//
//  LinkmanFriendCell.m
//  Connect
//
//  Created by MoHuilin on 16/5/23.
//  Copyright © 2016年 Connect.  All rights reserved.
//

#import "LinkmanFriendCell.h"
#import "YYImageCache.h"
#import "LMRamGroupInfo.h"

@interface LinkmanFriendCell ()

@end


@implementation LinkmanFriendCell

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setup];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

- (void)setup{
    self.nameLabel.font = [UIFont systemFontOfSize:FONT_SIZE(32)];
}

- (void)setData:(id)data{
    [super setData:data];
    if ([data isKindOfClass:[LMRamGroupInfo class]]) {
        LMRamGroupInfo *groupInfo = (LMRamGroupInfo *)data;
        _nameLabel.text = groupInfo.groupName;
        [self.avatarImageView setPlaceholderImageWithAvatarUrl:groupInfo.avatarUrl];
    } else if([data isKindOfClass:[AccountInfo class]]){
        AccountInfo *user = (AccountInfo *)data;
        if (user.remarks && user.remarks.length) {
            _nameLabel.text = user.remarks;
        } else{
            _nameLabel.text = user.username;
        }
        if (![user.pub_key isEqualToString:kSystemIdendifier]) {
            [self.avatarImageView setPlaceholderImageWithAvatarUrl:user.avatar];
        } else{
            self.avatarImageView.image = [UIImage imageNamed:user.avatar];
        }
    }
}
@end
