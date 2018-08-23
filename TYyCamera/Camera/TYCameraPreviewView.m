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
UICollectionViewDelegate
>

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) UICollectionView *collectionView;

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

@end
