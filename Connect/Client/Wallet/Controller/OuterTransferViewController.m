//
//  OuterTransferViewController.m
//  Connect
//
//  Created by MoHuilin on 2016/11/14.
//  Copyright © 2016年 Connect.  All rights reserved.
//

#import "OuterTransferViewController.h"
#import "TransferInputView.h"
#import "OuterTransferDetailController.h"
#import "WallteNetWorkTool.h"
#import "OuterTransferHisPage.h"
#import "NetWorkOperationTool.h"
#import "NSString+Size.h"
#import "LMPayCheck.h"

@interface OuterTransferViewController ()

@property(nonatomic, strong) UILabel *userBalanceLabel;

@property(nonatomic, strong) TransferInputView *inputAmountView;
@property(nonatomic, strong) NSDecimalNumber *amount;
@property(nonatomic, strong) UIButton *outerTransferHisButton;
@property(nonatomic, strong) UILabel *titleLabel;

@end

@implementation OuterTransferViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LMLocalizedString(@"Wallet Transfer", nil);
    [self setWhitefBackArrowItem];
    [self creatView];
    [self.view addSubview:self.errorTipLabel];
    [self setRightBarButtonItem];
}

- (void)setRightBarButtonItem {
    self.outerTransferHisButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_outerTransferHisButton addTarget:self action:@selector(outerTransferHis) forControlEvents:UIControlEventTouchUpInside];
    _outerTransferHisButton.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE(28)];
    [_outerTransferHisButton setTitleColor:LMBasicGreen forState:UIControlStateNormal];
    self.outerTransferHisButton.width = [LMLocalizedString(@"Chat History", nil) widthWithFont:_outerTransferHisButton.titleLabel.font constrainedToHeight:AUTO_HEIGHT(49)];
    [_outerTransferHisButton setTitle:LMLocalizedString(@"Chat History", nil) forState:UIControlStateNormal];
    self.outerTransferHisButton.height = AUTO_HEIGHT(49);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.outerTransferHisButton];
}

- (void)creatView {

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE(36)];
    self.titleLabel.textColor = GJCFQuickHexColor(@"767A82");
    _titleLabel.text = LMLocalizedString(@"Wallet Transfer via other APP messges", nil);
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(AUTO_HEIGHT(40) + 64);
        make.centerX.equalTo(self.view);
        make.left.mas_equalTo(self.view).offset(10);
        make.right.mas_equalTo(self.view).offset(-10);
    }];


    __weak __typeof(&*self) weakSelf = self;
    TransferInputView *view = [[TransferInputView alloc] init];
    self.inputAmountView = view;
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(AUTO_HEIGHT(40));
        make.width.equalTo(self.view);
        make.height.mas_equalTo(AUTO_HEIGHT(334));
        make.left.equalTo(self.view);
    }];
    view.topTipString = LMLocalizedString(@"Wallet Amount", nil);
    view.resultBlock = ^(NSDecimalNumber *btcMoney, NSString *note) {
        weakSelf.amount = btcMoney;
        [weakSelf createTranscationWithMoney:btcMoney note:note];
    };
    view.lagelBlock = ^(BOOL enabled) {
        weakSelf.comfrimButton.enabled = enabled;
    };
    [[PayTool sharedInstance] getRateComplete:^(NSDecimalNumber *rate, NSError *error) {
        if (!error) {
            weakSelf.rate = rate.floatValue;
            [[MMAppSetting sharedSetting] saveRate:[rate floatValue]];
            [weakSelf.inputAmountView reloadWithRate:rate.floatValue];
        } else {
            [GCDQueue executeInMainQueue:^{
                [MBProgressHUD showToastwithText:LMLocalizedString(@"Wallet Get rate failed", nil) withType:ToastTypeFail showInView:weakSelf.view complete:nil];
            }];
        }
    }];


    self.userBalanceLabel = [[UILabel alloc] init];
    self.amount = [[NSDecimalNumber alloc] initWithLong:[[MMAppSetting sharedSetting] getBalance]];
    self.userBalanceLabel.text = [NSString stringWithFormat:LMLocalizedString(@"Wallet Balance", nil), [PayTool getBtcStringWithAmount:[self.amount integerValue]]];
    self.userBalanceLabel.textColor = [UIColor colorWithHexString:@"38425F"];
    self.userBalanceLabel.font = [UIFont systemFontOfSize:FONT_SIZE(28)];
    self.userBalanceLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.userBalanceLabel];
    // Get wallet information
    [[PayTool sharedInstance] getBlanceWithComplete:^(NSString *blance, UnspentAmount *unspentAmount, NSError *error) {
        [GCDQueue executeInMainQueue:^{
            weakSelf.userBalanceLabel.text = [NSString stringWithFormat:LMLocalizedString(@"Wallet Balance", nil), [PayTool getBtcStringWithAmount:unspentAmount.avaliableAmount]];
            weakSelf.amount = [[NSDecimalNumber alloc] initWithLong:unspentAmount.avaliableAmount];
        }];
    }];
    [_userBalanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.inputAmountView.mas_bottom).offset(AUTO_HEIGHT(60));
        make.centerX.equalTo(self.view);
    }];
    self.comfrimButton = [[ConnectButton alloc] initWithNormalTitle:LMLocalizedString(@"Wallet Transfer", nil) disableTitle:LMLocalizedString(@"Wallet Transfer", nil)];
    [self.comfrimButton addTarget:self action:@selector(tapConfrim) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.comfrimButton];
    [self.comfrimButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.userBalanceLabel.mas_bottom).offset(AUTO_HEIGHT(30));
        make.height.mas_equalTo(self.comfrimButton.height);
        make.width.mas_equalTo(self.comfrimButton.width);
    }];
}

- (void)outerTransferHis {
    OuterTransferHisPage *page = [[OuterTransferHisPage alloc] init];
    [self.navigationController pushViewController:page animated:YES];
}

- (void)tapConfrim {
    [self.inputAmountView executeBlock];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hidenKeyBoard];
}

- (void)createTranscationWithMoney:(NSDecimalNumber *)money note:(NSString *)note {
    __weak __typeof(&*self) weakSelf = self;
    // Whether the balance is sufficient
    if (([PayTool getPOW8Amount:money] + [[MMAppSetting sharedSetting] getTranferFee]) > self.blance) {
        [GCDQueue executeInMainQueue:^{
            [MBProgressHUD showToastwithText:LMLocalizedString(@"Wallet Insufficient balance", nil) withType:ToastTypeFail showInView:weakSelf.view complete:nil];
        }];
        self.comfrimButton.enabled = YES;
        return;
    }

    [GCDQueue executeInMainQueue:^{
        [self.view endEditing:YES];
        [MBProgressHUD showTransferLoadingViewtoView:self.view];
    }];

    [WallteNetWorkTool sendExternalBillWithSendAddress:[[LKUserCenter shareCenter] currentLoginUser].address privkey:[[LKUserCenter shareCenter] currentLoginUser].prikey fee:[[MMAppSetting sharedSetting] getTranferFee] money:[PayTool getPOW8Amount:money] tips:note complete:^(OrdinaryBilling *billing, UnspentOrderResponse *unspent, NSArray *toAddresses, NSError *error) {
        // New payment check method
        [LMPayCheck payCheck:billing withVc:weakSelf withTransferType:TransferTypeOuterTransfer unSpent:unspent withArray:toAddresses withMoney:0 withNote:nil withType:0 withRedPackage:0 withError:error];
    }];
}

- (void)checkChangeWithRawTrancationModel:(LMRawTransactionModel *)rawModel billing:(OrdinaryBilling *)billing {
    // Check for change
    __weak __typeof(&*self) weakSelf = self;
    rawModel = [LMUnspentCheckTool checkChangeDustWithRawTrancation:rawModel];
    switch (rawModel.unspentErrorType) {
        case UnspentErrorTypeChangeDust: {
            [MBProgressHUD hideHUDForView:self.view];
            NSString *tips = [NSString stringWithFormat:LMLocalizedString(@"Wallet Charge small calculate to the poundage", nil),
                                                        [PayTool getBtcStringWithAmount:rawModel.change]];
            [UIAlertController showAlertInViewController:self withTitle:LMLocalizedString(@"Set tip title", nil) message:tips cancelButtonTitle:LMLocalizedString(@"Common Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:@[LMLocalizedString(@"Common OK", nil)] tapBlock:^(UIAlertController *_Nonnull controller, UIAlertAction *_Nonnull action, NSInteger buttonIndex) {
                self.comfrimButton.enabled = YES;
                switch (buttonIndex) {
                    case 0: {
                        self.comfrimButton.enabled = YES;
                    }
                        break;
                    case 2: // click sure
                    {
                        LMRawTransactionModel *rawModelNew = [LMUnspentCheckTool createRawTransactionWithRawTrancation:rawModel addDustToFee:YES];
                        // pay money
                        [weakSelf outerTransferWithvtsArray:rawModelNew.vtsArray rawTransaction:rawModelNew.rawTrancation billing:billing];
                    }
                        break;
                    default:
                        break;
                }
            }];
        }
            break;
        case UnspentErrorTypeNoError: {
            LMRawTransactionModel *rawModelNew = [LMUnspentCheckTool createRawTransactionWithRawTrancation:rawModel addDustToFee:NO];
            // pay money
            [weakSelf outerTransferWithvtsArray:rawModelNew.vtsArray rawTransaction:rawModelNew.rawTrancation billing:billing];
        }
            break;
        default:
            break;
    }
}

- (NSDecimalNumber *)amount {
    if (!_amount) {
        _amount = [[NSDecimalNumber alloc] initWithDouble:MIN_TRANSFER_AMOUNT];
    }
    return _amount;
}

- (void)hidenKeyBoard {
    [self.inputAmountView hidenKeyBoard];
    [self.view endEditing:YES];
}

- (void)outerTransferWithvtsArray:(NSArray *)vtsArray rawTransaction:(NSString *)rawTransaction billing:(OrdinaryBilling *)billing {
    __weak __typeof(&*self) weakSelf = self;
    [[PayTool sharedInstance] payVerfifyFingerWithComplete:^(BOOL result, NSString *errorMsg) {
        if (result) {
            [MBProgressHUD showLoadingMessageToView:weakSelf.view];
            NSString *rawTx = [KeyHandle signRawTranscationWithTvsArray:vtsArray privkeys:@[[[LKUserCenter shareCenter] currentLoginUser].prikey] rawTranscation:rawTransaction];
            billing.rawTx = rawTx;
            [NetWorkOperationTool POSTWithUrlString:ExternalSendUrl postProtoData:billing.data complete:^(id response) {
                HttpResponse *hResponse = (HttpResponse *) response;
                [MBProgressHUD hideHUDForView:weakSelf.view];
                if (hResponse.code != successCode) {
                    return;
                }
                NSData *data = [ConnectTool decodeHttpResponse:hResponse];
                if (data) {
                    NSError *error = nil;
                    ExternalBillingInfo *billInfo = [ExternalBillingInfo parseFromData:data error:&error];

                    [GCDQueue executeInMainQueue:^{
                        [MBProgressHUD hideHUDForView:weakSelf.view];
                    }];
                    // update blance
                    [[PayTool sharedInstance] getBlanceWithComplete:^(NSString *blance, UnspentAmount *unspentAmount, NSError *error) {

                    }];
                    [GCDQueue executeInMainQueue:^{
                        OuterTransferDetailController *page = [[OuterTransferDetailController alloc] init];
                        page.billInfo = billInfo;
                        [weakSelf.navigationController pushViewController:page animated:YES];
                    }];
                }
            }                                  fail:^(NSError *error) {

            }];
        } else {
            if ([errorMsg isEqualToString:@"NO"]) {
                [GCDQueue executeInMainQueue:^{
                    [MBProgressHUD hideHUDForView:weakSelf.view];
                    weakSelf.comfrimButton.enabled = YES;
                }];
            } else {
                [InputPayPassView showInputPayPassWithComplete:^(InputPayPassView *passView, NSError *error, BOOL result) {
                    NSString *rawTx = [KeyHandle signRawTranscationWithTvsArray:vtsArray privkeys:@[[[LKUserCenter shareCenter] currentLoginUser].prikey] rawTranscation:rawTransaction];
                    billing.rawTx = rawTx;
                    [NetWorkOperationTool POSTWithUrlString:ExternalSendUrl postProtoData:billing.data complete:^(id response) {
                        HttpResponse *hResponse = (HttpResponse *) response;

                        if (hResponse.code != successCode) {
                            if (passView.requestCallBack) {
                                passView.requestCallBack([NSError errorWithDomain:hResponse.message code:hResponse.code userInfo:nil]);
                            }
                            return;
                        }
                        if (passView.requestCallBack) {
                            passView.requestCallBack(nil);
                        }
                        NSData *data = [ConnectTool decodeHttpResponse:hResponse];
                        if (data) {
                            NSError *error = nil;
                            ExternalBillingInfo *billInfo = [ExternalBillingInfo parseFromData:data error:&error];

                            [GCDQueue executeInMainQueue:^{
                                [MBProgressHUD hideHUDForView:weakSelf.view];
                            }];
                            // update blance
                            [[PayTool sharedInstance] getBlanceWithComplete:^(NSString *blance, UnspentAmount *unspentAmount, NSError *error) {
                            }];
                            [GCDQueue executeInMainQueue:^{
                                OuterTransferDetailController *page = [[OuterTransferDetailController alloc] init];
                                page.billInfo = billInfo;
                                [weakSelf.navigationController pushViewController:page animated:YES];
                            }];
                        }
                    }                                  fail:^(NSError *error) {
                        if (passView.requestCallBack) {
                            passView.requestCallBack(error);
                        }
                    }];
                }                              forgetPassBlock:^{
                    [GCDQueue executeInMainQueue:^{
                        [MBProgressHUD hideHUDForView:weakSelf.view];
                        weakSelf.comfrimButton.enabled = YES;
                        PaySetPage *page = [[PaySetPage alloc] initIsNeedPoptoRoot:YES];
                        [self.navigationController pushViewController:page animated:YES];
                    }];
                }                                   closeBlock:^{
                    [GCDQueue executeInMainQueue:^{
                        [MBProgressHUD hideHUDForView:weakSelf.view];
                        weakSelf.comfrimButton.enabled = YES;
                    }];
                }];
            }
        }
    }];
}

@end
