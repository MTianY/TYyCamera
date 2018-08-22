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

@end

@implementation TYCameraOverlayView

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

#pragma mark - Metdod
- (void)switchCameraBtnClick:(UIButton *)btn {
    if ([[TYCameraControlInstance shareInstance] canSwitchCameras]) {
        [[TYCameraControlInstance shareInstance] switchCameras];
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
    
}

#pragma mark - Lazy Load
- (UIView *)topContainerView {
    if (nil == _topContainerView) {
        _topContainerView = [[UIView alloc] init];
        _topContainerView.backgroundColor = [UIColor orangeColor];
    }
    return _topContainerView;
}

- (UIView *)bottomContainerView {
    if (nil == _bottomContainerView) {
        _bottomContainerView = [[UIView alloc] init];
        _bottomContainerView.backgroundColor = [UIColor orangeColor];
        
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

@end
