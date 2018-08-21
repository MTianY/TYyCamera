//
//  TYCameraPreviewView.h
//  TYyCamera
//
//  Created by Maty on 2018/8/21.
//  Copyright © 2018年 kangarootec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface TYCameraPreviewView : UIView

@property (nonatomic, strong) AVCaptureSession *captureSession;

@end
