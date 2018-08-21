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

@end
