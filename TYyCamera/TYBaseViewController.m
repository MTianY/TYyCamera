//
//  TYBaseViewController.m
//  TYyCamera
//
//  Created by Maty on 2018/8/21.
//  Copyright © 2018年 kangarootec. All rights reserved.
//

#import "TYBaseViewController.h"
#import "TYCameraPreviewView.h"
#import "TYCameraTopOverlayView.h"

@interface TYBaseViewController ()

@property (nonatomic, strong) TYCameraPreviewView *previewView;
@property (nonatomic, strong) TYCameraTopOverlayView *topOverlayView;

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
    
    [self.view addSubview:self.topOverlayView];
    [self.topOverlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(100);
    }];
    
}

#pragma mark - Lazy Load
- (TYCameraPreviewView *)previewView {
    if (nil == _previewView) {
        _previewView = [[TYCameraPreviewView alloc] init];
    }
    return _previewView;
}
- (TYCameraTopOverlayView *)topOverlayView {
    if (nil == _topOverlayView) {
        _topOverlayView = [[TYCameraTopOverlayView alloc] init];
    }
    return _topOverlayView;
}

@end
