//
//  TYSeeBigPhotoViewController.m
//  TYyCamera
//
//  Created by Maty on 2018/8/30.
//  Copyright © 2018年 kangarootec. All rights reserved.
//

#import "TYSeeBigPhotoViewController.h"
#import "TYSeeBigCollectionViewCell.h"
#import "TYSeeBigPhotoOverlayView.h"

static NSString * const bigCellID = @"seeBigCellID";

@interface TYSeeBigPhotoViewController () <
UICollectionViewDataSource,
UICollectionViewDelegate,
TYSeeBigPhotoOverlayViewDelegate
>

@property (nonatomic, strong) UICollectionView *collectionView;

/**
 * 相册内所有资源集合
 */
@property (nonatomic, strong) NSMutableArray *allAssetsMutArray;

@property (nonatomic, strong) TYSeeBigPhotoOverlayView *overlayView;

@end

@implementation TYSeeBigPhotoViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    
    // 默认遮盖隐藏
    self.overlayView.hidden = YES;
    
    // 获取相册内所有资源的集合(包括最近删除的)
    self.allAssetsMutArray = [[TYPhotoTool shareInstance] getAllAssetsFromAlbum];
    
}

#pragma mark - SET
- (void)setAsset:(PHAsset *)asset {
    _asset = asset;
    [[TYPhotoTool shareInstance] getImageFromAssetWithPHAsset:asset andTargetSize:CGSizeMake(TYSCREEN_WIDTH, TYSCREEN_HEIGHT) andResultHandler:^(UIImage *result, NSDictionary *resultHandler) {
        
        
        
    }];
}

#pragma mark - Tap
- (void)tapGes:(UITapGestureRecognizer *)tap {
    [UIView animateWithDuration:0.25 animations:^{
        self.overlayView.hidden = !self.overlayView.hidden;
    }];
}

#pragma mark - Dismiss
- (void)dismiss {
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 
                             }];
}

#pragma mark - <TYSeeBigPhotoOverlayViewDelegate>
- (void)ty_dismissBtnClick {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegate>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.allAssetsMutArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TYSeeBigCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:bigCellID forIndexPath:indexPath];
    cell.asset = self.allAssetsMutArray[indexPath.row];
    return cell;
}

#pragma mark - UI
- (void)setupUI {
    [self.view addSubview:self.collectionView];
    self.navigationItem.title = @"Big";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    
    [self.view addSubview:self.overlayView];
    [self.overlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
}

#pragma mark - Lazy Load
- (UICollectionView *)collectionView {
    if (nil == _collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(TYSCREEN_WIDTH, TYSCREEN_HEIGHT);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, TYSCREEN_WIDTH, TYSCREEN_HEIGHT) collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.bounces = NO;
        _collectionView.pagingEnabled = YES;
        
        [_collectionView registerClass:[TYSeeBigCollectionViewCell class] forCellWithReuseIdentifier:bigCellID];
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
        [_collectionView addGestureRecognizer:tapGes];
        
        
    }
    return _collectionView;
}

- (NSMutableArray *)allAssetsMutArray {
    if (nil == _allAssetsMutArray) {
        _allAssetsMutArray = [NSMutableArray array];
    }
    return _allAssetsMutArray;
}

- (TYSeeBigPhotoOverlayView *)overlayView {
    if (nil == _overlayView) {
        _overlayView = [[TYSeeBigPhotoOverlayView alloc] init];
        _overlayView.userInteractionEnabled = YES;
        _overlayView.delegate = self;
    }
    return _overlayView;
}

@end
