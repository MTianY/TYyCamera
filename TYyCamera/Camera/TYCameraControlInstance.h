//
//  TYCameraControlInstance.h
//  TYyCamera
//
//  Created by Maty on 2018/8/21.
//  Copyright © 2018年 kangarootec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol TYFaceDetectionDelegate <NSObject>
- (void)didDetectFaces:(NSArray *)faces;
@end

@interface TYCameraControlInstance : NSObject

+ (instancetype)shareInstance;

#pragma mark - 会话配置
@property (nonatomic, strong, readonly) AVCaptureSession *captureSession;
/**
 * 配置会话
 */
- (BOOL)setupSession:(NSError *)error;
/**
 * 启动会话
 */
- (void)startSession;
/**
 * 结束会话
 */
- (void)stopSession;

#pragma mark - 获取活跃的摄像头
/**
 * 返回当前捕捉会话对应的摄像头,返回激活的捕捉设备输入的 device 属性
 */
- (AVCaptureDevice *)activeCamera;

#pragma mark - 切换摄像头
/**
 * 是否超过一个摄像头
 */
- (BOOL)canSwitchCameras;
/**
 * 切换摄像头
 */
- (BOOL)switchCameras;

#pragma mark - 点击对焦
/**
 * 是否支持点击对焦
 */
- (BOOL)canCameraSupportsTapToFocus;
/**
 * 点击对焦
 */
- (void)focusAtPoint:(CGPoint)point;

#pragma mark - 点击曝光
/**
 * 是否支持点击曝光
 */
- (BOOL)canCameraSupportsTapToExpose;
/**
 * 点击曝光
 */
- (void)exposeAtPoint:(CGPoint)point;
/**
 * 重置聚焦和曝光
 * 连接聚焦和曝光(从中心点扩散)
 */
- (void)resetFocusAndExposureModes;

#pragma mark - 闪光灯 & 手电筒
/**
 * 闪光灯模式
 */
@property (nonatomic) AVCaptureFlashMode flashMode;
/**
 * 手电筒模式
 */
@property (nonatomic) AVCaptureTorchMode torchMode;
/**
 * 判断是否支持闪光灯
 */
- (BOOL)cameraHasFlash;
/**
 * 判断是否支持手电筒
 */
- (BOOL)cameraHasTorch;

#pragma mark - 拍照
/**
 * 拍照
 */
- (void)captureStillImage;

#pragma mark - 录像
/**
 * 是否正在录像
 */
- (BOOL)isRecording;
/**
 * 开始录像
 */
- (void)startRecording;
/**
 * 结束录像
 */
- (void)stopRecording;

#pragma mark - 缩放
/**
 * 是否支持缩放
 */
- (BOOL)cameraSupportZoom;
/**
 * 缩放
 */
- (void)setZoomValue:(CGFloat)zoomValue;

#pragma mark - 人脸检测
@property (nonatomic, weak) id<TYFaceDetectionDelegate> faceDetectionDelegate;
/**
 * 配置 AVCaptureMetadataOutput
 */
- (BOOL)setupSessionOutputs:(NSError *)error;

@end
