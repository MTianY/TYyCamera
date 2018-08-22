//
//  TYBaseViewController.m
//  TYyCamera
//
//  Created by Maty on 2018/8/21.
//  Copyright © 2018年 kangarootec. All rights reserved.
//

#import "TYBaseViewController.h"
#import "TYCameraPreviewView.h"

@interface TYBaseViewController ()

@property (nonatomic, strong) TYCameraPreviewView *previewView;

@end

@implementation TYBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
   
    self.previewView.captureSession = [TYCameraControlInstance shareInstance].captureSession;
    
    [self setupUI];
    
}




#pragma mark - UI
- (void)setupUI {
    [self.view addSubview:self.previewView];
    [self.previewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
}

#pragma mark - Lazy Load
- (TYCameraPreviewView *)previewView {
    if (nil == _previewView) {
        _previewView = [[TYCameraPreviewView alloc] init];
    }
    return _previewView;
}

@end
