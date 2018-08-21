//
//  TYCameraControlInstance.m
//  TYyCamera
//
//  Created by Maty on 2018/8/21.
//  Copyright © 2018年 kangarootec. All rights reserved.
//

#import "TYCameraControlInstance.h"

@interface TYCameraControlInstance ()

/**
 * 会话
 */
@property (nonatomic, strong) AVCaptureSession *captureSession;
/**
 * 从摄像头捕捉静态图片
 */
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;
/**
 * 从摄像头捕捉视频
 */
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieOutput;

@property (nonatomic, strong) dispatch_queue_t videoQueue;

@property (nonatomic, strong) AVCaptureDeviceInput *activeVideoInput;
@property (nonatomic, readonly) NSUInteger cameraCount;

@end

@implementation TYCameraControlInstance

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static TYCameraControlInstance *_instance;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        NSError *error;
        if ([self setupSession:error]) {
            [self startSession];
        } else {
            NSLog(@"%@",error);
        }
    }
    return self;
}

#pragma mark - 会话配置部分
- (BOOL)setupSession:(NSError *)error {
    
    self.captureSession = [[AVCaptureSession alloc] init];
    // 输出的质量等级
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    // 1. 设置视频捕捉设备
    // 获取默认的视频捕捉的默认设备(默认后置摄像头)
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 在将捕捉设备添加到会话之前,要先将它封装成一个 AVCaptureDeviceInput 对象.
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    // 添加到会话
    if (videoInput) {
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        }
    } else {
        return NO;
    }
    
    // 2.设置音频捕捉设备
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    if (audioInput) {
        if ([self.captureSession canAddInput:audioInput]) {
            [self.captureSession addInput:audioInput];
        } else {
            return NO;
        }
    }
    
    // 3.从摄像头捕捉静态图片
    if ([self.captureSession canAddOutput:self.imageOutput]) {
        [self.captureSession addOutput:self.imageOutput];
    }
    
    // 4.从摄像头捕捉视频
    if ([self.captureSession canAddOutput:self.movieOutput]) {
        [self.captureSession addOutput:self.movieOutput];
    }
    
    self.videoQueue = dispatch_queue_create("com.mty.videoQueue", NULL);
    
    return YES;
}

- (void)startSession {
    if (![self.captureSession isRunning]) {
        dispatch_async(self.videoQueue, ^{
            [self.captureSession startRunning];
        });
    }
}

- (void)stopSession {
    if ([self.captureSession isRunning]) {
        dispatch_async(self.videoQueue, ^{
            [self.captureSession stopRunning];
        });
    }
}

#pragma mark - 摄像头
/**
 * 返回指定位置的设备.(前置 or 后置)
 */
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

/**
 * 返回当前捕捉会话对应的摄像头,返回激活的捕捉设备输入的 device 属性
 */
- (AVCaptureDevice *)activeCamera {
    return self.activeVideoInput.device;
}

/**
 * 返回未被激活的摄像头.(如果设备只有一个摄像头,返回 nil)
 */
- (AVCaptureDevice *)inactiveCamera {
    AVCaptureDevice *device = nil;
    if (self.cameraCount > 1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

/**
 * 是否超过一个摄像头,为切换摄像头做准备
 */
- (BOOL)canSwitchCameras {
    return self.cameraCount > 1;
}

/**
 * 返回可用视频捕捉设备的数量
 */
- (NSUInteger)cameraCount {
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

#pragma mark - Lazy Load
- (AVCaptureStillImageOutput *)imageOutput {
    if (nil == _imageOutput) {
        _imageOutput = [[AVCaptureStillImageOutput alloc] init];
        _imageOutput.outputSettings = @{
                                        AVVideoCodecKey : AVVideoCodecJPEG
                                        };
    }
    return _imageOutput;
}

- (AVCaptureMovieFileOutput *)movieOutput {
    if (nil == _movieOutput) {
        _movieOutput = [[AVCaptureMovieFileOutput alloc] init];
    }
    return _movieOutput;
}

#pragma mark 切换摄像头
- (void)switchCameras {
    if (![self canSwitchCameras]) {
        return;
    }
    
    // 获取未激活的摄像头
    NSError *error;
    AVCaptureDevice *videoDevice = [self inactiveCamera];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (videoInput) {
        [self.captureSession beginConfiguration];
        [self.captureSession removeInput:self.activeVideoInput];
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        } else {
            [self.captureSession addInput:self.activeVideoInput];
        }
        [self.captureSession commitConfiguration];
    } else {
        
    }
    
}

@end