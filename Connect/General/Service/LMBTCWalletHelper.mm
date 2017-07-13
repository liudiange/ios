//
//  LMBTCWalletHelper.m
//  Connect
//
//  Created by MoHuilin on 2017/6/15.
//  Copyright © 2017年 Connect. All rights reserved.
//

#import "LMBTCWalletHelper.h"

#ifdef __cplusplus
#if __cplusplus
extern "C" {
#include "bip39.h"
#include "ecies.h"
#include "pbkdf2.h"
}
#endif
#endif /* __cplusplus */

#include "key.h"
#include <sstream>

#include "base58.h"
#include "script.h"
#include "uint256.h"
#include "util.h"
#include "keydb.h"


#include <string>
#include <vector>

#include <openssl/aes.h>
#include <openssl/evp.h>
#include <openssl/bn.h>
#include <openssl/ecdsa.h>
#include <openssl/obj_mac.h>
#include <openssl/rand.h>
#include <openssl/hmac.h>
#include <openssl/md5.h>


#include <boost/algorithm/string.hpp>
#include <boost/assign/list_of.hpp>
#include "json_spirit_reader_template.h"
#include "json_spirit_utils.h"
#include "json_spirit_writer_template.h"
#include "json_spirit_value.h"

@implementation LMBTCWalletHelper


+ (NSString *)createRawTranscationWithTvsArray:(NSArray *)tvsArray outputs:(NSDictionary *)outputs {
    // checkout format
    for (NSDictionary *temD in tvsArray) {
        if (![temD isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        if (![temD.allKeys containsObject:@"vout"]) {
            return nil;
        }
        if (![temD.allKeys containsObject:@"txid"]) {
            return nil;
        }
        if (![temD.allKeys containsObject:@"scriptPubKey"]) {
            return nil;
        }
    }

    NSString *tvsJson = [self ObjectTojsonString:tvsArray];
    NSString *outputJson = [self ObjectTojsonString:outputs];
    NSString *inparamStr_ = [NSString stringWithFormat:@"%@ %@", tvsJson, outputJson];

    char *rawtrans_str;
    char inparam[1024 * 100];

    const char *inparam1 = [inparamStr_ UTF8String];// Naked trading data
    strcpy(inparam, inparam1);
    createBtcRawTranscation(inparam, &rawtrans_str);
    NSString *rawTranscation = [NSString stringWithUTF8String:rawtrans_str];
    free(rawtrans_str);
    return rawTranscation;
}

+ (NSString *)signRawTranscationWithTvsArray:(NSArray *)tvsArray privkeys:(NSArray *)privkeys rawTranscation:(NSString *)rawTranscation {

    for (NSDictionary *temD in tvsArray) {
        if (![temD isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        if (![temD.allKeys containsObject:@"vout"]) {
            return nil;
        }
        if (![temD.allKeys containsObject:@"txid"]) {
            return nil;
        }
        if (![temD.allKeys containsObject:@"scriptPubKey"]) {
            return nil;
        }
    }

    NSString *tvsJson = [self ObjectTojsonString:tvsArray];

    const char *rawtrans_str = [rawTranscation UTF8String];
    char *signedtrans_ret;
    char inparam[1024 * 100];

    NSArray *privkeyArr_ = privkeys;//
    // Signature parameters json data
    NSMutableString *signParamStr = [NSMutableString stringWithFormat:@"%s", rawtrans_str];
    [signParamStr appendString:@" "];
    [signParamStr appendString:tvsJson];
    [signParamStr appendString:@" "];
    NSString *privKeyJson = [self ObjectTojsonString:privkeyArr_];
    [signParamStr appendString:privKeyJson];
    const char *inparam2 = [signParamStr UTF8String];//sign data
    strcpy(inparam, inparam2);

    signBtcRawTranscation(inparam, &signedtrans_ret);
    printf("signRawTranscation=%s\n", signedtrans_ret);

    NSString *signedStr = [NSString stringWithFormat:@"%s", signedtrans_ret];
    free(signedtrans_ret);
    NSError *error;
    NSDictionary *completeDic = [NSJSONSerialization JSONObjectWithData:[signedStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    BOOL b = [[completeDic objectForKey:@"complete"] boolValue];
    if (b) {
        NSString *result = [completeDic objectForKey:@"hex"];

        return result;
    }
    NSLog(@"signRawTranscation is failure,please check!");

    return nil;

}

+ (NSString *)getPrivkeyBySeed:(NSString *)seed index:(int)index {
    char myRand[129] = {0};
    char *randomC = (char *) [seed UTF8String];
    sprintf(myRand, "%s", randomC);
    char privKey[512];
    GetBtcPrivKeyFromSeedBIP44(myRand, privKey, 44, 0, 0, 0, index);
    return [NSString stringWithFormat:@"%s", privKey];
}

+(NSString *)encodeValue:(NSString *)value password:(NSString *)password n:(int)n{
    char *v = (char *)[value UTF8String];
    char *pass = (char *)[password UTF8String];
    std::string retString=connectWalletEncrypt(v,pass,n, 1);
    return [NSString stringWithFormat:@"%s",retString.c_str()];
}

+(NSString *)decodeEncryptValue:(NSString *)encryptValue password:(NSString *)password{
    char value[256];
    char *ev = (char *)[encryptValue UTF8String];
    char *pass = (char *)[password UTF8String];
    int result = connectWalletDecrypt(ev,pass,1, value);
    if (result == 1) {
        return [NSString stringWithUTF8String:value];
    } else {
        return @"";
    }
}

// Data is converted to JsonString type
+ (NSString *)ObjectTojsonString:(id)object {
    if (object == nil) {
        return nil;
    }
    NSString *jsonString = [[NSString alloc] init];


    // The system comes with the method
    // /*
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0, jsonString.length};
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0, mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];

    return mutStr;
}


std::string xtalkWalletSeedEncrypt(unsigned char *usrID, unsigned char *privKey, char *pwd, int n, int ver) {
    //  below is the process of E1
    unsigned char h[64];
    unsigned char chk[2];
    unsigned char usrIDAandPrivKey[XTALK_USRID_LEN + XTALK_PRIVKEY_LEN];

    // user id 8bytes
    memcpy(usrIDAandPrivKey, usrID, XTALK_USRID_LEN);
    // privkey 32 bytes
    memcpy(usrIDAandPrivKey + XTALK_USRID_LEN, privKey, XTALK_PRIVKEY_LEN);

    xtalkSHA512(usrIDAandPrivKey, XTALK_USRID_LEN + XTALK_PRIVKEY_LEN, h);

    // copy first 2 bytes to chk
    memcpy(chk, h, 2);

    // below is the process of E2
    unsigned char salt[8];    // 8*8= 64 bits
    RAND_bytes(salt, 8);

    // below is the process of E3
    unsigned char key[256 / 8];
    xtalkPBKDF2_HMAC_SHA512((unsigned char *) pwd, strlen(pwd), salt, 64, key, 256, n);

    // below is the process of E4
    unsigned char chkUsrIDPrivKey[2 + XTALK_USRID_LEN + XTALK_PRIVKEY_LEN];    // 2+36+32 = 70
    memcpy(chkUsrIDPrivKey, chk, 2);
    memcpy(chkUsrIDPrivKey + 2, usrID, XTALK_USRID_LEN);
    memcpy(chkUsrIDPrivKey + 2 + XTALK_USRID_LEN, privKey, XTALK_PRIVKEY_LEN);

    AES_KEY aes_key;
    if (AES_set_encrypt_key((const unsigned char *) key, sizeof(key) * 8, &aes_key) < 0) {
        assert(false);
        return "error";
    }

    unsigned char *secret;
    unsigned char *data_tmp;
    unsigned int ret_len = sizeof(chkUsrIDPrivKey);    // use input data len to get the secret len
    if (sizeof(chkUsrIDPrivKey) % AES_BLOCK_SIZE > 0) {
        ret_len += AES_BLOCK_SIZE - (sizeof(chkUsrIDPrivKey) % AES_BLOCK_SIZE);
    }
    data_tmp = (unsigned char *) malloc(ret_len);
    secret = (unsigned char *) malloc(ret_len);
    memset(data_tmp, 0x00, ret_len);
    memcpy(data_tmp, chkUsrIDPrivKey, sizeof(chkUsrIDPrivKey));    // prepare data for encrypt

    for (unsigned int i = 0; i < ret_len / AES_BLOCK_SIZE; i++) {
        unsigned char out[AES_BLOCK_SIZE];
        memset(out, 0, AES_BLOCK_SIZE);
        AES_encrypt((const unsigned char *) (&data_tmp[i * AES_BLOCK_SIZE]), out, &aes_key);
        memcpy(&secret[i * AES_BLOCK_SIZE], out, AES_BLOCK_SIZE);
    }
    free(data_tmp);
    // data stored in secret, length is ret_len

    // below is the process of E5
    unsigned char *result;
    result = (unsigned char *) malloc(1 + 8 + ret_len);    // 1 byte version + 8 bytes salt + secret

    // set v value;
    result[0] = (ver << 5) + n;
    memcpy(result + 1, salt, 8);
    memcpy(result + 9, secret, ret_len);
    free(secret);    // do not forget to free it.

    // finally, we return the hex string. easiler for debug and show
    std::string retStr = HexStr(&result[0], &result[1 + 8 + ret_len], false);
    free(result);

    return retStr;
}


using namespace json_spirit;

Value CallRPC(string args);

int createBtcRawTranscation(char *in_param, char **rawtrans_string) {
    Value r;
    char *ret_str;
    string param = string("createrawtransaction ") + in_param;
    r = CallRPC(param);
    string notsigned = r.get_str();
    ret_str = (char *) malloc(notsigned.size() + 1);
    sprintf(ret_str, "%s", notsigned.c_str());
    *rawtrans_string = ret_str;
    return 0;
}

int signBtcRawTranscation(char *in_param, char **signedtrans_ret) {
    Value r;
    char *ret_str;
    string param = string("signrawtransaction ") + in_param;
    r = CallRPC(param);
    string ret = write_string(Value(r), false);
    ret_str = (char *) malloc(ret.size() + 1);
    sprintf(ret_str, "%s", ret.c_str());
    *signedtrans_ret = ret_str;
    return 0;
}


// add
int GetBtcPrivKeyFromSeedBIP44(const char *SeedStr, char *PrivKey, unsigned int purpose, unsigned int coin, unsigned int account, unsigned int isInternal, unsigned int addrIndex) {
    CExtKey Exkey;
    std::vector<unsigned char> seed = ParseHex(SeedStr);
    Exkey.SetMaster(&seed[0], seed.size());

    CExtKey privkey1;
    purpose |= 0x80000000;
    Exkey.Derive(privkey1, purpose);

    CExtKey privkey2;
    coin |= 0x80000000;
    privkey1.Derive(privkey2, coin);

    CExtKey privkey3;
    account |= 0x80000000;
    privkey2.Derive(privkey3, account);

    CExtKey privkey4;
    privkey3.Derive(privkey4, isInternal);

    CExtKey privkey5;
    privkey4.Derive(privkey5, addrIndex);

    CBitcoinSecret btcSecret;
    btcSecret.SetKey(privkey5.key);
    sprintf(PrivKey, "%s", btcSecret.ToString().c_str());

    return 0;
}

int GetBTCPubKeyFromPrivKey(char *privKey, char *pubKey)
{
    string privStr(privKey);
    CBitcoinSecret btcSecret;
    if(!btcSecret.SetString (privStr))
    {
        printf("Error : btcSecret.SetString (privStr)...\n");
        return 1;
    }
    CPubKey pubkey  = btcSecret.GetKey().GetPubKey();
    std::vector<unsigned char> vch(pubkey.begin(), pubkey.end());
    std::string pubkeyStr=HexStr(vch);
    
    sprintf(pubKey,"%s",pubkeyStr.c_str());
    
    return 0;
}

int GetBTCAddrressFromPubKey(char *pubKey, char *address)
{
    std::string pubkeyStr = pubKey;
    CPubKey pubkey(ParseHex(pubkeyStr));
    CBitcoinAddress btcAddr(pubkey.GetID());
    sprintf(address,"%s",btcAddr.ToString().c_str());
    
    return 0;
}


+ (NSString *)getAddressByPrivKey:(NSString *)prvkey{
    char *cPrivkey = (char *)[prvkey UTF8String];
    char pubKey[128];
    GetBTCPubKeyFromPrivKey(cPrivkey, pubKey);
    char address[128];
    GetBTCAddrressFromPubKey(pubKey, address);
    return [NSString stringWithFormat:@"%s",address];
}


// use hex string to encrypt wallet
std::string connectWalletEncrypt(char *wallet_HexString, char *pwd, int n, int ver)
{
    std::vector<unsigned char> wallet = ParseHex(wallet_HexString);
    
    if (wallet.size() == 0)
        return "error wallet lenght";
    
    //  below is the process of E1
    unsigned char h[64];
    unsigned char chk[2];
    unsigned char plainTextLen = (unsigned char)wallet.size();
    
    xtalkSHA512(&wallet[0], wallet.size(), h);
    
    // copy first 2 bytes to chk
    memcpy(chk, h, 2);
    
    // below is the process of E2
    unsigned char salt[8]; // 8*8= 64 bits
    RAND_bytes(salt, 8);
    
    // below is the process of E3
    unsigned char key[32];
    xtalkPBKDF2_HMAC_SHA512((unsigned char *)pwd, strlen(pwd), salt, 8 * 8, key, sizeof(key) * 8, n);
    
    // below is the process of E4
    unsigned char chkWallet[2 + wallet.size()]; //
    memcpy(chkWallet, chk, 2);
    memcpy(chkWallet + 2, &wallet[0], wallet.size());
    
    AES_KEY aes_key;
    if (AES_set_encrypt_key((const unsigned char *)key, sizeof(key) * 8, &aes_key) < 0)
    {
        assert(false);
        return "error";
    }
    
    unsigned char *secret;
    unsigned char *data_tmp;
    unsigned int ret_len = sizeof(chkWallet); // use input data len to get the secret len
    if (sizeof(chkWallet) % AES_BLOCK_SIZE > 0)
    {
        ret_len += AES_BLOCK_SIZE - (sizeof(chkWallet) % AES_BLOCK_SIZE);
    }
    data_tmp = (unsigned char *)malloc(ret_len);
    secret = (unsigned char *)malloc(ret_len);
    memset(data_tmp, 0x00, ret_len);
    memcpy(data_tmp, chkWallet, sizeof(chkWallet)); // prepare data for encrypt
    
    for (unsigned int i = 0; i < ret_len / AES_BLOCK_SIZE; i++)
    {
        unsigned char out[AES_BLOCK_SIZE];
        memset(out, 0, AES_BLOCK_SIZE);
        AES_encrypt((const unsigned char *)(&data_tmp[i * AES_BLOCK_SIZE]), out, &aes_key);
        memcpy(&secret[i * AES_BLOCK_SIZE], out, AES_BLOCK_SIZE);
    }
    free(data_tmp);
    // data stored in secret, length is ret_len
    
    // below is the process of E5
    unsigned char *result;
    result = (unsigned char *)malloc(1 + 1 + 8 + ret_len); // 1 byte version + 8 bytes salt + secret
    
    // set v value;
    result[0] = (ver << 5) + n;
    result[1] = plainTextLen;
    memcpy(result + 2, salt, 8);
    memcpy(result + 10, secret, ret_len);
    free(secret); // do not forget to free it.
    
    // finally, we return the hex string. easiler for debug and show
    std::string retStr = HexStr(&result[0], &result[1 + 1 + 8 + ret_len], false);
    free(result);
    
    return retStr;
}

// connect wallet decrypt
int connectWalletDecrypt(char *encryptedString, char *pwd, int ver, char *walletHexString){
    int ret;
    
    std::vector<unsigned char> encryptedData = ParseHex(encryptedString);
    // below is the process of D1
    unsigned char v[1];
    v[0] = encryptedData[0];
    
    int version = (v[0] >> 5) & 0x7; // only get the high 3 bits' value
    if (version != ver)
        return -1; // version error
    
    // below is the process of D2
    int n = v[0] & 0x1f; // only get the low 5 bits' value
    
    // below is the process of D3
    int plainTextLen = (int)encryptedData[1];
    unsigned char salt[8];
    unsigned char *secret;
    int secretLen = encryptedData.size() - 1 - 1 - 8; // decrease one byte v and 8 bytes salt
    secret = (unsigned char *)malloc(secretLen);
    memcpy(salt, &encryptedData[2], 8);
    memcpy(secret, &encryptedData[10], secretLen);
    
    // below is the process of D4
    unsigned char key[32];
    xtalkPBKDF2_HMAC_SHA512((unsigned char *)pwd, strlen(pwd), salt, 8 * 8, key, sizeof(key) * 8, n);
    
    // below is the process of D5
    unsigned char *secret_decrypted;
    secret_decrypted = (unsigned char *)malloc(secretLen);
    
    AES_KEY aes_key;
    if (AES_set_decrypt_key(key, sizeof(key) * 8, &aes_key) < 0)
    {
        assert(false);
        return -1;
    }
    
    for (unsigned int i = 0; i < secretLen / AES_BLOCK_SIZE; i++)
    {
        unsigned char out[AES_BLOCK_SIZE];
        ::memset(out, 0, AES_BLOCK_SIZE);
        AES_decrypt(&secret[AES_BLOCK_SIZE * i], out, &aes_key);
        memcpy(&secret_decrypted[AES_BLOCK_SIZE * i], out, AES_BLOCK_SIZE);
    }
    free(secret);
    
    unsigned char chk[2];
    unsigned char *wallet;
    wallet = (unsigned char *)malloc(plainTextLen);
    memcpy(chk, secret_decrypted, 2);
    memcpy(&wallet[0], secret_decrypted + 2, plainTextLen);
    free(secret_decrypted);
    
    // below is the process of D6
    unsigned char h[64];
    
    xtalkSHA512(&wallet[0], plainTextLen, h);
    
    if (memcmp(chk, h, 2) != 0)
        return 0;
    
    strcpy(walletHexString, HexStr(&wallet[0], &wallet[plainTextLen], false).c_str());
    free(wallet);
    
    return 1;
}


@end