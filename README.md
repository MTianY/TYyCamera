# README

## 一.捕捉功能概述

AVFoundation 的照片和视频捕捉功能从框架搭建之处就是它的一个强项.

### 1. 捕捉会话 -- AVCaptureSession

AVFoundation 捕捉栈的核心类是 `AVCaptureSession`.

- 一个 `AVCaptureSession`(捕捉会话) 相当于一个虚拟的"插线板",`用来连接输入和输出的资源`.
- `AVCaptureSession`管理从物理设备得到的数据流,比如摄像头和麦克风设备,输出到一个或多个目的地.
- 可以动态配置输入和输出的线路,让开发者能够在会话进行中按需重新配置捕捉环境.
- 捕捉会话还可以额外配置一个会话预设值(`session preset`),`用来控制捕捉数据的格式和质量`.
    - 会话预设值默认为`AVCaptureSessionPresetHigh`.它适用于大多数情况,不过框架仍然提供了多个预设值对输出进行定制,以满足应用程序的特殊需求. 

### 2. 捕捉设备 -- AVCaptureDevice

`AVCaptureDevice` 为注入摄像头或麦克风等物理设备定义了一个接口.

- 大多数情况下,这些设备都内置于 iPhone、iPad 或 Mac 中.不过也可能是外部数码相机或便携式摄像机.
- `AVCaptureDevice`针对物理硬件设备定义了大量的控制方法.
    -  如控制摄像头的对焦、曝光、白平衡和闪光灯等.
- `AVCaptureDevice`定义了大量的`类方法`用来访问系统的捕捉设备.
    - 最常用的一个方法是 `defaultDeviceWithMediaType:`.作用是`它会根据给定的媒体类型返回一个系统指定的默认设备.`

    ```objc
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    ``` 

### 3. 捕捉设备的输入 -- AVCaptureDeviceInput

在使用捕捉设备进行处理前,首先需要将它添加为捕捉会话的输入.

不过一个捕捉设备不能直接添加到`AVCaptureSession`中,但是可以通过将它封装在一个`AVCaptureDeviceInput`实例中来添加.

- `AVCaptureDeviceInput`这个对象在设备输出数据和捕捉会话间扮演接线板的作用.
- 使用`deviceInputWithDevice:error:`方法创建`AVCaptureDeviceInput`.

```objc
NSError *error;
AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
```

### 4. 捕捉的输出 -- AVCaptureOutput

AVFoundation 定义了 `AVCaptureOutput`的许多扩展类.

- `AVCaptureOutput`是一个抽象基类,用来`为从捕捉会话得到的数据寻找输出目的地`.
- 框架定义了一些`AVCaptureOutput`的高级扩展类,如:
    - `AVCaptureStillImageOutput`
    - `AVCaptureMovieFileOutput`
    - 使用它们可以很容易的实现捕捉静态照片和视频的功能.
- 还可以找到一些底层拓展类,如:
    - `AVCaptureVideoDataOutput`
    - `AVCaptureAudioDataOutput`
    - 使用它们可以直接访问硬件捕捉到的数字样本.

### 5. 捕捉连接 -- AVCaptureConnection

捕捉会话首先需要确定由给定捕捉设备输入渲染的媒体类型,并自动建立其到能够接收该媒体类型的捕捉输出端的连接.

- 比如`AVCaptureMovieFileOutput`可以接受音频和视频数据,所以会话会确定哪些输入产生视频,哪些输入产生音频,并正确地建立该连接.
- 对这些连接的访问可以让开发者对信号流进行底层的控制,比如禁用某些特定的连接,或在音频连接中访问单独的音频轨道.

### 6. 捕捉预览 -- AVCaptureVideoPreviewLayer

预览层是一个 Core Animation 的 CALayer 子类,对捕捉视频数据进行实时预览.

- 这个类所扮演的角色类似于 AVPlayerLayer,不过还是针对摄像头步骤的需求进行了定制.
- 像 AVPlayerLayer 一样,`AVCaptureVideoPreviewLayer`也可以控制视频内容渲染的缩放和拉伸效果.
    - AVLayerVideoGravityResizeAspect
        - 默认值.保持原始视频的宽高比 
    - AVLayerVideoGravityResizeAspectFill
        - 按照原始视频的宽高比拉伸至填充整个图层.
        - 通常会导致视频被剪切部分 
    - AVLayerVideoGravityResize
        - 拉伸视频来填充整个图层
        - 不常用,会变形  

## 二. TYyCamera 应用程序

### 1.坐标空间转换.

#### 1.1 屏幕坐标系

![屏幕坐标系](https://lh3.googleusercontent.com/-4HISQvP_baE/W3Pk2Q9iBLI/AAAAAAAAABg/BNn60cJpNUEOdQyEKxtq3s9rLWUfw3uOQCHMYCw/I/%255BUNSET%255D)

- 屏幕左上角为 (0,0)
- 屏幕右下角为 (屏幕宽度, 屏幕高度)



#### 1.2 设备坐标系

![WechatIMG127](https://lh3.googleusercontent.com/-3xVPi297vj4/W3PlvyoTosI/AAAAAAAAACY/WKIg5_IUqqQQhR-vq9JrdvUb0IxsPMu2ACHMYCw/I/WechatIMG127.jpeg)

- 设备坐标系通常是基于摄像头传感器的本地设置,水平方向不可旋转
- 并且左上角(0,0).
- 右下角(1,1)

#### 1.3 AVCaptureVideoPreviewLayer 定义了两个方法用来在两个坐标系间进行转换:

- `captureDevicePointOfInterestForPoint:`
    - 获取屏幕坐标系的`CGPoint`数据,返回转换得到的设备坐标系`CGPoint`数据.
- `pointForCaptureDevicePointOfInterest:`
    - 获取摄像头坐标系的 `CGPoint` 数据,返回转换得到的屏幕坐标系 `CGPoint` 数据.
- 本例中使用第一个方法

```objc
/**
 * 将屏幕坐标系上的触控点转换为摄像头坐标系上的点
 */
- (CGPoint)captureDevicePointForPoint:(CGPoint)point {
    AVCaptureVideoPreviewLayer *layer = (AVCaptureVideoPreviewLayer *)self.layer;
    return [layer captureDevicePointOfInterestForPoint:point];
}
```   

### 2.捕捉会话部分

#### 2.1 配置捕捉会话

- `AVCaptureSession`是捕捉场景各活动的中心枢纽.也是输入和输出数据需要添加的对象.
- 一个捕捉会话可以配置会话预设值.如我们这里`AVCaptureSessionPresetHigh`.
- 在几乎所有的 iOS 系统中,`AVCaptureDevice`都会返回手机的`后置摄像头`.
- 在将捕捉设备添加到`AVCaptureSession`前,首先要将它封装成一个`AVCaptureDeviceInput`对象.
- 当返回一个有效的`AVCaptureDeviceInput`时,首先希望调用会话的`canAddInput:`方法测试其是否可以被添加到会话中.如果可以,再调用`addInput:`方法将其添加到会话并给它传递捕捉设备的输入信息.
- 默认音频设备类似.
- `AVCaptureStillImageOutput`是`AVCaptureOutput`的子类. 用来从摄像头捕捉静态图片.
    - 可以为对象的`outputSettings`属性配置一个字典来表示希望捕捉 JPEG 格式的图片.
    - 创建完成后,就可以加入会话了.
- `AVCaptureMovieFileOutput`是`AVCaptureOutput`的子类,用来将 QuickTime 电影录制到文件系统.  

```objc
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

/*--------------------------------------------------------------*/
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
```

#### 2.2 启动会话

- 使用捕捉会话前,首先需要启动会话.
- 启动会话第一步是启动数据流并使它处于准备捕捉图片和视频的状态.
- 检查并确保捕捉会话没有处于准备运行状态.如果没有准备好,则调用捕捉会话的`startRunning`方法.这是一个`同步调用并会消耗一定时间`,所有要以异步的方法在子线程调用该方法.省的阻碍主线程.

```objc
- (void)startSession {
    if (![self.captureSession isRunning]) {
        dispatch_async(self.videoQueue, ^{
            [self.captureSession startRunning];
        });
    }
}
```


#### 2.3 结束会话

- 在捕捉会话上调用`stopRunning`方法会停止系统中的数据流,这也是一个`同步调用`,所以也要采用异步方式.

```objc
- (void)stopSession {
    if ([self.captureSession isRunning]) {
        dispatch_async(self.videoQueue, ^{
            [self.captureSession stopRunning];
        });
    }
}
```

### 3.info.plist 隐私设置

```objc
Privacy - Camera Usage Description
Privacy - Microphone Usage Description
Privacy - Photo Library Additions Usage Description
Privacy - Photo Library Usage Description
```

### 4.摄像头切换功能

目前几乎所有的 iOS 设备都具有前置和后置两个摄像头.首先看一些摄像头的支撑方法,对实现摄像头的切换会方便很多.

- 返回指定位置的设备`AVCaptureDevice`.
    - 有效的位置为`AVCaptureDevicePositionFront` 或 `AVCaptureDevicePositionBack`.
    - 遍历可用的视频设备并返回`position`参数对应的值.

```objc
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
``` 

- 返回当前捕捉会话对应的摄像头
    - 返回激活的捕捉设备输入的 device 属性.

```objc
/**
 * 返回当前捕捉会话对应的摄像头,返回激活的捕捉设备输入的 device 属性
 */
- (AVCaptureDevice *)activeCamera {
    return self.activeVideoInput.device;
}
```

- 返回当前未被激活的摄像头
    - 通过查找当前激活摄像头的反向摄像头实现.
    - 如果设备只有一个摄像头,则返回 nil;

```objc
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
``` 

- 返回一个 BOOL 值,判断是否有超过一个摄像头可用.

```objc
/**
 * 返回可用视频捕捉设备的数量
 */
- (NSUInteger)cameraCount {
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}


/**
 * 是否超过一个摄像头,为切换摄像头做准备
 */
- (BOOL)canSwitchCameras {
    return self.cameraCount > 1;
}
```

- **切换摄像头功能实现**
    - 首先判断是否可以切换摄像头.不可以直接 return 掉
    - 获取未被激活的摄像头设备,并未它创建一个新的`AVCaptureDeviceInput`.
    - 在会话中调用`beginConfiguration`
    - 移除当前激活的`AVCaptureDeviceInput`. 该当前视频捕捉设备输入信息必须在新的对象添加前移除.
    - 检测是否可以添加`AVCaptureDeviceInput`.可以后添加.并重新设置`activeVideoInput`属性.
    - 配置完成后,对`AVCaptureSession`调用`commitConfiguration`.会分批将所有变更整合在一起,得出一个有关会话的单独的、原子性的修改.

```objc
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
    }
    
}
```

### 5.配置捕捉设备

`AVCaptureDevice` 定义了很多方法让开发者控制 iOS 设备上的摄像头.尤其是可以独立调整和锁定摄像头的`焦距、曝光和白平衡`.还可以控制设备的 LED 作为拍照的`闪光灯或手电筒使用`.对焦和曝光还可以基于特定的`兴趣点`进行设置,可以实现`点击对焦`和`点击曝光`的功能.

- 如果要修改摄像头设备时,一定要`先测试`修改动作是否能被设备支持.否则可能会抛异常,程序闪退.
    - 如前置摄像头不支持对焦操作,因为它和目标之间不会超过一个臂长的距离.
    - 大部分的后置摄像头都支持全尺寸对焦. 

    
#### 5.1 点击对焦

- 首先要询问激活中的摄像头是否支持兴趣点对焦.
- `focusAtPoint:`传递进来的 `point`要从屏幕坐标系转为设备坐标系.
- 将屏幕坐标系转为设备坐标系的方法在`TYCameraPreviewView.m`上.

实现代码:

```objc
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

/**
 * 将屏幕坐标系上的触控点转为设备坐标系的点
 */
- (CGPoint)screenCoordinateSystemPointToEquipmentCoordinateSystemPoint:(CGPoint)point {
    AVCaptureVideoPreviewLayer *layer = (AVCaptureVideoPreviewLayer *)self.layer;
    return [layer captureDevicePointOfInterestForPoint:point];
}
```

#### 5.2 点击曝光

- 首先依然是询问激活设备是否支持对一个兴趣点进行曝光
- 曝光模式


```objc
typedef NS_ENUM(NSInteger, AVCaptureExposureMode) {
    // 锁定当前曝光
    AVCaptureExposureModeLocked                            = 0,
    
    // 自动调整曝光一次,然后将曝光模式改为 AVCaptureExposureModeLocked
    AVCaptureExposureModeAutoExpose                        = 1,
    
    // 在需要的时候自动调整曝光
    AVCaptureExposureModeContinuousAutoExposure            = 2,
    
    // 根据用户提供的 ISO、曝光值调整曝光.
    AVCaptureExposureModeCustom NS_ENUM_AVAILABLE_IOS(8_0) = 3,
} NS_AVAILABLE(10_7, 4_0) __TVOS_PROHIBITED;
```

- 对`adjustingExposure`添加 KVO 监听,观察该属性可以知道曝光调整何时完成,让我们有机会在该点上锁定曝光.
- 判断设备是否不再调整曝光等级,确认设备的`exposureMode`是否可以设置为`AVCaptureExposureModeLocked`.
- 移除监听器,这样就不会得到后续变更的通知.
- 最后,已异步方式调度回主队列,定义一个块来设置`exposureMode`属性为`AVCaptureExposureModeLocked`.将`exposureMode`更改转移到下一个事件循环运行非常重要,这样上一步中的`removeObserver:`调用才有机会完成.

实现代码

```objc
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
```

#### 5.3 重置曝光,将对焦点和曝光点放在中心位置

```objc
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
```

### 6.闪光灯和手电筒模式

AVCaptureDevice 类可以让开发者修改摄像头的闪光灯和手电筒模式. 设备后面的LED灯当拍摄静态图片时作为闪光灯,而当拍摄视频时用作手电筒. 捕捉设备的`flasMode`和`torchMode`属性可以被设置为一下3个值中的一个:

- 总是开启
    - `AVCaptureTorchModeOn`  
    - `AVCaptureFlashModeOn`
- 总是关闭  
    - `AVCaptureTorchModeOff`  
    - `AVCaptureFlashModeOff`
- 系统会基于周围环境光照情况自动关闭或打开 LED
    - `AVCaptureTorchModeAuto` 
    - `AVCaptureFlashModeAuto`

