//
//  TYSeeBigCollectionViewCell.m
//  TYyCamera
//
//  Created by Maty on 2018/8/30.
//  Copyright © 2018年 kangarootec. All rights reserved.
//

#import "TYSeeBigCollectionViewCell.h"

@interface TYSeeBigCollectionViewCell ()
@property (nonatomic, strong) UIImageView *bigImageV;
@end

@implementation TYSeeBigCollectionViewCell

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

#pragma mark - SET
- (void)setAsset:(PHAsset *)asset {
    _asset = asset;
    
    
    
    [[TYPhotoTool shareInstance] getImageFromAssetWithPHAsset:asset andTargetSize:CGSizeMake(TYSCREEN_WIDTH, TYSCREEN_HEIGHT) andResultHandler:^(UIImage *result, NSDictionary *resultHandler) {
        self.bigImageV.image = result;
    }];
    
}

#pragma mark - UI
- (void)setupUI {
    
    self.backgroundColor = [UIColor blackColor];
    
    [self addSubview:self.bigImageV];
    [self.bigImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(self);
    }];
}

#pragma mark - Lazy Load
- (UIImageView *)bigImageV {
    if (nil == _bigImageV) {
        _bigImageV = [[UIImageView alloc] init];
    }
    return _bigImageV;
}

@end
