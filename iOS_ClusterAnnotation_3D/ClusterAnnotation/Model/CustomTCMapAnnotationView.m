//
//  CustomTCMapAnnotationView.h
//  iOS_ClusterAnnotation_3D
//
//  Created by 栗子 on 2018/5/31.
//  Copyright © 2018年 AutoNavi. All rights reserved.
//


#import "CustomTCMapAnnotationView.h"
#import "PointModel.h"
#define kWidth   70.f
#define ZOOM_LEVEL 0.6f
@interface CustomTCMapAnnotationView()

@property (nonatomic, strong) UIImageView *backPic;
@property (nonatomic, strong) UILabel *pointLabel;
@property (nonatomic, strong) UILabel *moreLabel;
@property (nonatomic, strong) CABasicAnimation *animation;

@end

@implementation CustomTCMapAnnotationView
- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        [self setAnn:nil];
    }
    
    return self;
}

- (void)setAnn:(PointModel *)ann
{
    _ann = ann;
    if (ann)
    {
        self.moreLabel.hidden  = true;
        self.pointLabel.hidden = NO;

        self.backPic.hidden    = false;
        [self setupAnnotation:ann];
    }else
    {
        
        self.pointLabel.hidden = YES;
        
        self.backPic.hidden    = false;
        self.moreLabel.hidden  = false;
        self.backPic.backgroundColor = [UIColor redColor];
        
        self.bounds            = CGRectMake(0.f, 0.f, kWidth, kWidth + 14.f);
        self.moreLabel.frame   = CGRectMake(0, 0, kWidth, 40.f);
        self.backPic.frame     = CGRectMake(0.f, 0.f, kWidth, kWidth);

        self.centerOffset      = CGPointMake(0.f, - ZOOM_LEVEL*((kWidth + 14.f)/2.f - 19.f));
        self.transform         = CGAffineTransformMakeScale(ZOOM_LEVEL, ZOOM_LEVEL);
        
        self.moreLabel.text = [NSString stringWithFormat:@"%ld",self.count];
        self.backPic.layer.cornerRadius  = kWidth/2;
        self.backPic.layer.masksToBounds = YES;
    }
}

- (void)setupAnnotation:(PointModel *)ann
{
    
        CGFloat selfScale = ZOOM_LEVEL;
        CGFloat oriW           = kWidth;
        CGFloat het            = kWidth + 14.f;
        CGFloat picH           = kWidth;
        
        self.bounds            = CGRectMake(0.f, 0.f, oriW, het);
        self.backPic.frame     = CGRectMake(0.f, 0.f, oriW, picH);
        self.pointLabel.frame  = CGRectMake(-30.f,picH, oriW+60, 14);
        self.centerOffset      = CGPointMake(0.f, - ZOOM_LEVEL*(het/2.f - 19.f));
        
    self.pointLabel.text   = ann.titleStr;
    self.pointLabel.backgroundColor = [UIColor greenColor];
    
    self.backPic.backgroundColor     = [UIColor redColor];
    self.backPic.layer.cornerRadius  = oriW/2;
    self.backPic.layer.masksToBounds = YES;
    self.transform = CGAffineTransformMakeScale(selfScale, selfScale);
   
}



- (UILabel *)pointLabel
{//底部的名称
    if (!_pointLabel) {
        _pointLabel = [UILabel new];
        _pointLabel.textColor = [UIColor blackColor];
        _pointLabel.textAlignment =NSTextAlignmentCenter;
        _pointLabel.font   = [UIFont boldSystemFontOfSize:14.f];
        [self addSubview:_pointLabel];
    }
    return _pointLabel;
}

- (UILabel *)moreLabel
{//显示多个重叠一起的个数
    if (!_moreLabel) {
        _moreLabel = [UILabel new];
        _moreLabel.textColor = [UIColor whiteColor];
        _moreLabel.textAlignment =NSTextAlignmentCenter;
        _moreLabel.font   = [UIFont boldSystemFontOfSize:30.f];
        [self addSubview:_moreLabel];
    }
    return _moreLabel;
}



- (UIImageView *)backPic
{//背景图
    if (!_backPic) {
        _backPic = [UIImageView new];
        [self addSubview:_backPic];
    }
    return _backPic;
}



#pragma mark - annimation


- (void)addBounceAnnimation
{
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    bounceAnimation.values = @[@(0.1), @(0.9), @(0.7), @(0.8)];

    bounceAnimation.duration = 0.6;
    
    NSMutableArray *timingFunctions = [[NSMutableArray alloc] initWithCapacity:bounceAnimation.values.count];
    for (NSUInteger i = 0; i < bounceAnimation.values.count; i++)
    {
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    }
    [bounceAnimation setTimingFunctions:timingFunctions.copy];
    
    bounceAnimation.removedOnCompletion = NO;
    bounceAnimation.fillMode = kCAFillModeForwards;

    [self.layer addAnimation:bounceAnimation forKey:@"bounce"];
}

@end
