//
//  SYDownloadeConst.m
//  SYDownloader
//
//  Created by shusy on 2017/12/28.
//  Copyright © 2017年 杭州爱卿科技. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 存放所有的文件大小 */
NSMutableDictionary *_totalFileSizes ;
/** 存放所有的文件大小的文件路径 */
NSString *_totalFileSizesFile;
/** 根文件夹 */
NSString * const SYDownloadRootDir = @"com_aqcome_www_sydownload";
/** 下载管理唯一标识 */
NSString * const SYDownloadManagerIdentifier = @"com_aqcome_www_SYDownloadManager";
