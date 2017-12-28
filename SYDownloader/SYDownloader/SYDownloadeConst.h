//
//  SYDownloadeConst.h
//  SYDownloader
//
//  Created by shusy on 2017/12/27.
//  Copyright © 2017年 杭州爱卿科技. All rights reserved.
//

/**
 下载状态
 */
typedef NS_ENUM(NSUInteger, SYDownloadState) {
    SYDownloadStateNone, //默认状态
    SYDownloadStateWillResume, //等待下载状态
    SYDownloadStateResume,//下载状态
    SYDownloadStateSuspend,//暂停状态
    SYDownloadStateCompleted//下载完成状态
} NS_ENUM_AVAILABLE_IOS(2_0);

/**
 下载进度改变的回调
 @param currentWriteBytes 当前本次下载的字节数
 @param writedBytes 已经下载的字节数
 @param totalBytes  文件总的字节数
 */
typedef void(^SYDownloadProgerssBlock)(NSInteger currentWriteBytes,NSInteger writedBytes,NSInteger totalBytes);

/**
 下载状态改变的回调
 
 @param state 下载状态
 @param file 下载的文件
 @param error 错误信息
 */
typedef void(^SYDownloadStateBlock)(SYDownloadState state,NSString *file, NSError* error);

/** 存放所有的文件大小 */
extern NSMutableDictionary *_totalFileSizes ;
/** 存放所有的文件大小的文件路径 */
extern NSString *_totalFileSizesFile;
/** 根文件夹 */
extern NSString * const SYDownloadRootDir;
/** 下载管理唯一标识 */
extern NSString * const SYDownloadManagerIdentifier;
