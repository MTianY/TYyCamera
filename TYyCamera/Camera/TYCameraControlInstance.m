//
//  TYCameraControlInstance.m
//  TYyCamera
//
//  Created by Maty on 2018/8/21.
//  Copyright © 2018年 kangarootec. All rights reserved.
//

#import "TYCameraControlInstance.h"
#import <Photos/Photos.h>

@interface TYCameraControlInstance () <
AVCaptureFileOutputRecordingDelegate,
AVCaptureMetadataOutputObjectsDelegate
>

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
/**
 * 当前被激活的输入设备
 */
@property (nonatomic, strong) AVCaptureDeviceInput *activeVideoInput;
/**
 * 摄像头数量
 */
@property (nonatomic, readonly) NSUInteger cameraCount;

@property (nonatomic, strong) NSURL *outputURL;

@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;

@property (nonatomic, strong) NSMutableArray *imageIDsMutArray;

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
- (BOOL)switchCameras {
    
    if (![self canSwitchCameras]) {
        return NO;
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
        NSLog(@"%@",error);
        return NO;
    }
    
    return YES;
}

#pragma mark - 点击对焦
/**
 * 询问是否支持兴趣点对焦
 */
- (BOOL)canCameraSupportsTapToFocus {
    return [[self activeCamera] isFocusPointOfInterestSupported];
}

/**
 * 点击对焦
 * point 首先要从屏幕坐标系转为捕捉设备坐标.
 */
- (void)focusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [self activeCamera];
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        } else {
            NSLog(@"%@",error);
        }
    }
}

#pragma mark - 点击曝光
/**
 * 询问是否支持点击曝光
 */
- (BOOL)canCameraSupportsTapToExpose {
    return [[self activeCamera] isExposurePointOfInterestSupported];
}

/**
 * 点击曝光
 */
- (void)exposeAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [self activeCamera];
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    if (device.isExposurePointOfInterestSupported) {
        [device isExposureModeSupported:exposureMode];
        
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.exposurePointOfInterest = point;
            device.exposureMode = exposureMode;
            if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                [device addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:nil];
            }
            [device unlockForConfiguration];
        } else {
            NSLog(@"%@",error);
        }
        
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    AVCaptureDevice *device = (AVCaptureDevice *)object;
    if (!device.isAdjustingExposure && [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
        [object removeObserver:self forKeyPath:@"adjustingExposure" context:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error;
            if ([device lockForConfiguration:&error]) {
                device.exposureMode = AVCaptureExposureModeLocked;
                [device unlockForConfiguration];
            } else {
                NSLog(@"%@",error);
            }
        });
        
    }
}

/**
 * 切换回连续对焦和曝光模式
 * 中心店对焦和曝光(centerPoint)
 */
- (void)resetFocusAndExposureModes {
    AVCaptureDevice *device = [self activeCamera];
    
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    BOOL canResetFocus = [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode];
    
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    BOOL canResetExposure = [device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode];
    
    CGPoint centerPoint = CGPointMake(0.5f, 0.5f);
    
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if (canResetFocus) {
            device.focusMode = focusMode;
            device.focusPointOfInterest = centerPoint;
        }
        if (canResetExposure) {
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centerPoint;
        }
        [device unlockForConfiguration];
    } else {
        NSLog(@"%@",error);
    }
    
}

#pragma mark - 闪光灯&手电筒模式
/**
 * 是否支持闪光灯模式
 */
- (BOOL)cameraHasFlash {
    return [[self activeCamera] hasFlash];
}

- (AVCaptureFlashMode)flashMode {
    return [[self activeCamera] flashMode];
}

/**
 * 设置闪光模式:开|关|自动
 */
- (void)setFlashMode:(AVCaptureFlashMode)flashMode {
    AVCaptureDevice *device = [self activeCamera];
    if ([device isFlashModeSupported:flashMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        } else {
            NSLog(@"%@",error);
        }
    }
}

/**
 * 是否支持手电筒模式
 */
- (BOOL)cameraHasTorch {
    return [[self activeCamera] hasTorch];
}

- (AVCaptureTorchMode)torchMode {
    return [[self activeCamera] torchMode];
}

/**
 * 设置手电筒模式: 开|关|自动
 */
- (void)setTorchMode:(AVCaptureTorchMode)torchMode {
    AVCaptureDevice *device = [self activeCamera];
    if ([device isTorchModeSupported:torchMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        } else {
            NSLog(@"%@",error);
        }
    }
}

#pragma mark - 拍照
- (void)captureStillImage {
    AVCaptureConnection *connection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (connection.isVideoOrientationSupported) {
        connection.videoOrientation = [self currentVideoOrientation];
    }
    __weak typeof(self) weakSelf = self;
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        if (imageDataSampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            
            // 写入相册
            [weakSelf writeImageToPhotoAlbum:image];
            
        } else {
            NSLog(@"%@",[error localizedDescription]);
        }
    }];
}

// 写入图片至相册
- (void)writeImageToPhotoAlbum:(UIImage *)image {
    NSMutableArray *imageIDs = [NSMutableArray array];
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // 写入图片到相册
        PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        // 记录本地标识,等待完成后取出相册中的图片对象
        [imageIDs addObject:request.placeholderForCreatedAsset.localIdentifier];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {

            [[NSNotificationCenter defaultCenter] postNotificationName:@"TYNotification_Photo_Success" object:nil];

            // 取图片
            __block PHAsset *imageAsset = nil;
            PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:imageIDs options:nil];
            [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                imageAsset = obj;
                *stop = YES;
            }];
            if (imageAsset) {
                // 加载图片数据
                [[PHImageManager defaultManager] requestImageDataForAsset:imageAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    NSLog(@"%@",imageData);


                }];
            }
        }
    }];
}


- (AVCaptureVideoOrientation)currentVideoOrientation {
    AVCaptureVideoOrientation orientation;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationFaceDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    return orientation;
}

#pragma mark - 视频捕捉
- (BOOL)isRecording {
    return self.movieOutput.isRecording;
}

- (void)startRecording {
    if (![self isRecording]) {
        
        NSLog(@"startRecording  --%@",[NSThread currentThread]);
        
        AVCaptureConnection *videoConnection = [self.movieOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([videoConnection isVideoOrientationSupported]) {
            videoConnection.videoOrientation = [self currentVideoOrientation];
        }
        if ([videoConnection isVideoStabilizationSupported]) {
            videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
        AVCaptureDevice *device = [self activeCamera];
        if (device.isSmoothAutoFocusSupported) {
            NSError *error;
            if ([device lockForConfiguration:&error]) {
                device.smoothAutoFocusEnabled = YES;
                [device unlockForConfiguration];
            } else {
                NSLog(@"%@",error);
            }
        }
        self.outputURL = [self uniqueURL];
        [self.movieOutput startRecordingToOutputFileURL:self.outputURL recordingDelegate:self];

    }
}

- (NSURL *)uniqueURL {
    NSArray *doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = doc.firstObject;
    NSString *filePath = [docPath stringByAppendingPathComponent:@"camera_movie.mov"];
    return [NSURL fileURLWithPath:filePath];
}

- (void)stopRecording {
    if (self.isRecording) {
        [self.movieOutput stopRecording];
    }
}

#pragma mark <AVCaptureFileOutputRecordingDelegate>
- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error {
    if (error) {
        NSLog(@"%@",error);
    } else {
        // 保留视频到相册
        [TYPhotoManger saveVideo:[self.outputURL copy] albumTitle:@"TYVideo" completionHandler:^(BOOL success, NSError *error) {
            
        }];
    }
    self.outputURL = nil;
}

#pragma mark - 缩放
// 如果 activeFormat 的 videoMaxZoomFactor 的值大于1.0.则捕捉设备支持缩放功能.
- (BOOL)cameraSupportZoom {
    return [self activeCamera].activeFormat.videoMaxZoomFactor > 1.0f;
}

- (CGFloat)maxZoomFactor {
    NSLog(@"[self activeCamera].activeFormat.videoMaxZoomFactor = %f",[self activeCamera].activeFormat.videoMaxZoomFactor);
    return MIN([self activeCamera].activeFormat.videoMaxZoomFactor, 4.0f);
}

- (void)setZoomValue:(CGFloat)zoomValue {
    if (![self activeCamera].isRampingVideoZoom) {
        NSError *error;
        if ([[self activeCamera] lockForConfiguration:&error]) {
            
            CGFloat zoomFactor = pow([self maxZoomFactor], zoomValue);
            
            
            NSLog(@"zoomValue = %f",zoomValue);
            NSLog(@"zoomFactor = %f",zoomFactor);
            NSLog(@"maxZoomFactor = %f",[self maxZoomFactor]);
            NSLog(@"[self activeCamera].videoZoomFactor = %f",[self activeCamera].videoZoomFactor);
            NSLog(@"-------------------------------------\n\n");
            
            
            if (zoomFactor > 16) {
                return;
            }
            
            [self activeCamera].videoZoomFactor = zoomFactor;
            [[self activeCamera] unlockForConfiguration];
        } else {
            NSLog(@"%@",error);
        }
    }
}


#pragma mark - 人脸检测
- (BOOL)setupSessionOutputs:(NSError *)error {
    self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    if ([self.captureSession canAddOutput:self.metadataOutput]) {
        [self.captureSession addOutput:self.metadataOutput];
        
        NSArray *metadataObjectTypes = @[AVMetadataObjectTypeFace];
        self.metadataOutput.metadataObjectTypes = metadataObjectTypes;
        
        [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        return YES;
        
    } else {
        if (error) {
            NSLog(@"%@",error);
        }
        return NO;
    }
}

#pragma mark - <AVCaptureMetadataOutputObjectsDelegate>
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    for (AVMetadataFaceObject *faceObj in metadataObjects) {
//        NSLog(@"%li",faceObj.faceID);
//        NSLog(@"%@",NSStringFromCGRect(faceObj.bounds));
    }
    if ([self.faceDetectionDelegate respondsToSelector:@selector(didDetectFaces:)]) {
        [self.faceDetectionDelegate didDetectFaces:metadataObjects];
    }
    // 自动对焦,曝光
    [[TYCameraControlInstance shareInstance] resetFocusAndExposureModes];
}


#pragma mark - Lazy Load
- (NSMutableArray *)imageIDsMutArray {
    if (nil == _imageIDsMutArray) {
        _imageIDsMutArray = [NSMutableArray array];
    }
    return _imageIDsMutArray;
}

@end
