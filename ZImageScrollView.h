//
//  ADScrollView.h
//  naluhodoPT
//
//  Created by cookie on 11/21/15.
//  Copyright © 2015 cookie. All rights reserved.
//

#import <UIKit/UIKit.h>


#define MIN_PAGE_CHANGE_TIMEINTERVL 2.0

#define FRAME_WIDTH self.frame.size.width
#define FRAME_HEIGHT self.frame.size.height
#define PAGECONTROL_BOTTOM_DISTANCE 10


enum ScrollDirection{
    DIRECTION_UP = 0,
    DIRECTION_DOWN = 1,
    DIRECTION_LEFT = 2,
    DIRECTION_RIGHT = 3 //个人认为向左滑和向右滑比较符合审美
};

@protocol TapOnImageDelegate

@optional
- (void)tapOnImage:(NSInteger)index; //当点击图片后调用这个协议

@end


@interface ZImageScrollView : UIView

@property(nonatomic) UIImage* placeHolderImage; //when the network is not good
@property(nonatomic) NSUInteger pageChangeInterval;
@property(nonatomic) BOOL autoScroll;
@property(nonatomic) enum ScrollDirection direction;
@property(nonatomic) BOOL scrollUnlimted;

@property (nonatomic) id<TapOnImageDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame withImages:(NSArray*)images autoScroll:(BOOL)autoScroll unlimited:(BOOL)unlimited;
- (instancetype)initWithFrame:(CGRect)frame withImageURLs:(NSArray *)imageURLs autoScroll:(BOOL)autoScroll unlimited:(BOOL)unlimited;


@end
