//
//  TYPhotoManger.h
//
//  Created by 马天野 on 2017/1/14.
//  Copyright © 2017年 MTY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 处理图片,保存图片
 */
@interface TYPhotoManger : NSObject

+ (void)savePhoto:(UIImage *)image albumTitle:(NSString *)albumTitle completionHandler:(void(^)(BOOL success,NSError *error))completionHandler;


+ (void)saveVideo:(NSURL *)fileURL albumTitle:(NSString *)albumTitle completionHandler:(void(^)(BOOL, NSError *))completionHandler;

@end
