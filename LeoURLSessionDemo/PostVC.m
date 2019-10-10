//
//  PostVC.m
//  LeoUrlRequestDemo
//
//  Created by leo on 2019/10/10.
//  Copyright © 2019 leo. All rights reserved.
//

#import "PostVC.h"

@interface PostVC ()

@end

@implementation PostVC

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
    [self post1];
}

- (void)post1 {
    NSURL *url = [NSURL URLWithString:@""];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *paramsStr = @"username:leo&pwd:123&type=JSON";
    request.HTTPBody = [paramsStr dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"post1 success: %@",dict);
        } else {
            NSLog(@"post1 error:%@", error);
        }
    }];
    [task resume];
}

@end
