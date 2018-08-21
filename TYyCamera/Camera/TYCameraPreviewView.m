//
//  TYCameraPreviewView.m
//  TYyCamera
//
//  Created by Maty on 2018/8/21.
//  Copyright © 2018年 kangarootec. All rights reserved.
//

#import "TYCameraPreviewView.h"

@interface TYCameraPreviewView ()

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation TYCameraPreviewView

- (AVCaptureVideoPreviewLayer *)previewLayer {
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

/**
 * 会将捕捉数据直接输出到图层中,并确保与会话状态同步.
 */
- (void)setCaptureSession:(AVCaptureSession *)captureSession {
    [self.previewLayer setSession:captureSession];
}

- (AVCaptureSession *)captureSession {
    return self.previewLayer.session;
}

+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}


@end
