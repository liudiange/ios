//
//  LMHandleScanResultManager.m
//  Connect
//
//  Created by MoHuilin on 2016/12/21.
//  Copyright © 2016年 Connect. All rights reserved.
//

#import "LMHandleScanResultManager.h"
#import "LMTranHisViewController.h"
#import "NetWorkOperationTool.h"
#import "UserDBManager.h"
#import "LMSetMoneyResultViewController.h"
#import "LMUnSetMoneyResultViewController.h"
#import "LMBitAddressViewController.h"
#import "NSURL+Param.h"
#import "HandleUrlManager.h"
#import "UserDetailPage.h"
#import "InviteUserPage.h"
#import "MainWalletPage.h"
#import "LMApplyJoinToGroupViewController.h"
#import "CommonClausePage.h"
#import "StringTool.h"

#define BitCoinStr @"bitcoin:"
#define AmountTip  @"?amount"

@interface LMHandleScanResultManager ()

@property(nonatomic, strong) UIViewController *controller;
@property(nonatomic, copy) NSString *resultContent;
@property(nonatomic, strong) NSDecimalNumber *money;

@end

@implementation LMHandleScanResultManager

CREATE_SHARED_MANAGER(LMHandleScanResultManager)

- (void)handleScanResult:(NSString *)resultStr controller:(UIViewController *)controller {
    self.controller = controller;
    if ([self isHttpNetWork:resultStr]) {  //network url
        [self loadWeb:resultStr];
    } else {
        if ([resultStr hasPrefix:@"group:"]) {
            NSArray *array = [[resultStr stringByReplacingOccurrencesOfString:@"group:" withString:@""] componentsSeparatedByString:@"/"];
            if (array.count == 4) {
                [self appleyToGroupWithQrarray:array hash:resultStr];
            }
        } else {
            if ([controller isKindOfClass:[MainWalletPage class]]) {
                [self handleWalletWithResult:resultStr];
            } else {
                [self search:resultStr];
            }
        }
    }
}

- (void)loadWeb:(NSString *)resultStr {
    CommonClausePage *page = [[CommonClausePage alloc] initWithUrl:resultStr];
    page.hidesBottomBarWhenPushed = YES;
    [self.controller.navigationController pushViewController:page animated:YES];

}

- (BOOL)isHttpNetWork:(NSString *)resultStr {
    NSString *pattern = [StringTool regHttp];
    NSRegularExpression *regException = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *resultArray = [regException matchesInString:resultStr options:NSMatchingReportCompletion range:NSMakeRange(0, resultStr.length)];
    if (resultArray.count > 0) {
        //host check
        NSURL *url = [NSURL URLWithString:resultStr];
        if (![url.host containsString:@"connect.im"] && ![url.host containsString:@"snowball.io"]) {
            return YES;
        }
    }
    return NO;
}

- (void)handleWalletWithResult:(NSString *)resultStr {
    /*
     "connectim://transfer?token="
     "connectim://packet?token="
     */
    if ([resultStr hasPrefix:@"http"]) {
        NSDictionary *parameters = [[NSURL URLWithString:resultStr] parameters];
        NSString *token = [parameters valueForKey:@"token"];
        if (!GJCFStringIsNull(token)) {
            if ([resultStr containsString:@"transfer"]) {
                NSString *urlString = [NSString stringWithFormat:@"connectim://transfer?token=%@", token];
                [HandleUrlManager handleOpenURL:[NSURL URLWithString:urlString]];
            } else if ([resultStr containsString:@"packet"]) {
                NSString *urlString = [NSString stringWithFormat:@"connectim://packet?token=%@", token];
                [HandleUrlManager handleOpenURL:[NSURL URLWithString:urlString]];
            } else if ([resultStr containsString:@"group"]) {
                NSString *urlString = [NSString stringWithFormat:@"connectim://group?token=%@", token];
                [HandleUrlManager handleOpenURL:[NSURL URLWithString:urlString]];
            }
        } else {
            [MBProgressHUD showToastwithText:LMLocalizedString(@"Parameter error", nil) withType:ToastTypeFail showInView:self.controller.view complete:nil];
        }
    } else {
        [MBProgressHUD showLoadingMessageToView:self.controller.view];
        if ([resultStr containsString:BitCoinStr] && [resultStr containsString:AmountTip]) {
            NSString *parm = [resultStr substringFromIndex:[resultStr rangeOfString:@"?"].location + 1];
            NSString *key = [parm componentsSeparatedByString:@"="].firstObject;
            NSString *amount = [parm substringFromIndex:(key.length + 1)];
            NSString *address = [resultStr substringWithRange:NSMakeRange([resultStr rangeOfString:@":"].location + 1, [resultStr rangeOfString:@"?"].location - [resultStr rangeOfString:@":"].location - 1)];
            self.resultContent = address;
            self.money = [NSDecimalNumber decimalNumberWithString:amount];
        } else {
            self.resultContent = resultStr;
            self.money = 0;

        }

        if (![KeyHandle checkAddress:self.resultContent]) {
            [MBProgressHUD hideHUDForView:self.controller.view];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LMLocalizedString(@"Wallet Result is not a bitcoin address", nil) message:LMLocalizedString(@"Login Please check that your input is correct", nil) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *unBoundAction = [UIAlertAction actionWithTitle:LMLocalizedString(@"Common OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {

            }];
            [alertController addAction:unBoundAction];
            [self.controller presentViewController:alertController animated:YES completion:nil];
        } else {
            if (self.money.doubleValue > 0) {
                [self GetMoneyUserInfo];
            } else {
                [self GetUserInfo];
            }
        }
    }
}

- (void)GetUserInfo {

    self.resultContent = [self.resultContent stringByReplacingOccurrencesOfString:BitCoinStr withString:@""];
    if (![KeyHandle checkAddress:self.resultContent]) {
        [MBProgressHUD hideHUDForView:self.controller.view];
        [GCDQueue executeInMainQueue:^{

            [MBProgressHUD showToastwithText:LMLocalizedString(@"Wallet Result is not a bitcoin address", nil) withType:ToastTypeFail showInView:self.controller.view complete:^{
                [self.controller.navigationController popViewControllerAnimated:YES];
            }];
        }];
        return;
    }
    AccountInfo *info = [[UserDBManager sharedManager] getUserByAddress:self.resultContent];
    if (info) {
        [MBProgressHUD hideHUDForView:self.controller.view];
        LMUnSetMoneyResultViewController *unsetVc = [[LMUnSetMoneyResultViewController alloc] init];
        unsetVc.info = info;
        [self.controller.navigationController pushViewController:unsetVc animated:YES];
    } else {
        [self baseQRcodeResultAddressSearchUserInformation:self.resultContent haveAmount:NO];
    }
}

- (void)GetMoneyUserInfo {

    if (![KeyHandle checkAddress:self.resultContent]) {
        [MBProgressHUD hideHUDForView:self.controller.view];
        [GCDQueue executeInMainQueue:^{

            [MBProgressHUD showToastwithText:LMLocalizedString(@"Wallet Result is not a bitcoin address", nil) withType:ToastTypeFail showInView:self.controller.view complete:^{
                [self.controller.navigationController popViewControllerAnimated:YES];
            }];
        }];
        return;
    }

    AccountInfo *info = [[UserDBManager sharedManager] getUserByAddress:self.resultContent];
    if (info) {
        [MBProgressHUD hideHUDForView:self.controller.view];
        LMSetMoneyResultViewController *unsetVc = [[LMSetMoneyResultViewController alloc] init];
        unsetVc.info = info;
        unsetVc.trasferAmount = self.money;
        [self.controller.navigationController pushViewController:unsetVc animated:YES];
    } else {
        [self baseQRcodeResultAddressSearchUserInformation:self.resultContent haveAmount:YES];
    }
}

#pragma mark --get user info by address

- (void)baseQRcodeResultAddressSearchUserInformation:(NSString *)address haveAmount:(BOOL)haveAmount {
    SearchUser *usrAddInfo = [[SearchUser alloc] init];
    usrAddInfo.criteria = address;
    [NetWorkOperationTool POSTWithUrlString:ContactUserSearchUrl postProtoData:usrAddInfo.data complete:^(id response) {
        [GCDQueue executeInMainQueue:^{
            [MBProgressHUD hideHUDForView:self.controller.view];
        }];
        NSError *error;
        HttpResponse *respon = (HttpResponse *) response;
        if (respon.code == 2404) {
            LMBitAddressViewController *page = [[LMBitAddressViewController alloc] init];
            page.address = address;
            if ([address containsString:BitCoinStr]) {
                page.address = [address stringByReplacingOccurrencesOfString:BitCoinStr withString:@""];
            }
            if (self.money.doubleValue > 0) {
                page.amountString = self.money.stringValue;
            }
            page.hidesBottomBarWhenPushed = YES;
            [self.controller.navigationController pushViewController:page animated:YES];
            return;
        }
        if (respon.code != successCode) {
            return;
        }

        NSData *data = [ConnectTool decodeHttpResponse:respon];
        if (data) {
            UserInfo *info = [[UserInfo alloc] initWithData:data error:&error];
            AccountInfo *accoutInfo = [[AccountInfo alloc] init];
            accoutInfo.username = info.username;
            accoutInfo.avatar = info.avatar;
            accoutInfo.pub_key = info.pubKey;
            accoutInfo.address = info.address;
            if (haveAmount) {
                //transfer to user with amount
                LMSetMoneyResultViewController *unsetVc = [[LMSetMoneyResultViewController alloc] init];
                unsetVc.info = accoutInfo;
                if ([self.money doubleValue] > 0) {
                    unsetVc.trasferAmount = self.money;
                }
                [self.controller.navigationController pushViewController:unsetVc animated:YES];
            } else {
                //transfer to user
                LMUnSetMoneyResultViewController *unsetVc = [[LMUnSetMoneyResultViewController alloc] init];
                unsetVc.info = accoutInfo;
                [self.controller.navigationController pushViewController:unsetVc animated:YES];
            }
            if (error) {

                [MBProgressHUD showToastwithText:LMLocalizedString(@"ErrorCode Error", nil) withType:ToastTypeFail showInView:self.controller.view complete:^{

                }];
            }
        }
    }                                  fail:^(NSError *error) {
        [GCDQueue executeInMainQueue:^{
            [MBProgressHUD hideHUDForView:self.controller.view];
            [MBProgressHUD showToastwithText:LMLocalizedString(@"Server Error", nil) withType:ToastTypeFail showInView:self.controller.view complete:^{

            }];
        }];
    }];
}


- (void)search:(NSString *)text {
    //Adapt btc.com
    NSString *keyWord = [text stringByReplacingOccurrencesOfString:BitCoinStr withString:@""];;
    if (![KeyHandle checkAddress:keyWord]) {
        if (![RegexKit vilidatePhoneNum:text region:nil]) {
            [self handleWalletWithResult:text];
            return;
        }
    } else {
        AccountInfo *localUser = [[UserDBManager sharedManager] getUserByAddress:text];
        if (localUser) {
            [GCDQueue executeInMainQueue:^{
                [self showDetailPageWithUser:localUser];
            }];
            return;
        }
    }
    [GCDQueue executeInMainQueue:^{
        [MBProgressHUD showMessage:LMLocalizedString(@"Common Loading", nil) toView:self.controller.view];
    }];
    SearchUser *search = [[SearchUser alloc] init];
    search.criteria = keyWord;
    [NetWorkOperationTool POSTWithUrlString:ContactUserSearchUrl postProtoData:search.data complete:^(id response) {
        HttpResponse *hResponse = (HttpResponse *) response;

        [GCDQueue executeInMainQueue:^{
            [MBProgressHUD hideHUDForView:self.controller.view];
        }];
        if (hResponse.code != successCode) {
            if ([text containsString:BitCoinStr] && [text containsString:AmountTip]) {
                NSString *parm = [text substringFromIndex:[text rangeOfString:@"?"].location + 1];
                NSString *key = [parm componentsSeparatedByString:@"="].firstObject;
                NSString *amount = [parm substringFromIndex:(key.length + 1)];
                NSString *address = [text substringWithRange:NSMakeRange([text rangeOfString:@":"].location + 1, [text rangeOfString:@"?"].location - [text rangeOfString:@":"].location - 1)];
                NSDecimalNumber *decimalAmount = [NSDecimalNumber decimalNumberWithString:amount];
                [GCDQueue executeInMainQueue:^{
                    if ([KeyHandle checkAddress:address]) {
                        LMBitAddressViewController *page = [[LMBitAddressViewController alloc] init];
                        page.address = [text stringByReplacingOccurrencesOfString:BitCoinStr withString:@""];
                        if (decimalAmount.doubleValue > 0) {
                            page.amountString = [decimalAmount stringValue];
                        }
                        page.hidesBottomBarWhenPushed = YES;
                        [self.controller.navigationController pushViewController:page animated:YES];
                        return;
                    }
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LMLocalizedString(@"Wallet No match user", nil) message:LMLocalizedString(@"Login Please check that your input is correct", nil) preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *unBoundAction = [UIAlertAction actionWithTitle:LMLocalizedString(@"Common OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {

                    }];
                    [alertController addAction:unBoundAction];
                    [self.controller presentViewController:alertController animated:YES completion:nil];
                }];
            } else {
                if ([KeyHandle checkAddress:keyWord]) {
                    [self handleWalletWithResult:text];
                }
            }
            return;
        }

        NSData *data = [ConnectTool decodeHttpResponse:hResponse];
        if (data) {
            UserInfo *user = [UserInfo parseFromData:data error:nil];
            DDLogInfo(@"%@", user);
            [GCDQueue executeInMainQueue:^{
                AccountInfo *userInfo = [[AccountInfo alloc] init];
                userInfo.username = user.username;
                userInfo.avatar = user.avatar;
                userInfo.pub_key = user.pubKey;
                userInfo.address = user.address;
                userInfo.stranger = YES;
                [self showDetailPageWithUser:userInfo];
            }];
        }
    }                                  fail:^(NSError *error) {
        [GCDQueue executeInMainQueue:^{
            [MBProgressHUD hideHUDForView:self.controller.view];
            [MBProgressHUD showToastwithText:LMLocalizedString(@"Server Error", nil) withType:ToastTypeFail showInView:self.controller.view complete:^{

            }];
        }];
    }];
}

- (void)showDetailPageWithUser:(AccountInfo *)userInfo {
    if (!userInfo.stranger) {
        UserDetailPage *page = [[UserDetailPage alloc] initWithUser:userInfo];
        page.hidesBottomBarWhenPushed = YES;
        [self.controller.navigationController pushViewController:page animated:YES];

    } else {
        InviteUserPage *page = [[InviteUserPage alloc] initWithUser:userInfo];
        page.sourceType = UserSourceTypeQrcode;
        page.hidesBottomBarWhenPushed = YES;
        [self.controller.navigationController pushViewController:page animated:YES];
    }
}

- (void)appleyToGroupWithQrarray:(NSArray *)array hash:(NSString *)resultStr {
    LMApplyJoinToGroupViewController *page = [[LMApplyJoinToGroupViewController alloc]
            initWithGroupIdentifier:[array objectAtIndex:0] hashP:resultStr];
    page.hidesBottomBarWhenPushed = YES;
    [self.controller.navigationController pushViewController:page animated:YES];
}

@end
