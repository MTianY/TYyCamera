//
//  TYPhotoView.m
//  TYyCamera
//
//  Created by Maty on 2018/8/27.
//  Copyright © 2018年 kangarootec. All rights reserved.
//

#import "TYPhotoView.h"

@interface TYPhotoView ()

@property (nonatomic, strong) UIImageView *imageV;

@end

@implementation TYPhotoView

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
        [self setupUI];
    }
    return self;
}

#pragma mark - UI
- (void)setupUI {
    [self addSubview:self.imageV];
    [self.imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(self);
    }];
}

#pragma mark - Lazy Load
- (UIImageView *)imageV {
    if (nil == _imageV) {
        _imageV = [[UIImageView alloc] initWithImage:self.photoImage];
    }
    return _imageV;
}

@end
