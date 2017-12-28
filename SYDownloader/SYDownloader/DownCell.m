//
//  DownCell.m
//  SYDownloader
//
//  Created by shusy on 2017/12/28.
//  Copyright © 2017年 杭州爱卿科技. All rights reserved.
//

#import "DownCell.h"
#import "SYDownload.h"
#import "SYProgressView.h"

@interface DownCell()
@property (weak, nonatomic) IBOutlet SYProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@end

@implementation DownCell

- (void)setUrl:(NSString *)url {
    _url = url;
    self.textLabel.text = [url lastPathComponent];
    SYDownloadInfo *info = [[SYDownloadManager defaultManager] downloadInfoWithUrl:url];
    if (info.state == SYDownloadStateCompleted) {
        [self.downloadBtn setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
        self.progressView.hidden = YES;
    }else if (info.state == SYDownloadStateWillResume) {
        self.progressView.hidden = YES;
        [self.downloadBtn setImage:[UIImage imageNamed:@"clock"] forState:UIControlStateNormal];
    }else if (info.state == SYDownloadStateSuspend) {
        self.progressView.hidden = YES;
        [self.downloadBtn setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
    }else {
        if (info.state == SYDownloadStateNone) {
            [self.downloadBtn setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
            self.progressView.hidden = YES;
            return;
        }
        self.progressView.hidden = NO;
        [self.downloadBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        //计算下载进度
        if (info.expectedBytes) {
            self.progressView.progress =1.0*info.downloadedBytes/info.expectedBytes;
        }else{
            self.progressView.progress = 0.0;
        }
    }
}

- (IBAction)downloadBtnClick:(id)sender {
    SYDownloadInfo *info = [[SYDownloadManager defaultManager] downloadInfoWithUrl:self.url];
    if ( info.state == SYDownloadStateResume || info.state == SYDownloadStateWillResume) {
        [[SYDownloadManager defaultManager] suspend:self.url];
    }else{
        [[SYDownloadManager defaultManager] download:self.url progress:^(NSInteger currentWriteBytes, NSInteger writedBytes, NSInteger totalBytes) {
            self.url  = self.url;
        } state:^(SYDownloadState state, NSString *file, NSError *error) {
            self.url  = self.url;
        }];
    }
    
}


@end
