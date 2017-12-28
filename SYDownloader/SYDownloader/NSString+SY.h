//
//  NSString+SY.h
//  SYDownloader
//
//  Created by shusy on 2017/12/27.
//  Copyright © 2017年 杭州爱卿科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SY)

/**
 获取cache目录
 @return 完整路径
 */
- (NSString*)cachePath;

/**
 *  生成MD5摘要
 */
- (NSString *)MD5;

/**
 *  文件大小
 */
- (NSInteger)fileSize;

/**
 *  生成编码后的URL
 */
- (NSString *)encodedURL;

@end
