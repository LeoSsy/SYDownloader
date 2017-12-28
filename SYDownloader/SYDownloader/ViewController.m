//
//  ViewController.m
//  SYDownloader
//
//  Created by shusy on 2017/12/27.
//  Copyright © 2017年 杭州爱卿科技. All rights reserved.
//

#import "ViewController.h"
#import "SYDownload.h"
#import "DownCell.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)NSMutableArray *urls;
@end

@implementation ViewController

- (IBAction)resumeAll:(id)sender {
    [[SYDownloadManager defaultManager] resumeAll];
}

- (IBAction)suspendAll:(id)sender {
    [[SYDownloadManager defaultManager] suspendAll];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SYDownloadManager defaultManager].maxDownloadingCount = 5;
    self.urls = [NSMutableArray array];
    for (int i = 1 ; i< 11 ; i++) {
        [self.urls addObject:[NSString stringWithFormat:@"http://120.25.226.186:32812/resources/videos/minion_%02d.mp4",i]];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    SYDownloadInfo *infon = [[SYDownloadManager defaultManager] download:@"http://120.25.226.186:32812/resources/videos/minion_04.mp4" progress:^(NSInteger currentWriteBytes, NSInteger writedBytes, NSInteger totalBytes) {
       //计算进度
//        NSLog(@"progress=%f",1.0*writedBytes/totalBytes);
    } state:^(SYDownloadState state, NSString *file, NSError *error) {
        NSLog(@"file====%@",file);
    }];
    NSLog(@"url====%@",infon.url);
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.urls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownCell *cell = [tableView dequeueReusableCellWithIdentifier:@"download"];
    cell.url = self.urls[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

@end
