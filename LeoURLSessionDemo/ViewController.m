//
//  ViewController.m
//  LeoURLSessionDemo
//
//  Created by leo on 2019/10/10.
//  Copyright © 2019 leo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *vcArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSArray *vcArr = @[@"GetVC", @"PostVC", @"DownloadVC", @"UploadVC"];
    self.vcArr = [NSMutableArray arrayWithArray:vcArr];
    CGFloat width = 150;
    CGFloat height = 40;
    CGFloat btnX = ([UIScreen mainScreen].bounds.size.width - width) / 2.0;
    for (int i = 0; i < vcArr.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(btnX, 100 + (height + 30) * i, width, height);
        [self.view addSubview:btn];
        [btn addTarget:self action:@selector(handleBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 1000 + i;
        btn.backgroundColor = [UIColor redColor];
        [btn setTitle:vcArr[i] forState:UIControlStateNormal];
    }
}

- (void)handleBtnAction:(UIButton *)sender {
    NSInteger index = sender.tag - 1000;
    if (index >= 0 && index < self.vcArr.count) {
        NSString *vcStr = self.vcArr[index];
        Class vcc = NSClassFromString(vcStr);
        UIViewController *vc = [[vcc alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end
