//
//  PointModel.h
//  iOS_ClusterAnnotation_3D
//
//  Created by 栗子 on 2018/5/31.
//  Copyright © 2018年 AutoNavi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>

@interface PointModel : MAPointAnnotation

@property (nonatomic,   copy) NSString *index;//第几个点标
@property (nonatomic,   copy) NSString *titleStr;//点标的文字

@end
