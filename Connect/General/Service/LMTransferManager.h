//
//  LMTransferManager.h
//  Connect
//
//  Created by MoHuilin on 2017/7/11.
//  Copyright © 2017年 Connect. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Wallet.pbobjc.h"
#import "Protofile.pbobjc.h"


typedef NS_ENUM(NSInteger ,LuckypackageTypeCategory) {
    LuckypackageTypeCategoryGroup = 0,
    LuckypackageTypeCategoryOuterUrl,
};

typedef NS_ENUM(NSInteger ,TransactionType) {
    TransactionTypeLuckypackage = 0,
    TransactionTypeURLLuckypackage,
    TransactionTypeSigleTransfer,
    TransactionTypeMutiAddressTransfer,
    TransactionTypeURLTransfer,
    TransactionTypePayReceipt,
    TransactionTypePayCrowding
};

typedef NS_ENUM(NSInteger ,CurrencyType) {
    CurrencyTypeBTC = 0,
    CurrencyTypeLTC,
    CurrencyTypeETH,
};

typedef void (^CompleteWithDataBlock)(id data,NSError *error);

@interface LMTransferManager : NSObject

+ (instancetype)sharedManager;

- (void)sendUrlTransferAmount:(NSInteger)amount fee:(NSInteger)fee fromAddresses:(NSArray *)fromAddresses currency:(CurrencyType)currency complete:(CompleteWithDataBlock)complete;

- (void)sendLuckyPackageWithReciverIdentifier:(NSString *)identifier size:(int)size amount:(NSInteger)amount fee:(NSInteger)fee luckyPackageType:(int)type category:(LuckypackageTypeCategory)category tips:(NSString *)tips fromAddresses:(NSArray *)fromAddresses currency:(CurrencyType)currency complete:(CompleteWithDataBlock)complete;


- (void)sendCrowdfuningToGroup:(NSString *)groupIdentifier amount:(NSInteger)amount size:(int)size tips:(NSString *)tips complete:(void (^)(NSString *hashId,NSError *error))complete;


- (void)sendReceiptToPayer:(NSString *)payer amount:(NSInteger)amount tips:(NSString *)tips complete:(void (^)(NSString *hashId,NSError *error))complete;

- (void)payCrowdfuningReceiptWithHashId:(NSString *)hashId type:(TransactionType)type fromAddresses:(NSArray *)fromAddresses currency:(CurrencyType)currency complete:(CompleteWithDataBlock)complete;

/**
 * transger from addresses to addresses
 * @param addresses
 * @param fee
 * @param toAddresses
 * @param perAddressAmount
 * @param tips
 * @param complete
 */
- (void)transferFromAddresses:(NSArray *)fromAddresses currency:(CurrencyType)currency fee:(NSInteger)fee toAddresses:(NSArray *)toAddresses perAddressAmount:(NSInteger)perAddressAmount tips:(NSString *)tips complete:(CompleteWithDataBlock)complete;


@end
