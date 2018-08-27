//
//  TYCameraBottomOverlayView.m
//  TYyCamera
//
//  Created by Maty on 2018/8/23.
//  Copyright © 2018年 kangarootec. All rights reserved.
//

#import "TYCameraBottomOverlayView.h"

@interface TYCameraBottomOverlayView ()

@property (nonatomic, strong) UIButton *photoBtn;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, assign) int recordTime;
@property (nonatomic, strong) UIImageView *photoAlbumImageView;

@end

@implementation TYCameraBottomOverlayView

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TYNotification_CollectionView_ContentOffset_X:) name:@"TYNotification_CollectionView_ContentOffset_X" object:nil];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 通知
- (void)TYNotification_CollectionView_ContentOffset_X:(NSNotification *)notif {
    NSNumber *offsetXNum = notif.object;
    CGFloat offset_X = [offsetXNum floatValue];
    
    [UIView animateWithDuration:0.5 animations:^{
        if (offset_X > 0 && offset_X < (TYSCREEN_WIDTH * 0.5)) {
            
            self.photoBtn.tag = 10;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.photoBtn setImage:[UIImage imageNamed:@"拍照"] forState:UIControlStateNormal];
                self.infoLabel.text = @"拍照";
            });
            
        } else if (offset_X > (TYSCREEN_WIDTH * 0.5) && offset_X < TYSCREEN_WIDTH) {
            
            self.photoBtn.tag = 11;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.photoBtn setImage:[UIImage imageNamed:@"录像"] forState:UIControlStateNormal];
                self.infoLabel.text = @"视频";
            });
            
        }
    }];
    
}


#pragma mark - 定时器
- (void)startTimer {
    dispatch_queue_t queue = dispatch_queue_create("com.maty.timer", DISPATCH_QUEUE_CONCURRENT);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    self.timer = timer;
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(timer, ^{

        weakSelf.recordTime++;
        NSLog(@"%d",weakSelf.recordTime);
        
        dispatch_async(dispatch_get_main_queue(), ^{

            NSString *time = @"";
            if (weakSelf.recordTime < 10) {
                time = [NSString stringWithFormat:@"00:0%d",weakSelf.recordTime];
            } else if (weakSelf.recordTime > 9 && weakSelf.recordTime < 60) {
                time = [NSString stringWithFormat:@"00:%d",weakSelf.recordTime];
            } else if (weakSelf.recordTime == 60) {
                time = [NSString stringWithFormat:@"01:00"];
            } else if (weakSelf.recordTime == 61) {
                
                if ([TYCameraControlInstance shareInstance].isRecording) {
                    [[TYCameraControlInstance shareInstance] stopRecording];
                }
                [weakSelf stopTimer];
                
                [weakSelf.photoBtn setSelected:NO];
                [weakSelf.photoBtn setImage:[UIImage imageNamed:@"录像"] forState:UIControlStateNormal];
                
            }
            weakSelf.infoLabel.text = [NSString stringWithFormat:@"%@",time];

        });
        
    });
    dispatch_resume(timer);
}

- (void)stopTimer {
    if (self.timer) {
        dispatch_source_cancel(self.timer);
    }
}

#pragma mark - Method
- (void)photoBtnClick:(UIButton *)btn {
    
    if (btn.tag == 10) {
        // 拍照
        [[TYCameraControlInstance shareInstance] captureStillImage];
    } else if (btn.tag == 11) {
        btn.selected = !btn.selected;
        if (btn.selected) {
            
            [self startTimer];
            if (![TYCameraControlInstance shareInstance].isRecording) {
                [[TYCameraControlInstance shareInstance] startRecording];

            }
            
            NSLog(@"[NSThread currentThread] = %@",[NSThread currentThread]);
            
        } else {
            
            [self stopTimer];
            if ([TYCameraControlInstance shareInstance].isRecording) {
                [[TYCameraControlInstance shareInstance] stopRecording];

            }
        }
    }
    
}

#pragma mark - UI
- (void)setupUI {
    [self addSubview:self.photoBtn];
    [self.photoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.mas_equalTo(self);
        make.width.height.mas_equalTo(60);
    }];
    
    [self addSubview:self.infoLabel];
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(self).offset(-10);
        make.top.mas_equalTo(self.photoBtn.mas_bottom).offset(5);
    }];
    
    [self addSubview:self.photoAlbumImageView];
    [self.photoAlbumImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(self).offset(20);
        make.width.height.mas_equalTo(60);
    }];
    
}

#pragma mark - Lazy Load
- (UIButton *)photoBtn {
    if (nil == _photoBtn) {
        _photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_photoBtn setImage:[UIImage imageNamed:@"拍照"] forState:UIControlStateNormal];
        [_photoBtn addTarget:self action:@selector(photoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_photoBtn setImage:[UIImage imageNamed:@"停止录制"] forState:UIControlStateSelected];
        _photoBtn.tag = 10;
    }
    return _photoBtn;
}

- (UILabel *)infoLabel {
    if (nil == _infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.textColor = [UIColor orangeColor];
        _infoLabel.font = [UIFont systemFontOfSize:14];
        _infoLabel.text = @"拍照";
    }
    return _infoLabel;
}

- (UIImageView *)photoAlbumImageView {
    if (nil == _photoAlbumImageView) {
        _photoAlbumImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"闪光灯-开"]];
        _photoAlbumImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        _photoAlbumImageView.layer.borderWidth = 1.0f;
    }
    return _photoAlbumImageView;
}

@end
