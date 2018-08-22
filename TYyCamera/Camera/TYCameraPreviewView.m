//
//  TYCameraPreviewView.m
//  TYyCamera
//
//  Created by Maty on 2018/8/21.
//  Copyright © 2018年 kangarootec. All rights reserved.
//

#import "TYCameraPreviewView.h"
#import "TYCameraOverlayView.h"

@interface TYCameraPreviewView ()

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) TYCameraOverlayView *overlayView;


@end

@implementation TYCameraPreviewView

- (AVCaptureVideoPreviewLayer *)previewLayer {
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

/**
 * 会将捕捉数据直接输出到图层中,并确保与会话状态同步.
 */
- (void)setCaptureSession:(AVCaptureSession *)captureSession {
    [(AVCaptureVideoPreviewLayer *)self.layer setSession:captureSession];
}

- (AVCaptureSession *)captureSession {
    return [(AVCaptureVideoPreviewLayer *)self.layer session];
}

+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self setupUI];
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesMethod:)];
        NSLog(@"%@",[self class]);
        [self addGestureRecognizer:tapGes];
        
    }
    return self;
}

#pragma mark - 点击对焦
- (void)tapGesMethod:(UITapGestureRecognizer *)tap {
    NSLog(@"Tap---%@",[self class]);
    CGPoint tapScreenPoint = [tap locationInView:self];
    CGPoint equipmentPoint = [self screenCoordinateSystemPointToEquipmentCoordinateSystemPoint:tapScreenPoint];
    if ([[TYCameraControlInstance shareInstance] canCameraSupportsTapToFocus]) {
        [[TYCameraControlInstance shareInstance] focusAtPoint:equipmentPoint];
    }
    if ([[TYCameraControlInstance shareInstance] canCameraSupportsTapToExpose]) {
        [[TYCameraControlInstance shareInstance] exposeAtPoint:equipmentPoint];
    }
}

/**
 * 将屏幕坐标系上的触控点转为设备坐标系的点
 */
- (CGPoint)screenCoordinateSystemPointToEquipmentCoordinateSystemPoint:(CGPoint)point {
    AVCaptureVideoPreviewLayer *layer = (AVCaptureVideoPreviewLayer *)self.layer;
    return [layer captureDevicePointOfInterestForPoint:point];
}

#pragma mark - UI
- (void)setupUI {
    [self addSubview:self.overlayView];
    [self.overlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    

    
}

#pragma mark - Lazy Load
- (TYCameraOverlayView *)overlayView {
    if (nil == _overlayView) {
        _overlayView = [[TYCameraOverlayView alloc] init];
    }
    return _overlayView;
}

@end
