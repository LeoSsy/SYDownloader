//
//  NSString+SY.m
//  SYDownloader
//
//  Created by shusy on 2017/12/27.
//  Copyright © 2017年 杭州爱卿科技. All rights reserved.
//

#import "NSString+SY.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (SY)
- (NSString *)cachePath {
    return  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:self];
}

- (NSString *)MD5
{
    // 得出bytes
    const char *cstring = self.UTF8String;
    unsigned char bytes[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cstring, (CC_LONG)strlen(cstring), bytes);
    
    // 拼接
    NSMutableString *md5String = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5String appendFormat:@"%02x", bytes[i]];
    }
    return md5String;
}

- (NSInteger)fileSize
{
    return [[[NSFileManager defaultManager] attributesOfItemAtPath:self error:nil][NSFileSize] integerValue];
}

- (NSString *)encodedURL
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]", NULL,kCFStringEncodingUTF8));
}
@end
