//
//  TYPhotoManger.m
//
//  Created by 马天野 on 2017/1/14.
//  Copyright © 2017年 MTY. All rights reserved.
//

#import "TYPhotoManger.h"
#import <Photos/Photos.h>

@implementation TYPhotoManger

+ (PHAssetCollection *)fetchAssetCollection:(NSString *)albumTitle {
    // 获取之前的相册
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    for (PHAssetCollection *assetCollection in result) {
        if ([assetCollection.localizedTitle isEqualToString:albumTitle]) {
            return assetCollection;
        }
    }
    return nil;
}

+ (void)savePhoto:(UIImage *)image albumTitle:(NSString *)albumTitle completionHandler:(void (^)(BOOL, NSError *))completionHandler {
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // 判断之前有没有相册,获取之前的相册
        PHAssetCollection *assetCollection = [self fetchAssetCollection:albumTitle];
        PHAssetCollectionChangeRequest *assetCollectionChangeRequest;
        if (assetCollection) {
            // 已有相册
            assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        }else {
            // 1.创建自定义相册
            assetCollectionChangeRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumTitle];
        }
        
        // 2.保存图片到系统的相册
        PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        
        
        // 3.把创建好的图片添加到自己的相册
        PHObjectPlaceholder *placeholder = [assetChangeRequest placeholderForCreatedAsset];
        [assetCollectionChangeRequest addAssets:@[placeholder]];
        
    } completionHandler:completionHandler];
    
}

+ (void)saveVideo:(NSURL *)fileURL albumTitle:(NSString *)albumTitle completionHandler:(void(^)(BOOL, NSError *))completionHandler {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetCollection *assetCollection = [self fetchAssetCollection:albumTitle];
        PHAssetCollectionChangeRequest *assetCollectionChagneRequest;
        if (assetCollection) {
            assetCollectionChagneRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        } else {
            assetCollectionChagneRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumTitle];
        }
        PHAssetChangeRequest  *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:fileURL];
        PHObjectPlaceholder *placeHolder = [assetChangeRequest placeholderForCreatedAsset];
        [assetCollectionChagneRequest addAssets:@[placeHolder]];
        
    } completionHandler:completionHandler];
}

@end
