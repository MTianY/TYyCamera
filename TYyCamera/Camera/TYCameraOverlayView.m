//
//  TYCameraOverlayView.m
//  TYyCamera
//
//  Created by Maty on 2018/8/22.
//  Copyright © 2018年 kangarootec. All rights reserved.
//

#import "TYCameraOverlayView.h"

@interface TYCameraOverlayView ()

@property (nonatomic, strong) UIView *topContainerView;
@property (nonatomic, strong) UIView *bottomContainerView;

@property (nonatomic, strong) UIButton *switchCameraBtn;
@property (nonatomic, strong) UIButton *flashAndTorchBtn;

@end

@implementation TYCameraOverlayView {
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

#pragma mark - Metdod
// 切换摄像头
- (void)switchCameraBtnClick:(UIButton *)btn {
    if ([[TYCameraControlInstance shareInstance] canSwitchCameras]) {
        [[TYCameraControlInstance shareInstance] switchCameras];
    }
}

// 闪光灯
- (void)flashBtnClick:(UIButton *)btn {
    
}

- (void)flashAndTorchBtnClick:(UIButton *)btn {
    
    NSLog(@"_clickCount = %d",_clickCount);
    
    if (_clickCount >3) {
        _clickCount = 0;
    } else {
        NSString *imageName = @"";
        imageName = _flashImageNames[_clickCount];
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        _clickCount++;
    }
    
    
    
}

#pragma mark - UI
- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.topContainerView];
    [self.topContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self);
        make.height.mas_equalTo(60);
    }];
    
    [self addSubview:self.bottomContainerView];
    [self.bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self);
        make.height.mas_equalTo(90);
    }];
    
    [self.bottomContainerView addSubview:self.switchCameraBtn];
    [self.switchCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bottomContainerView);
        make.right.mas_equalTo(self.bottomContainerView).offset(-20);
        make.width.height.mas_equalTo(40);
    }];
    
    [self.topContainerView addSubview:self.flashAndTorchBtn];
    [self.flashAndTorchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topContainerView);
        make.left.mas_equalTo(self.topContainerView).offset(20);
        make.width.height.mas_equalTo(25);
    }];
    
}

#pragma mark - Lazy Load
- (UIView *)topContainerView {
    if (nil == _topContainerView) {
        _topContainerView = [[UIView alloc] init];
        _topContainerView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    
    }
    return _topContainerView;
}

- (UIView *)bottomContainerView {
    if (nil == _bottomContainerView) {
        _bottomContainerView = [[UIView alloc] init];
        _bottomContainerView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        
    }
    return _bottomContainerView;
}

- (UIButton *)switchCameraBtn {
    if (nil == _switchCameraBtn) {
        _switchCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchCameraBtn setImage:[UIImage imageNamed:@"切换摄像头"] forState:UIControlStateNormal];
        [_switchCameraBtn addTarget:self action:@selector(switchCameraBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCameraBtn;
}

- (UIButton *)flashAndTorchBtn {
    if (nil == _flashAndTorchBtn) {
        _flashAndTorchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashAndTorchBtn setImage:[UIImage imageNamed:@"闪光灯-关"] forState:UIControlStateNormal];
        [_flashAndTorchBtn addTarget:self action:@selector(flashAndTorchBtnClick:) forControlEvents:UIControlEventTouchDown];
    }
    return _flashAndTorchBtn;
}

@end
