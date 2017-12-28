//
//  SYDownloadInfo.m
//  SYDownloader
//
//  Created by shusy on 2017/12/27.
//  Copyright © 2017年 杭州爱卿科技. All rights reserved.
//

#import "SYDownloadInfo.h"
#import "SYDownload.h"

@interface SYDownloadInfo()
{
    SYDownloadState _state;
    NSInteger _downloadedBytes;
}
/**文件流*/
@property(nonatomic,strong)NSOutputStream *outputStream;
/**文件下载状态*/
@property(nonatomic,assign)SYDownloadState state;
/**下载错误信息*/
@property(nonatomic,copy)NSError *error;
/**当前下载文件的总大小*/
@property(nonatomic,assign)NSInteger expectedBytes;
/**当前已经下载的字节*/
@property(nonatomic,assign)NSInteger downloadedBytes;
/**本次下载的字节*/
@property(nonatomic,assign)NSInteger currentDownloadedBytes;
/**下载任务对象*/
@property(nonatomic,strong)NSURLSessionDataTask *task;
@end

@implementation SYDownloadInfo

- (NSString *)file {
    if (!_file) {
        _file = [NSString stringWithFormat:@"%@/%@",SYDownloadRootDir,self.fileName].cachePath;
    }
    if (_file && ![[NSFileManager defaultManager] fileExistsAtPath:_file]) {
        NSString *dir = [_file stringByDeletingLastPathComponent];
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return _file;
}

- (NSString *)fileName {
    if (!_fileName) {
        NSString *pathExtension = self.url.pathExtension;
        if (pathExtension.length) {
            _fileName = [NSString stringWithFormat:@"%@.%@",self.url.MD5,pathExtension];
        }else{
            _fileName = self.url.MD5;
        }
    }
    return _fileName;
}

- (NSOutputStream *)outputStream {
    if (!_outputStream) {
        _outputStream = [NSOutputStream outputStreamToFileAtPath:self.file append:YES];
    }
    return _outputStream;
}

- (NSInteger)downloadedBytes {
    return self.file.fileSize;
}

- (NSInteger)expectedBytes {
    if (!_expectedBytes) {
        _expectedBytes = [_totalFileSizes[self.url] integerValue];
    }
    return _expectedBytes;
}

- (SYDownloadState)state {
    if (self.expectedBytes && self.downloadedBytes == self.expectedBytes) {
        return SYDownloadStateCompleted;
    }
    if (self.task.error) { return SYDownloadStateNone;}
    return _state;
}

/**
 初始化任务

 @param session session对象
 */
- (void)setupTask:(NSURLSession*)session {
    if (self.task) { return;}
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-",self.currentDownloadedBytes];
    [request setValue:range forHTTPHeaderField:@"Range"];
    self.task = [session dataTaskWithRequest:request];
    self.task.taskDescription = self.url;
}

/**
 取消下载
 */
- (void)cancle{
    if (self.state == SYDownloadStateCompleted || self.state == SYDownloadStateNone) {return;}
    [self.task cancel];
    self.state = SYDownloadStateNone;
}

/**
 恢复下载
 */
- (void)resume{
    if (self.state == SYDownloadStateCompleted || self.state == SYDownloadStateResume) {return;}
    [self.task resume];
    self.state = SYDownloadStateResume;
}

/**
 等待下载
 */
- (void)willResume{
    if (self.state == SYDownloadStateCompleted || self.state == SYDownloadStateWillResume) {return;}
    self.state = SYDownloadStateWillResume;
}

/**
 暂停
 */
- (void)suspend {
    if (self.state == SYDownloadStateCompleted || self.state == SYDownloadStateSuspend) {return;}
    if (self.state == SYDownloadStateResume) { //如果正在下载就暂停下载任务
        [self.task suspend];
        self.state = SYDownloadStateSuspend;
    }else{ //如果是等待下载就设置为默认状态
        self.state = SYDownloadStateNone;
    }
}

/**
 进度改变的通知
 */
- (void)notifyProgressChange{
    dispatch_async(dispatch_get_main_queue(), ^{
     self.progressBlock ? self.progressBlock(self.currentDownloadedBytes, self.downloadedBytes, self.expectedBytes) : nil;
    });
}

/**
 下载状态改变的通知
 */
-(void)notifyStateChange{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.stateBlock?self.stateBlock(self.state, self.file, self.error):nil;
    });
}

- (void)setState:(SYDownloadState)state {
    SYDownloadState oldState = self.state;
    if (state == oldState) { return;}
    _state = state;
    [self notifyStateChange];
}

- (void)didReceiveResonse:(NSHTTPURLResponse*)response {
    if (!self.expectedBytes) {
        self.expectedBytes = [response.allHeaderFields[@"Content-Length"] integerValue]+self.downloadedBytes;
        _totalFileSizes[self.url] = @(self.expectedBytes);
        [_totalFileSizes writeToFile:_totalFileSizesFile atomically:YES];
    }
    //打开流
    [self.outputStream open];
    //错误
    self.error = nil;
}

- (void)didReceiveData:(NSData*)data{
    NSInteger result = [self.outputStream write:data.bytes maxLength:data.length];
    if (result == -1) {
        self.error = self.outputStream.streamError;
        [self.task cancel];
    }else{
        self.currentDownloadedBytes = data.length;
        [self notifyProgressChange];
    }
}
    
- (void)didCompleteWithError:(NSError*)error {
    //关闭文件流
    [self.outputStream close];
    self.currentDownloadedBytes = 0;
    self.outputStream = nil;
    self.task = nil;
    //设置状态
    self.error = error?error:self.error;
    if (self.state == SYDownloadStateCompleted || error) {
        self.state = error? SYDownloadStateNone : SYDownloadStateCompleted;
    }
}

@end
