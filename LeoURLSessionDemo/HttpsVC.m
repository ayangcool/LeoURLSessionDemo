//
//  HttpsVC.m
//  LeoURLSessionDemo
//
//  Created by leo on 2019/10/10.
//  Copyright © 2019 leo. All rights reserved.
//

#import "HttpsVC.h"

@interface HttpsVC () <NSURLSessionDataDelegate>

@end

@implementation HttpsVC

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
    [self get1];
}

- (void)get1 {
    NSURL *url = [NSURL URLWithString:@"https://kyfw.12306.cn/otn"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
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
    [task resume];}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    if (![challenge.protectionSpace.authenticationMethod isEqualToString:@"NSURLAuthenticationMethodServerTrust"]) {
        return;
    }
    NSLog(@"%@",challenge.protectionSpace);
    //NSURLSessionAuthChallengeDisposition 如何处理证书
    /*
     NSURLSessionAuthChallengeUseCredential = 0, 使用该证书 安装该证书
     NSURLSessionAuthChallengePerformDefaultHandling = 1, 默认采用的方式,该证书被忽略
     NSURLSessionAuthChallengeCancelAuthenticationChallenge = 2, 取消请求,证书忽略
     NSURLSessionAuthChallengeRejectProtectionSpace = 3,          拒绝
     */
    NSURLCredential *credential = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
    
    //NSURLCredential 授权信息
    completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
}

@end
