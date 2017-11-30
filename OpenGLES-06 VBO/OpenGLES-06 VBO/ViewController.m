//
//  ViewController.m
//  OpenGLES-06 VBO
//
//  Created by 黎仕仪 on 17/11/6.
//  Copyright © 2017年 shiyi.Li. All rights reserved.
//

#import "ViewController.h"
#import "MyGLView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MyGLView *openGLView = [[MyGLView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:openGLView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
