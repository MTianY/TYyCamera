//
//  TYCameraControlInstance.h
//  TYyCamera
//
//  Created by Maty on 2018/8/21.
//  Copyright © 2018年 kangarootec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

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

#pragma mark - 切换摄像头
/**
 * 是否超过一个摄像头
 */
- (BOOL)canSwitchCameras;
/**
 * 切换摄像头
 */
- (void)switchCameras;

#pragma mark - 点击对焦
- (BOOL)canCameraSupportsTapToFocus;
- (void)focusAtPoint:(CGPoint)point;

#pragma mark - 点击曝光
- (BOOL)canCameraSupportsTapToExpose;
- (void)exposeAtPoint:(CGPoint)point;
- (void)resetFocusAndExposureModes;

@end
