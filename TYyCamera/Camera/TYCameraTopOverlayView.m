//
//  TYCameraTopOverlayView.m
//  TYyCamera
//
//  Created by Maty on 2018/8/23.
//  Copyright © 2018年 kangarootec. All rights reserved.
//

#import "TYCameraTopOverlayView.h"

@interface TYCameraTopOverlayView ()

/**
 闪光灯 & 手电筒
 */
@property (nonatomic, strong) UIButton *flashAndTorchBtn;

/**
 切换摄像头
 */
@property (nonatomic, strong) UIButton *switchCameraBtn;

@end

@implementation TYCameraTopOverlayView{
    NSArray *_flashImageNames;
    int _clickCount;
}

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
        
        _clickCount = 0;
        _flashImageNames = @[@"闪光灯-关",@"闪光灯-开",@"闪光灯自动",@"手电筒"];
        
    }
    return self;
}

#pragma mark - Method
/**
 * 闪光灯
 */
- (void)flashAndTorchBtnClick:(UIButton *)btn {

    if (_clickCount >3) {
        _clickCount = 0;
    } else {
        NSString *imageName = @"";
        imageName = _flashImageNames[_clickCount];
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        
        if ([[TYCameraControlInstance shareInstance] cameraHasFlash]) {
            
            if ([[TYCameraControlInstance shareInstance] cameraHasTorch]) {
                if ([imageName isEqualToString:@"闪光灯-关"]) {
                    [[TYCameraControlInstance shareInstance] setTorchMode:AVCaptureTorchModeOff];
                    [[TYCameraControlInstance shareInstance] setFlashMode:AVCaptureFlashModeOff];
                } else if ([imageName isEqualToString:@"闪光灯-开"]) {
                    [[TYCameraControlInstance shareInstance] setTorchMode:AVCaptureTorchModeOff];
                    [[TYCameraControlInstance shareInstance] setFlashMode:AVCaptureFlashModeOn];
                } else if ([imageName isEqualToString:@"闪光灯自动"]) {
                    [[TYCameraControlInstance shareInstance] setTorchMode:AVCaptureTorchModeOff];
                    [[TYCameraControlInstance shareInstance] setFlashMode:AVCaptureFlashModeAuto];
                } else if ([imageName isEqualToString:@"手电筒"]) {
                    [[TYCameraControlInstance shareInstance] setTorchMode:AVCaptureTorchModeOn];
                    [[TYCameraControlInstance shareInstance] setFlashMode:AVCaptureFlashModeOff];
                }
            }
            
        }
        
        _clickCount++;
    }
}


/**
 * 切换摄像头
 */
- (void)switchCameraBtnClick:(UIButton *)btn {

    if ([[TYCameraControlInstance shareInstance] canSwitchCameras]) {
        if (![[TYCameraControlInstance shareInstance] switchCameras]) {
            return;
        }
    }
}

#pragma mark - UI
- (void)setupUI {
    [self addSubview:self.flashAndTorchBtn];
    [self.flashAndTorchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(self).offset(20);
        make.width.height.mas_equalTo(30);
    }];
    
    [self addSubview:self.switchCameraBtn];
    [self.switchCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self).offset(-20);
        make.width.height.mas_equalTo(40);
    }];
}

#pragma mark - Lazy Load
- (UIButton *)flashAndTorchBtn {
    if (nil == _flashAndTorchBtn) {
        _flashAndTorchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashAndTorchBtn setImage:[UIImage imageNamed:@"闪光灯-关"] forState:UIControlStateNormal];
        [_flashAndTorchBtn addTarget:self action:@selector(flashAndTorchBtnClick:) forControlEvents:UIControlEventTouchDown];
    }
    return _flashAndTorchBtn;
}

- (UIButton *)switchCameraBtn {
    if (nil == _switchCameraBtn) {
        _switchCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchCameraBtn setImage:[UIImage imageNamed:@"切换摄像头"] forState:UIControlStateNormal];
        [_switchCameraBtn addTarget:self action:@selector(switchCameraBtnClick:) forControlEvents:UIControlEventTouchDown];
    }
    return _switchCameraBtn;
}

@end
