//
//  CustomTCMapAnnotationView.h
//  iOS_ClusterAnnotation_3D
//
//  Created by 栗子 on 2018/5/31.
//  Copyright © 2018年 AutoNavi. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
@class PointModel;
@interface CustomTCMapAnnotationView : MAAnnotationView
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) PointModel *ann;
@property (nonatomic,  copy) NSString *isStart;
@end
