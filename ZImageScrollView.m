//
//  ADScrollView.m
//  naluhodoPT
//
//  Created by cookie on 11/21/15.
//  Copyright © 2015 cookie. All rights reserved.
//

#import "ZImageScrollView.h"
#import <SDWebImageManager.h>

@interface ZImageScrollView() <UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property(nonatomic) NSArray* imageURLs;
@property(nonatomic) NSMutableArray* images;

@property (nonatomic) UIScrollView* scrollView;
@property (nonatomic) UIPageControl* pageControl;
@property (nonatomic) NSTimer* timer;

@property (nonatomic) UIImageView* firstImageView;
@property (nonatomic) UIImageView* lastImageView;
@property (nonatomic) NSMutableArray* imageViewArray;

@property (nonatomic) NSInteger index;

@property (nonatomic) CGPoint startScrollContentOffset;

@end

@implementation ZImageScrollView

- (instancetype)initWithFrame:(CGRect)frame withImages:(NSArray*)images autoScroll:(BOOL)autoScroll unlimited:(BOOL)unlimited{
    self = [super initWithFrame:frame];
    if(self){
        // do some custom init here;
        self.images = [[NSMutableArray alloc]initWithArray:images];
        self.autoScroll = autoScroll;
        self.scrollUnlimted = unlimited;
        self.direction = DIRECTION_LEFT;
        [self setUp];
        [self setImageView];
        [self startScroll];
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withImageURLs:(NSArray *)imageURLs autoScroll:(BOOL)autoScroll unlimited:(BOOL)unlimited{
    NSArray* images = [self getImageFromURL:imageURLs];
    return [self initWithFrame:frame withImages:images autoScroll:autoScroll unlimited:unlimited];
}


#pragma mark - SetUpFunctions

- (void)setUp{
    UIScrollView* scrollView = [[UIScrollView alloc]initWithFrame:self.frame];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    // 初始化时先设置为NO，有>1张图片时才设置为YES
    scrollView.scrollEnabled = YES;
    scrollView.delegate = self;
    scrollView.bounces = !self.scrollUnlimted; //如果是无限循环的话，bounce设置为NO，因为末尾的下一张是最初的图片
    //UIPageControl初始化
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = self.images.count;
    CGPoint pageControlCenterPoint = CGPointMake(FRAME_WIDTH/2, FRAME_HEIGHT - PAGECONTROL_BOTTOM_DISTANCE);
    pageControl.center = pageControlCenterPoint;
    
    CGSize scrollContentSize;
    if(self.scrollUnlimted){
        switch (self.direction) {
            case DIRECTION_UP:
                break;
            case DIRECTION_LEFT:
                scrollContentSize = CGSizeMake(FRAME_WIDTH*(self.images.count+1), FRAME_HEIGHT);
                break;
            default:
                break;
        }
    }else{
        switch (self.direction) {
            case DIRECTION_UP:
                break;
            case DIRECTION_LEFT:
                scrollContentSize = CGSizeMake(FRAME_WIDTH*(self.images.count), FRAME_HEIGHT);
                break;
            default:
                break;
        }
    }
    
    [scrollView setContentSize:scrollContentSize];

    // 对于单个图片隐藏
    pageControl.hidesForSinglePage = YES;
    
    [self addSubview:scrollView];
    [self addSubview:pageControl];
    self.pageControl = pageControl;
    self.scrollView = scrollView;
    self.imageViewArray = [[NSMutableArray alloc]init];
    self.pageControl.currentPage = 0;
    self.index = 0;
}


- (void)setImageView{
    //初始化各个imageView
    if (self.images.count > 0) {
        for(int i = 0 ; i < self.images.count; i++){
            UIImageView* adImageView = [[UIImageView alloc]initWithFrame:CGRectMake(FRAME_WIDTH*i, 0, FRAME_WIDTH, FRAME_HEIGHT)];
            adImageView.image = self.images[i];
            adImageView.userInteractionEnabled = YES;
            adImageView.tag = i;
            UITapGestureRecognizer* tapGestrue = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOnImageView:)];
            [adImageView addGestureRecognizer:tapGestrue];
            [self.imageViewArray addObject:adImageView];
            [self.scrollView addSubview:adImageView];
        }
        
        if(self.images.count > 1 && self.scrollUnlimted){
            /*UITapGestureRecognizer* tapGestrueForFirstImageView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOnImageView:)];
            self.firstImageView = [[UIImageView alloc]initWithFrame:CGRectMake(-FRAME_WIDTH,0,FRAME_WIDTH,FRAME_HEIGHT)];
            self.firstImageView.image = self.images[self.images.count-1];
            self.firstImageView.userInteractionEnabled = YES;
            self.firstImageView.tag = self.images.count-1;
            [self.firstImageView addGestureRecognizer:tapGestrueForFirstImageView];
            //firstView是为了从左往右时准备的
            [self.scrollView addSubview:self.firstImageView];
            */
            UITapGestureRecognizer* tapGestrueForLastImageView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOnImageView:)];
            self.lastImageView  = [[UIImageView alloc]initWithFrame:CGRectMake(FRAME_WIDTH*self.images.count, 0, FRAME_WIDTH, FRAME_HEIGHT)];
            self.lastImageView.image = self.images[0];
            self.lastImageView.tag = 0;
            self.lastImageView.userInteractionEnabled = YES;
            [self.lastImageView addGestureRecognizer:tapGestrueForLastImageView];
            //lastView是为了从右往左时准备的
            
           
            [self.scrollView addSubview:self.lastImageView];

        }
        
        //初始化首个和末尾的imageView,为了实现循环播放
        
        //添加子视图
        for(int i = 0; i < self.imageViewArray.count ; i++){
            [self.scrollView addSubview:self.imageViewArray[i]];
        }
        
    }else{
        NSException* exception = [NSException
                                    exceptionWithName:@"ImageAmountException"
                                    reason:@"The Amount of the images is zero"
                                    userInfo:nil];
        @throw exception;
    }
    
    
}


- (NSArray*)getImageFromURL:(NSArray*)imageURLs{
    NSMutableArray* images = [NSMutableArray arrayWithCapacity:imageURLs.count];
    for(int i = 0; i < imageURLs.count; i++){
        [images addObject:[[UIImage alloc]init]];
    }
    
    self.images = images;
    
    for (NSInteger i = 0; i < imageURLs.count; i++) {
        [[SDWebImageManager sharedManager] downloadImageWithURL:imageURLs[i] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (image) {
                [self updateImageView:image WithIndex:i];
            }
        }];
    }
    return images;
}


- (void)updateImageView:(UIImage*)image WithIndex:(NSInteger)index{
    // when the image download finished, call this function to
    
    if(index == 0){
        //update the duplicate imageview of
        [self.lastImageView setImage:image];
    }
    UIImageView* imageView = (UIImageView*)self.imageViewArray[index];
    [imageView setImage:image];
    NSLog(@"update %ld",index);
}

#pragma mark - PrivateMethond

- (void)startScroll{
    if(self.autoScroll){
        if(!self.timer){
            self.timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
        }
    }
}

- (void)stopScroll{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)nextPage{
    if(self.scrollUnlimted){
        self.index += 1;
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width*self.index, 0) animated:YES];
        self.pageControl.currentPage = self.index;
        
        
        if (self.index == self.images.count) {
            self.pageControl.currentPage = 0;
        }
        
        if(self.index == (self.images.count+1)){
            //这边表示到了最后一张图，也是第一张图的复制,要跳回去
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
            self.index = 1;
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width*self.index, 0) animated:YES];
            self.pageControl.currentPage = self.index;
        }

    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(self.images.count <= 1) return;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.startScrollContentOffset = scrollView.contentOffset;
    [self stopScroll];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    CGFloat scrollContentOffsetX = scrollView.contentOffset.x - self.startScrollContentOffset.x;
    if(self.scrollUnlimted){
              //NSLog(@"%f",scrollContentOffsetX);
        if(scrollContentOffsetX > 0){
            //scrollview向左滑动
            self.index += 1;
            
        }else if(scrollContentOffsetX < 0){
            self.index -= 1;
        }else{
            //the first image view can not be slide to
        }
        
        [self.scrollView setContentOffset:CGPointMake(self.index* self.scrollView.bounds.size.width, 0) animated:YES];
        self.pageControl.currentPage = self.index;
    }else{
        if(scrollContentOffsetX > 0 && scrollView.contentOffset.x < scrollView.contentSize.width){
            self.index += 1;
            self.pageControl.currentPage += 1;
        }else if(scrollContentOffsetX < 0 && scrollView.contentOffset.x > 0){
            self.index -= 1;
            self.pageControl.currentPage -= 1;
        }else{
            
        }
        
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if(self.index >= self.images.count){
        [self.scrollView setContentOffset:CGPointMake(0,0) animated:NO];
        self.index = 0;
        self.pageControl.currentPage = 0;
    }
    
    [self startScroll];
}


#pragma mark - UIGestureRecognizerEvent

- (void)tapOnImageView:(UITapGestureRecognizer*)recoginzer{
    //这边用tag来判断点击的是哪个UIImageView
    NSLog(@"%ld",recoginzer.view.tag);
    [self.delegate tapOnImage:recoginzer.view.tag];
}


- (BOOL)gestureRecognizer:(UITapGestureRecognizer*) tap shouldRecognizeSimultaneouslyWithGestureRecognizer:(UISwipeGestureRecognizer*)swipe{
    return YES;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
