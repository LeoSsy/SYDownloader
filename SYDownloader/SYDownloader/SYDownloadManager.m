//
//  SYDownloadManager.m
//  SYDownloader
//
//  Created by shusy on 2017/12/27.
//  Copyright © 2017年 杭州爱卿科技. All rights reserved.
//

#import "SYDownloadManager.h"

@interface SYDownloadManager()<NSURLSessionDataDelegate>
/**session*/
@property(nonatomic,strong)NSURLSession *session;
/**下载队列*/
@property(nonatomic,strong)NSOperationQueue *queue;
/**所有文件下载信息*/
@property(nonatomic,strong)NSMutableArray *downloadFiles;
/** 是否正在批量处理 */
@property (assign, nonatomic, getter=isBatching) BOOL batching;
@end

@implementation SYDownloadManager

/** 存放所有的manager */
static NSMutableDictionary *_managers;

+ (void)initialize {
    _totalFileSizesFile = [[NSString stringWithFormat:@"%@/%@", SYDownloadRootDir, @"SYDownloadFileSizes.plist".MD5] cachePath];
    _totalFileSizes = [NSMutableDictionary dictionaryWithContentsOfFile:_totalFileSizesFile];
    if (_totalFileSizes == nil) {
        _totalFileSizes = [NSMutableDictionary dictionary];
    }
    _managers = [NSMutableDictionary dictionary];
}

- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
    }
    return _queue;
}

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session= [NSURLSession sessionWithConfiguration:cfg delegate:self delegateQueue:self.queue];
    }
    return _session;
}

- (NSMutableArray *)downloadFiles {
    if (!_downloadFiles) {
        _downloadFiles = [NSMutableArray array];
    }
    return _downloadFiles;
}

- (void)setMaxDownloadingCount:(NSInteger)maxDownloadingCount {
    _maxDownloadingCount = maxDownloadingCount;
    self.queue.maxConcurrentOperationCount = maxDownloadingCount;
}

#pragma mark 构造对象
+ (instancetype)defaultManager {
    return [self manageWithIdentifier:SYDownloadManagerIdentifier];
}

+ (instancetype)manageWithIdentifier:(NSString*)identifier {
    if (identifier == nil) { return [self manager];}
    SYDownloadManager *mgr = _managers[identifier];
    if (!mgr) {
        mgr = [self manager];
        _managers[identifier] = mgr;
    }
    return mgr;
}

+ (instancetype)manager{
    return [[self alloc] init];
}

#pragma mark 任务控制操作

- (void)cancleAll{
    [self.downloadFiles enumerateObjectsUsingBlock:^(SYDownloadInfo *info, NSUInteger idx, BOOL * _Nonnull stop) {
        [self cancle:info.url];
    }];
}

+ (void)cancleAll{
    [_managers.allValues makeObjectsPerformSelector:@selector(cancleAll)];
}

- (void)suspendAll{
    self.batching = YES;
    [self.downloadFiles enumerateObjectsUsingBlock:^(SYDownloadInfo *info, NSUInteger idx, BOOL * _Nonnull stop) {
        [self suspend:info.url];
    }];
    self.batching = NO;
}

+ (void)suspendAll {
    [_managers.allValues makeObjectsPerformSelector:@selector(suspendAll)];
}

- (void)resumeAll{
    [self.downloadFiles enumerateObjectsUsingBlock:^(SYDownloadInfo *info, NSUInteger idx, BOOL * _Nonnull stop) {
        [self resume:info.url];
    }];
}

+ (void)resumeAll {
    [_managers.allValues makeObjectsPerformSelector:@selector(resumeAll)];
}

- (void)resumeFirstWillResume {
    //如果正在批量操作就不要下载了
    if (self.isBatching) return;
    //取出等待下载的所有文件的第一个开始下载
    SYDownloadInfo *info = [self.downloadFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state==%d",SYDownloadStateWillResume]].firstObject;
    [self resume:info.url];
}

/**
 取消下载
 */
- (void)cancle:(NSString*)url {
    if (url == nil) { return;}
    [[self downloadInfoWithUrl:url] cancle];
}

/**
 暂停下载
 */
- (void)suspend:(NSString*)url {
    if (url == nil) { return;}
    //暂停
    [[self downloadInfoWithUrl:url] suspend];
    //当前任务暂停 那么就要取出等待下载的所有文件的第一个开始下载
    [self resumeFirstWillResume];
}

/**
 恢复下载
 */
- (void)resume:(NSString*)url {
    if (url == nil) { return;}
    //获得下载信息
    SYDownloadInfo *info = [self downloadInfoWithUrl:url];
    //获取正在下载的任务
    NSArray *downloadingFiles = [self.downloadFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state==%d",SYDownloadStateResume]];
    //如果当前正在下载的文件已经达到最大设置的下载数量
    //就让当前文件的下载任务状态变味等待下载
    if (self.maxDownloadingCount && downloadingFiles.count == self.maxDownloadingCount) {
        [info willResume];
    }else{//否则就继续下载
        [info resume];
    }
}

#pragma mark 下载操作相关
- (SYDownloadInfo*)download:(NSString*)url toDesitinationPath:(NSString*)desitinationPath progress:(SYDownloadProgerssBlock)progerssBlock state:(SYDownloadStateBlock)stateBlock {
    if (url == nil) { return nil;}
    
    //获得下载信息
    SYDownloadInfo *info = [self downloadInfoWithUrl:url];
    //设置相关回调
    info.progressBlock = progerssBlock;
    info.stateBlock = stateBlock;
    if (desitinationPath) {
        info.file = desitinationPath;
        info.fileName = [desitinationPath lastPathComponent];
    }
    //如果已经下载完毕
    if (info.state == SYDownloadStateCompleted) {
        [info notifyStateChange];
        return  info;
    }else if (info.state == SYDownloadStateResume){
        return info;
    }
    //创建任务
    [info setupTask:self.session];
    //开始任务
    [self resume:url];
    
    return info;
}

- (SYDownloadInfo*)download:(NSString*)url {
    return [self download:url toDesitinationPath:nil progress:nil state:nil];
}

- (SYDownloadInfo*)download:(NSString*)url progress:(SYDownloadProgerssBlock)progerssBlock state:(SYDownloadStateBlock)stateBlock{
    return [self download:url toDesitinationPath:nil progress:progerssBlock state:stateBlock];
}

/**
 获得下载信息
 */
- (SYDownloadInfo*)downloadInfoWithUrl:(NSString*)url {
    if (url == nil) { return nil;}
    SYDownloadInfo *info = [self.downloadFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"url==%@",url]].firstObject;
    if (info == nil) {
        info = [[SYDownloadInfo alloc] init];
        info.url = url;
        [self.downloadFiles addObject:info];
    }
    return info;
}

#pragma mark NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    //获得下载信息
    SYDownloadInfo *info = [self downloadInfoWithUrl:dataTask.taskDescription];
    //处理响应
    [info didReceiveResonse:response];
    //继续执行请求
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    //获得下载信息
    SYDownloadInfo *info = [self downloadInfoWithUrl:dataTask.taskDescription];
    //处理数据
    [info didReceiveData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"下载完成了=====");
    //获得下载信息
    SYDownloadInfo *info = [self downloadInfoWithUrl:task.taskDescription];
    // 处理结束
    [info didCompleteWithError:error];
    // 恢复等待下载的
    [self resumeFirstWillResume];
}


@end
