//
//  TYSeeBigPhotoOverlayView.m
//  TYyCamera
//
//  Created by Maty on 2018/8/30.
//  Copyright © 2018年 kangarootec. All rights reserved.
//

#import "TYSeeBigPhotoOverlayView.h"

@interface TYSeeBigPhotoOverlayView ()

@property (nonatomic, strong) UIView *topContainerView;
@property (nonatomic, strong) UIView *bottomContainerView;
@property (nonatomic, strong) UIButton *dismissBtn;

@end

@implementation TYSeeBigPhotoOverlayView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
        [self addGestureRecognizer:tapGes];
        
    }
    return self;
}

- (void)tapGes:(UITapGestureRecognizer *)tap {
    [UIView animateWithDuration:0.25 animations:^{
        self.hidden = !self.hidden;
    }];
}

- (void)dismissBtnClick {
    if ([self.delegate respondsToSelector:@selector(ty_dismissBtnClick)]) {
        [self.delegate ty_dismissBtnClick];
    }
}

#pragma mark - UI
- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.topContainerView];
    [self.topContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    [self addSubview:self.bottomContainerView];
    [self.bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    [self.topContainerView addSubview:self.dismissBtn];
    [self.dismissBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topContainerView);
        make.left.mas_equalTo(self.topContainerView).offset(20);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(30);
    }];
    
}

#pragma mark - Lazy Load
- (UIView *)topContainerView {
    if (nil == _topContainerView) {
        _topContainerView = [[UIView alloc] init];
        _topContainerView.backgroundColor = [UIColor whiteColor];
    }
    return _topContainerView;
}

- (UIView *)bottomContainerView {
    if (nil == _bottomContainerView) {
        _bottomContainerView = [[UIView alloc] init];
        _bottomContainerView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomContainerView;
}

- (UIButton *)dismissBtn {
    if (nil == _dismissBtn) {
        _dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dismissBtn setTitle:@"Dismiss" forState:UIControlStateNormal];
        [_dismissBtn addTarget:self action:@selector(dismissBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_dismissBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _dismissBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _dismissBtn;
}

@end
