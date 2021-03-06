//
//  InviteToGroupCell.m
//  Connect
//
//  Created by MoHuilin on 2016/12/29.
//  Copyright © 2016年 Connect. All rights reserved.
//

#import "InviteToGroupCell.h"

@interface InviteToGroupCell ()

@end

@implementation InviteToGroupCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        self.bubbleBackImageView.width = AUTO_WIDTH(425);
        self.bubbleBackImageView.height = AUTO_HEIGHT(151);

        self.contentSize = self.bubbleBackImageView.size;

        self.contactAvatarImageView = [[UIImageView alloc] init];
        self.contactAvatarImageView.image = GJCFQuickImage(@"default_user_avatar");
        self.contactAvatarImageView.width = AUTO_WIDTH(80);
        self.contactAvatarImageView.height = AUTO_WIDTH(80);
        self.contactAvatarImageView.left = 19;
        self.contactAvatarImageView.top = AUTO_HEIGHT(15);
        self.contactAvatarImageView.layer.cornerRadius = 5;
        self.contactAvatarImageView.layer.masksToBounds = YES;
        [self.bubbleBackImageView addSubview:self.contactAvatarImageView];


        self.contactNameView = [[UILabel alloc] init];
        self.contactNameView.numberOfLines = 2;
        self.contactNameView.height = self.contactAvatarImageView.height;
        self.contactNameView.left = self.contactAvatarImageView.right + 10;
        self.contactNameView.top = self.contactAvatarImageView.top;
        self.contactNameView.width = self.bubbleBackImageView.width - (self.contactAvatarImageView.right + AUTO_HEIGHT(15) * 2);
        self.contactNameView.backgroundColor = [UIColor clearColor];
        [self.bubbleBackImageView addSubview:self.contactNameView];

        self.subTipMessageView = [[GJCFCoreTextContentView alloc] init];
        self.subTipMessageView.width = AUTO_WIDTH(500);
        self.subTipMessageView.height = AUTO_HEIGHT(30);
        self.subTipMessageView.contentBaseWidth = self.subTipMessageView.width;
        self.subTipMessageView.contentBaseHeight = self.subTipMessageView.height;
        self.subTipMessageView.backgroundColor = [UIColor clearColor];
        [self.bubbleBackImageView addSubview:self.subTipMessageView];

        //tap
        UITapGestureRecognizer *tapR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnSelf)];
        tapR.numberOfTapsRequired = 1;
        [self.bubbleBackImageView addGestureRecognizer:tapR];

    }
    return self;
}

- (void)setContentModel:(GJGCChatContentBaseModel *)contentModel {
    if (!contentModel) {
        return;
    }
    [super setContentModel:contentModel];
    GJGCChatFriendContentModel *chatContentModel = (GJGCChatFriendContentModel *) contentModel;
    [self.contactAvatarImageView setPlaceholderImageWithAvatarUrl:chatContentModel.contactAvatar];
    self.contactNameView.attributedText = chatContentModel.contactName;

    self.subTipMessageView.contentAttributedString = chatContentModel.contactSubTipMessage;
    self.subTipMessageView.gjcf_size = [GJCFCoreTextContentView contentSuggestSizeWithAttributedString:chatContentModel.contactSubTipMessage forBaseContentSize:self.subTipMessageView.contentBaseSize];

    [self adjustContent];
    if (self.isFromSelf) {
        self.subTipMessageView.right = self.bubbleBackImageView.width - (BubbleLeftRightMargin + BubbleLeftRight);
        self.contactAvatarImageView.left = ImageIconInnerMargin;
    } else {
        self.subTipMessageView.right = self.bubbleBackImageView.width - BubbleLeftRightMargin;
        self.contactAvatarImageView.left = ImageIconInnerMargin + BubbleLeftRightMargin;
    }
    self.subTipMessageView.bottom = self.bubbleBackImageView.height - BubbleContentBottomMargin;
    self.contactNameView.left = self.contactAvatarImageView.right + ImageIconInnerMargin;
}

- (void)tapOnSelf {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatCellDidTapOnGroupInfoCard:)]) {
        [self.delegate chatCellDidTapOnGroupInfoCard:self];
    }
}

- (void)goToShowLongPressMenu:(UILongPressGestureRecognizer *)sender {
    [super goToShowLongPressMenu:sender];
    if (sender.state == UIGestureRecognizerStateBegan) {
        //
        [self becomeFirstResponder];
        UIMenuController *popMenu = [UIMenuController sharedMenuController];
        UIMenuItem *item1 = [[UIMenuItem alloc] initWithTitle:LMLocalizedString(@"Link Delete", nil) action:@selector(deleteMessage:)];
        NSArray *menuItems = @[item1];
        [popMenu setMenuItems:menuItems];
        [popMenu setArrowDirection:UIMenuControllerArrowDown];

        [popMenu setTargetRect:self.bubbleBackImageView.frame inView:self];
        [popMenu setMenuVisible:YES animated:YES];

    }
}

+ (CGFloat)cellHeightForContentModel:(GJGCChatContentBaseModel *)contentModel {
    CGSize nameSize = CGSizeZero;
    GJGCChatFriendContentModel *chatContentModel = (GJGCChatFriendContentModel *) contentModel;
    if (chatContentModel.isGroupChat && !chatContentModel.isFromSelf) {
        NSAttributedString *name = [[NSAttributedString alloc] initWithString:chatContentModel.senderName];
        nameSize = [GJCFCoreTextContentView contentSuggestSizeWithAttributedString:name forBaseContentSize:CGSizeMake(DEVICE_SIZE.width - AUTO_WIDTH(150), 25)];
        nameSize.height += 3;
    }

    return AUTO_HEIGHT(151) + BOTTOM_CELL_MARGIN + nameSize.height;
}

@end
