//
//  GetVC.m
//  LeoUrlRequestDemo
//
//  Created by leo on 2019/10/10.
//  Copyright © 2019 leo. All rights reserved.
//

#import "GetVC.h"

@interface GetVC () <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSMutableData *responseData;

@end

@implementation GetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSStringFromClass([self class]);
    
    CGFloat width = 150;
    CGFloat height = 40;
    CGFloat btnX = ([UIScreen mainScreen].bounds.size.width - width) / 2.0;
    for (int i = 0; i < 1; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(btnX, 200 + (height + 30) * i, width, height);
        [self.view addSubview:btn];
        [btn addTarget:self action:@selector(handleBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 3000 + i;
        btn.backgroundColor = [UIColor redColor];
        NSString *btnTitle = @"Get";
        [btn setTitle:btnTitle forState:UIControlStateNormal];
    }
}

- (void)handleBtnAction:(UIButton *)sender {
    [self get3];
}

// 第一种方式 回调
- (void)get1 {
    NSURL *url = [NSURL URLWithString:@"http://192.168.6.150/testGet.png"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            if (data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *img = [UIImage imageWithData:data];
                    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
                    imgView.frame = CGRectMake(100, 300, 100, 100);
                    [self.view addSubview:imgView];
                });
                NSLog(@"get1 success");
            }
        } else {
            NSLog(@"get1 error:%@", error);
        }
    }];
    [task resume];
}

// 第二种方式 回调
- (void)get2 {
    NSURL *url = [NSURL URLWithString:@"http://192.168.6.150/testGet1.png"];
    // 可以对request做超时等各种设置
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//    config.timeoutIntervalForRequest = 3;
    config.timeoutIntervalForResource = 3;
//    NSURLSession *session = [NSURLSession sharedSession];
    config.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    // 告诉服务器我的设备
    config.HTTPAdditionalHeaders = @{@"User-Agent": @"iPhone"};
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            if (data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *img = [UIImage imageWithData:data];
                    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
                    imgView.frame = CGRectMake(100, 300, 100, 100);
                    [self.view addSubview:imgView];
                });
                NSLog(@"get2 success");
            }
        } else {
            NSLog(@"get2 error:%@", error);
        }
    }];
    [task resume];
}

// 协议方式
- (void)get3 {
    NSURL *url = [NSURL URLWithString:@"http://192.168.6.150/testGet.png"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForResource = 8;
    config.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    config.HTTPAdditionalHeaders = @{@"User-Agent": @"iPhone"};
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url];
    [task resume];
}


//1.接收到服务器响应的时候调用该方法
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    //注意：需要使用completionHandler回调告诉系统应该如何处理服务器返回的数据
    //默认是取消的
    /*
     NSURLSessionResponseCancel = 0,        默认的处理方式，取消
     NSURLSessionResponseAllow = 1,         接收服务器返回的数据
     NSURLSessionResponseBecomeDownload = 2,变成一个下载请求
     NSURLSessionResponseBecomeStream        变成一个流
     */
    
    completionHandler(NSURLSessionResponseAllow);
    NSLog(@"didReceiveResponse");
}

//2.接收到服务器返回数据的时候会调用该方法，如果数据较大那么该方法可能会调用多次
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (!self.responseData) {
        self.responseData = [NSMutableData data];
    }
    [self.responseData appendData:data];
    NSLog(@"didReceiveData:%lu", (unsigned long)data.length);
}

//3.当请求完成(成功|失败)的时候会调用该方法，如果请求失败，则error有值
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (!error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *img = [UIImage imageWithData:self.responseData];
            UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
            imgView.frame = CGRectMake(100, 300, 100, 100);
            [self.view addSubview:imgView];
        });
    }
    NSLog(@"didCompleteWithError");
}

@end
