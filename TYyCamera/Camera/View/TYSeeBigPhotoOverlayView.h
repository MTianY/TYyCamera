//
//  TYSeeBigPhotoOverlayView.h
//  TYyCamera
//
//  Created by Maty on 2018/8/30.
//  Copyright © 2018年 kangarootec. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TYSeeBigPhotoOverlayViewDelegate <NSObject>

- (void)ty_dismissBtnClick;

@end

@interface TYSeeBigPhotoOverlayView : UIView

@property (nonatomic, weak) id<TYSeeBigPhotoOverlayViewDelegate> delegate;

@end
