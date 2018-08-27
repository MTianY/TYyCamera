//
//  TYCameraPreviewView.m
//  TYyCamera
//
//  Created by Maty on 2018/8/21.
//  Copyright © 2018年 kangarootec. All rights reserved.
//

#import "TYCameraPreviewView.h"
#import "TYCameraCollectionViewCell.h"

static NSString * const cellID = @"cellID";

@interface TYCameraPreviewView () <
UICollectionViewDataSource,
UICollectionViewDelegate,
TYFaceDetectionDelegate
>

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UISlider *scaleSlider;

@property (nonatomic, strong) NSMutableDictionary *faceLayersMutDict;
@property (nonatomic, strong) CALayer *faceOverlayLayer;

@property (nonatomic, strong) NSNumber *lastFaceID;

// 记录上一次记录的捏合缩放
@property (nonatomic, assign) CGFloat lastPinchScale;

@end

@implementation TYCameraPreviewView {
    CGFloat _initialPinchZoom;
}

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
        
        // 点击手势
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesMethod:)];
        [self addGestureRecognizer:tapGes];
        
        // 捏合手势
        UIPinchGestureRecognizer *pinchGes = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesMethod:)];
        [self addGestureRecognizer:pinchGes];
        
        [self setupFace];
        
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

#pragma mark - 缩放
// 手势捏合调整缩放
- (void)pinchGesMethod:(UIPinchGestureRecognizer *)pinchGes {
    
    NSLog(@"pinchGes.scale = %f",pinchGes.scale);
    
    if (pinchGes.state == UIGestureRecognizerStateBegan) {
        _initialPinchZoom = [[TYCameraControlInstance shareInstance] activeCamera].videoZoomFactor;
        
        NSLog(@"pinGes-InitialPinchZoom: %f",_initialPinchZoom);
        
    }
    
    NSError *error = nil;
    [[[TYCameraControlInstance shareInstance] activeCamera] lockForConfiguration:&error];
    if (!error) {
        CGFloat zoomFactor;
        CGFloat scale = pinchGes.scale;
        if (scale < 1.0f) {
            zoomFactor = _initialPinchZoom - pow([[TYCameraControlInstance shareInstance] activeCamera].activeFormat.videoMaxZoomFactor, 1.0f - pinchGes.scale);
            
            NSLog(@"pinGes zoomFactor:  scale<1.0f----->%f",zoomFactor);
            
        } else {
            zoomFactor = _initialPinchZoom + pow([[TYCameraControlInstance shareInstance] activeCamera].activeFormat.videoMaxZoomFactor, (pinchGes.scale - 1.0f)/2.0f);
            
            NSLog(@"pinGes zoomFactor:  scale>1.0f---->%f",zoomFactor);
            
        }
        
        zoomFactor = MIN(4.0f, zoomFactor);
        zoomFactor = MAX(1.0f, zoomFactor);
        
        
        NSLog(@"pinGes: zoomFactor---->%f",zoomFactor);
        
        NSLog(@"[[TYCameraControlInstance shareInstance] activeCamera].activeFormat.videoMaxZoomFactor = %f",[[TYCameraControlInstance shareInstance] activeCamera].activeFormat.videoMaxZoomFactor);
        
        NSLog(@"*********************\n\n");
        
        [[TYCameraControlInstance shareInstance] activeCamera].videoZoomFactor = zoomFactor;
        
//        CGFloat zoomFactor = pow([self maxZoomFactor], zoomValue);
        CGFloat zoomValue = sqrt(zoomFactor);
        NSLog(@"zoomValue = %f",zoomValue);
        
    
        [[[TYCameraControlInstance shareInstance] activeCamera] unlockForConfiguration];
        
    }
    
}

// 滑动 slider 调节缩放
- (void)sliderChangeMethod:(UISlider *)slider {
    
    NSLog(@"slider.Value = %f",slider.value);
    
    if ([[TYCameraControlInstance shareInstance] cameraSupportZoom]) {
        [[TYCameraControlInstance shareInstance] setZoomValue:slider.value];
    }
}

#pragma mark - 人脸检测

- (void)setupFace {
    
    // 不加这两行会无限的添加 layer 黄框
    self.faceLayersMutDict = [NSMutableDictionary dictionary];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    self.faceOverlayLayer = [CALayer layer];
    self.faceOverlayLayer.frame = self.bounds;
    self.faceOverlayLayer.sublayerTransform = TYMakePerspectiveTransform(1000);
    [self.previewLayer addSublayer:self.faceOverlayLayer];
    
    [[TYCameraControlInstance shareInstance] setFaceDetectionDelegate:self];
    
    NSError *error;
    if ([[TYCameraControlInstance shareInstance] setupSessionOutputs:error]) {
        if (error) {
            NSLog(@"error: =%@",error);
        }
    }
    
}

- (void)didDetectFaces:(NSArray *)faces {
    NSArray *transformedFaces = [self transformedFacesFromFaces:faces];
    
//    NSLog(@"%@",transformedFaces);
    
    // 确定移除视图的人脸,将图层移除
    NSMutableArray *lostFaces = [self.faceLayersMutDict.allKeys mutableCopy];
    
    for (AVMetadataFaceObject *face in transformedFaces) {
        NSNumber *faceID = @(face.faceID);
        [lostFaces removeObject:faceID];
        
        // 如果 faceID 一直相同,直接 return
        if (faceID == self.lastFaceID) {
            return;
        } else {
            
            // 记录上一次的 faceID
            self.lastFaceID = faceID;
            [self.faceOverlayLayer setHidden:NO];
            
            CALayer *layer = self.faceLayersMutDict[faceID];
            if (!layer) {
                // 如果没有 faceID 对应的 layer. 就创建新的
                layer = [self makeFaceLayer];
                [self.faceOverlayLayer addSublayer:layer];
                self.faceLayersMutDict[faceID] = layer;
            }
            
            layer.transform = CATransform3DIdentity;
            layer.frame = face.bounds;
            
            if (face.hasRollAngle) {
                CATransform3D t = [self transformForRollAngle:face.rollAngle];
                layer.transform = CATransform3DConcat(layer.transform, t);
            }
            
            if (face.hasYawAngle) {
                CATransform3D t = [self transformForYawAngle:face.yawAngle];
                layer.transform = CATransform3DConcat(layer.transform, t);
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.faceOverlayLayer setHidden:YES];
            });
            
        }
        
        
    }
    
    for (NSNumber *faceID in lostFaces) {
        CALayer *layer = self.faceLayersMutDict[faceID];
        [layer removeFromSuperlayer];
        [self.faceLayersMutDict removeObjectForKey:faceID];
    }
    
}

/*
 *将设备坐标系的人脸对象转为视图空间对象的集合
 */
- (NSArray *)transformedFacesFromFaces:(NSArray *)faces {
    NSMutableArray *transformedFaces = [NSMutableArray array];
    for (AVMetadataObject *face in faces) {
        AVMetadataObject *transformedFace = [self.previewLayer transformedMetadataObjectForMetadataObject:face];
        [transformedFaces addObject:transformedFace];
    }
    return transformedFaces;
}

/**
 * 返回一个新的 layer
 */
- (CALayer *)makeFaceLayer {
    CALayer *layer = [CALayer layer];
    layer.borderColor = [UIColor orangeColor].CGColor;
    layer.borderWidth = 2.0f;
    return layer;
}

/**
 * 绕 Z 轴旋转
 */
- (CATransform3D)transformForRollAngle:(CGFloat)rollAngleInDegrees {
    CGFloat rollAngleInRadians = TYDegressToRadian(rollAngleInDegrees);
    return CATransform3DMakeRotation(rollAngleInRadians, 0.0f, 0.0f, 1.0f);
}

/**
 * 绕 Y 轴旋转
 */
- (CATransform3D)transformForYawAngle:(CGFloat)yawAngleInDegrees {
    CGFloat yawAngleInRadians = TYDegressToRadian(yawAngleInDegrees);
    CATransform3D yawTransform = CATransform3DMakeRotation(yawAngleInRadians, 0.0f, -1.0f, 0.0f);
    return CATransform3DConcat(yawTransform, [self orientationTransform]);
}

- (CATransform3D)orientationTransform {
    CGFloat angle = 0.0f;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            angle = -M_PI / 2.0f;
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            angle = M_PI / 2.0f;
            break;
            
        case UIDeviceOrientationPortrait:
            angle = 0.0f;
            break;
            
        default:
            break;
    }
    return CATransform3DMakeRotation(angle, 0.0f, 0.0f, 1.0f);
}

static CATransform3D TYMakePerspectiveTransform(CGFloat eyePosition) {
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0 / eyePosition;
    return transform;
}

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegate>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TYCameraCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"%f",self.collectionView.contentOffset.x);
    
    CGFloat offset_X = self.collectionView.contentOffset.x;
    NSNumber *offetXNum = [NSNumber numberWithFloat:offset_X];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TYNotification_CollectionView_ContentOffset_X" object:offetXNum];
    
}

#pragma mark - UI
- (void)setupUI {
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(self);
    }];
    
    [self addSubview:self.scaleSlider];
    [self.scaleSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(20);
        make.right.mas_equalTo(self).offset(-20);
        make.bottom.mas_equalTo(self).offset(-130);
    }];
}

#pragma mark - Lazy Load
- (UICollectionView *)collectionView {
    if (nil == _collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(TYSCREEN_WIDTH, TYSCREEN_HEIGHT);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView setShowsVerticalScrollIndicator:NO];
        [_collectionView setShowsHorizontalScrollIndicator:NO];
        [_collectionView registerClass:[TYCameraCollectionViewCell class] forCellWithReuseIdentifier:cellID];
        [_collectionView setBounces:NO];
    }
    return _collectionView;
}

- (UISlider *)scaleSlider {
    if (nil == _scaleSlider) {
        _scaleSlider = [[UISlider alloc] init];
        _scaleSlider.minimumValue = 0.0f;
        _scaleSlider.maximumValue = 1.0f;
        [_scaleSlider addTarget:self action:@selector(sliderChangeMethod:) forControlEvents:UIControlEventValueChanged];
    }
    return _scaleSlider;
}

@end
