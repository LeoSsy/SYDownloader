//
//  SYDownloadInfo.h
//  SYDownloader
//
//  Created by shusy on 2017/12/27.
//  Copyright © 2017年 杭州爱卿科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYDownloadeConst.h"

@interface SYDownloadInfo : NSObject
/**文件下载状态*/
@property(assign,nonatomic,readonly)SYDownloadState state;
/**文件路径*/
@property(nonatomic,copy)NSString *file;
/**文件名*/
@property(nonatomic,copy)NSString *fileName;
/**文件url*/
@property(nonatomic,copy)NSString *url;
/**下载错误信息*/
@property(nonatomic,copy,readonly)NSError *error;
/**当前下载文件的总大小*/
@property(nonatomic,assign,readonly)NSInteger expectedBytes;
/**当前已经下载的字节*/
@property(nonatomic,assign,readonly)NSInteger downloadedBytes;
/**本次下载的字节*/
@property(nonatomic,assign,readonly)NSInteger currentDownloadedBytes;
/**下载进度改变后的回调*/
@property(nonatomic,strong)SYDownloadProgerssBlock progressBlock;
/**下载状态改变的回调*/
@property(nonatomic,strong)SYDownloadStateBlock stateBlock;
/**
 初始化任务
 
 @param session session对象
 */
- (void)setupTask:(NSURLSession*)session;
/**
 处理响应
 */
- (void)didReceiveResonse:(NSHTTPURLResponse*)response;
/**
 处理数据
 */
- (void)didReceiveData:(NSData*)data;

/**
 下载完成后的处理
 */
- (void)didCompleteWithError:(NSError*)error;

/**
 取消下载
 */
- (void)cancle;
/**
 恢复下载
 */
- (void)resume;
/**
 等待下载
 */
- (void)willResume;
/**
 暂停
 */
- (void)suspend;

/**
 进度改变的通知
 */
- (void)notifyProgressChange;

/**
 下载状态改变的通知
 */
-(void)notifyStateChange;
    
@end
