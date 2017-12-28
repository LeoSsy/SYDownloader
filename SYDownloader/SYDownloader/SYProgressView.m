//
//  SYProgressView.m
//  SYDownloader
//
//  Created by shusy on 2017/12/28.
//  Copyright © 2017年 杭州爱卿科技. All rights reserved.
//

#import "SYProgressView.h"

@implementation SYProgressView

- (void)setProgress:(CGFloat )progress {
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [[UIColor redColor] set];
    UIRectFill(CGRectMake(0, 0, self.progress*rect.size.width, rect.size.height));
}

@end
