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
#import "TYCameraBottomOverlayView.h"
#import "TYPhotoView.h"

@interface TYBaseViewController ()

@property (nonatomic, strong) TYCameraPreviewView *previewView;
@property (nonatomic, strong) TYCameraTopOverlayView *topOverlayView;
@property (nonatomic, strong) TYCameraBottomOverlayView *bottomOverlayView;

@property (nonatomic, strong) TYPhotoView *photoView;

@end

@implementation TYBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
   
    self.previewView.captureSession = [TYCameraControlInstance shareInstance].captureSession;
    
    [self setupUI];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TYNotification_Photo_SuccessMethod:) name:@"TYNotification_Photo_Success" object:nil];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Method
- (void)TYNotification_Photo_SuccessMethod:(NSNotification *)notif {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"拍照成功----%@",[NSThread currentThread]);
        [self.view addSubview:self.photoView];
        [self.photoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.mas_equalTo(self.view);
        }];
    });
    

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.photoView removeFromSuperview];
    });
    
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
    
    [self.view addSubview:self.bottomOverlayView];
    [self.bottomOverlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self.view);
        make.height.mas_equalTo(120);
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

- (TYCameraBottomOverlayView *)bottomOverlayView {
    if (nil == _bottomOverlayView) {
        _bottomOverlayView = [[TYCameraBottomOverlayView alloc] init];
    }
    return _bottomOverlayView;
}

- (TYPhotoView *)photoView {
    if (nil == _photoView) {
        _photoView = [[TYPhotoView alloc] init];
    }
    return _photoView;
}

@end
