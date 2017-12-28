//
//  SYDownloadManager.h
//  SYDownloader
//
//  Created by shusy on 2017/12/27.
//  Copyright © 2017年 杭州爱卿科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYDownload.h"

@interface SYDownloadManager : NSObject

/** 最多同时下载多少个文件*/
@property(nonatomic,assign)NSInteger maxDownloadingCount;

/** 获取默认的管理者*/
+ (instancetype)defaultManager;

/**
 获得下载信息
 */
- (SYDownloadInfo*)downloadInfoWithUrl:(NSString*)url;

/**
 下载一个文件
 @param url url地址
 @param desitinationPath 文件的描述路径 如： 1.mp3 2.mp4
 @param progerssBlock 下载进度的回调
 @param stateBlock 下载状态的回调
 @return 下载文件的信息
 */
- (SYDownloadInfo*)download:(NSString*)url toDesitinationPath:(NSString*)desitinationPath progress:(SYDownloadProgerssBlock)progerssBlock state:(SYDownloadStateBlock)stateBlock;

/**
 下载一个文件
 @param url url地址
 @return 下载文件的信息
 */
- (SYDownloadInfo*)download:(NSString*)url;

/**
 下载一个文件
 @param url url地址
 @param progerssBlock 下载进度的回调
 @param stateBlock 下载状态的回调
 @return 下载文件的信息
 */
- (SYDownloadInfo*)download:(NSString*)url progress:(SYDownloadProgerssBlock)progerssBlock state:(SYDownloadStateBlock)stateBlock;

/**
 取消下载
 */
- (void)cancle:(NSString*)url ;

/**
 暂停下载
 */
- (void)suspend:(NSString*)url ;

/**
 恢复下载
 */
- (void)resume:(NSString*)url;

+ (void)cancleAll;
- (void)cancleAll;

+ (void)suspendAll ;
- (void)suspendAll ;

+ (void)resumeAll;
- (void)resumeAll;

@end
