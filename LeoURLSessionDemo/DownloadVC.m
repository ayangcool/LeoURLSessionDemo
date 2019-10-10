//
//  DownloadVC.m
//  LeoUrlRequestDemo
//
//  Created by leo on 2019/10/10.
//  Copyright © 2019 leo. All rights reserved.
//

#import "DownloadVC.h"

@interface DownloadVC () <NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSData *resumeData;

@end

@implementation DownloadVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSStringFromClass([self class]);
    
    CGFloat width = 150;
    CGFloat height = 40;
    CGFloat btnX = ([UIScreen mainScreen].bounds.size.width - width) / 2.0;
    for (int i = 0; i < 3; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(btnX, 200 + (height + 30) * i, width, height);
        [self.view addSubview:btn];
        [btn addTarget:self action:@selector(handleBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 3000 + i;
        btn.backgroundColor = [UIColor redColor];
        NSString *btnTitle = @"下载";
        if (i == 1) {
            btnTitle = @"暂停";
        } else if (i == 2) {
            btnTitle = @"继续";
        }
        [btn setTitle:btnTitle forState:UIControlStateNormal];
    }
}

- (void)handleBtnAction:(UIButton *)sender {
    if (sender.tag - 3000 == 0) {
        // 只有 download3 支持断点下载
        [self download3];
    } else if (sender.tag - 3000 == 1) {
        [self pauseDownload];
    } else {
        [self resumeDownload];
    }
}

// 文件下载 回调形式
- (void)download1 {
    NSURL *url = [NSURL URLWithString:@"http://192.168.6.150/testDownload.pdf"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            // 创建存储文件路径
            NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            // response.suggestedFilename：建议使用的文件名，一般跟服务器端的文件名一致
            NSString *file = [caches stringByAppendingPathComponent:response.suggestedFilename];
            
            /**将临时文件剪切或者复制到Caches文件夹
             AtPath :剪切前的文件路径
             toPath :剪切后的文件路径
             */
            NSFileManager *manager = [NSFileManager defaultManager];
            [manager moveItemAtPath:location.path toPath:file error:nil];
            NSLog(@"download success");
        } else {
            NSLog(@"download failure");
        }
    }];
    [task resume];
}

// 文件下载 协议形式
- (void)download2 {
    NSURL *url = [NSURL URLWithString:@"http://192.168.6.150/testDownload.pdf"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url];
    [task resume];
}



- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    }
    return _session;
}

// 断点下载
- (void)download3 {
    NSURL *url = [NSURL URLWithString:@"http://192.168.6.150/testDownload.pdf"];
    self.downloadTask = [self.session downloadTaskWithURL:url];
    [self.downloadTask resume];
}

- (void)pauseDownload {
    __weak typeof(self) weakSelf = self;
    [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        weakSelf.resumeData = resumeData;
        weakSelf.downloadTask = nil;
        NSLog(@"cancelByProducingResumeData:%lu", (unsigned long)resumeData.length);
    }];
}

- (void)resumeDownload {
    if (!self.resumeData) {
        NSLog(@"还没开始下载");
        return;
    }
    self.downloadTask = [self.session downloadTaskWithResumeData:self.resumeData];
    [self.downloadTask resume];
}

#pragma mark - NSURLSessionDownloadDelegate
/**
 *  下载完毕后调用
 *
 *  @param location   临时文件的路径（下载好的文件）
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"didFinishDownloadingToURL:%@", location);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needNewBodyStream:(void (^)(NSInputStream * _Nullable))completionHandler {
    NSLog(@"needNewBodyStream");
}

/**
 *  每当下载完一部分时就会调用（可能会被调用多次）
 *
 *  @param bytesWritten  这次调用下载了多少
 *  @param totalBytesWritten   累计写了多少长度到沙盒中了
 *  @param totalBytesExpectedToWrite  文件总大小
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"didWriteData  bytesWritten:%@ totalBytesWritten:%@ totalBytesExpectedToWrite:%@", @(bytesWritten), @(totalBytesWritten), @(totalBytesExpectedToWrite));
}

// 恢复下载时使用（u通常用于断点续传）
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"didResumeAtOffset");
}

- (void)dealloc {
    [self.session invalidateAndCancel];
}

@end
