//
//  AnnotationClusterViewController.m
//  officialDemo2D
//
//  Created by yi chen on 14-5-15.
//  Copyright (c) 2014年 AutoNavi. All rights reserved.
//

#import "AnnotationClusterViewController.h"
#import "PoiDetailViewController.h"

#import "CoordinateQuadTree.h"
#import "ClusterAnnotation.h"

#import "ClusterAnnotationView.h"
#import "ClusterTableViewCell.h"
#import "CustomCalloutView.h"
#import "CustomTCMapAnnotationView.h"
#import "PointModel.h"

#define kCalloutViewMargin  -12
#define Button_Height       70.0

@interface AnnotationClusterViewController ()<CustomCalloutViewTapDelegate>

@property (nonatomic, strong) CoordinateQuadTree* coordinateQuadTree;

@property (nonatomic, strong) CustomCalloutView *customCalloutView;


@property (nonatomic, assign) BOOL shouldRegionChangeReCalculate;

@property (nonatomic, strong) AMapPOIKeywordsSearchRequest *currentRequest;

@property(nonatomic,strong) NSMutableArray *pointsArr;
@property (nonatomic,strong) NSMutableArray *dataSourceAnnotations;

@end

@implementation AnnotationClusterViewController

#pragma mark - update Annotation

/* 更新annotation. */
- (void)updateMapViewAnnotationsWithAnnotations:(NSArray *)annotations
{
    /* 用户滑动时，保留仍然可用的标注，去除屏幕外标注，添加新增区域的标注 */
    NSMutableSet *before = [NSMutableSet setWithArray:self.mapView.annotations];
    [before removeObject:[self.mapView userLocation]];
    NSSet *after = [NSSet setWithArray:annotations];
    
    /* 保留仍然位于屏幕内的annotation. */
    NSMutableSet *toKeep = [NSMutableSet setWithSet:before];
    [toKeep intersectSet:after];
    
    /* 需要添加的annotation. */
    NSMutableSet *toAdd = [NSMutableSet setWithSet:after];
    [toAdd minusSet:toKeep];
    
    /* 删除位于屏幕外的annotation. */
    NSMutableSet *toRemove = [NSMutableSet setWithSet:before];
    [toRemove minusSet:after];
    
    /* 更新. */
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView addAnnotations:[toAdd allObjects]];
        [self.mapView removeAnnotations:[toRemove allObjects]];
    });
}

- (void)addAnnotationsToMapView:(MAMapView *)mapView
{
    @synchronized(self)
    {
        if (self.coordinateQuadTree.root == nil || !self.shouldRegionChangeReCalculate)
        {
            NSLog(@"tree is not ready.");
            return;
        }
        
        /* 根据当前zoomLevel和zoomScale 进行annotation聚合. */
        MAMapRect visibleRect = self.mapView.visibleMapRect;
        double zoomScale = self.mapView.bounds.size.width / visibleRect.size.width;
        double zoomLevel = self.mapView.zoomLevel;
        
        /* 也可根据zoomLevel计算指定屏幕距离(以50像素为例)对应的实际距离 进行annotation聚合. */
        /* 使用：NSArray *annotations = [weakSelf.coordinateQuadTree clusteredAnnotationsWithinMapRect:visibleRect withDistance:distance]; */
        //double distance = 50.f * [self.mapView metersPerPointForZoomLevel:self.mapView.zoomLevel];
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSArray *annotations = [weakSelf.coordinateQuadTree clusteredAnnotationsWithinMapRect:visibleRect
                                                                                    withZoomScale:zoomScale
                                                                                     andZoomLevel:zoomLevel];
            /* 更新annotation. */
            [weakSelf updateMapViewAnnotationsWithAnnotations:annotations];
        });
    }
}

#pragma mark - CustomCalloutViewTapDelegate

- (void)didDetailButtonTapped:(NSInteger)index
{
    PoiDetailViewController *detail = [[PoiDetailViewController alloc] init];

    
    /* 进入POI详情页面. */
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view
{

  
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{

    
    if ([view isKindOfClass:[CustomTCMapAnnotationView class]]) {
        ClusterAnnotation *cluster = (ClusterAnnotation *)view.annotation;
        if (cluster.count)
        {
            AMapPOI *aPoi = (AMapPOI *)cluster.pois[0];
            PointModel *model = (PointModel *)aPoi.subPOIs[0];
            NSInteger index = [[NSString stringWithFormat:@"%@",model.index] integerValue];
             NSLog(@"index===%@",model.index);
        }
    }
    [self.mapView deselectAnnotation:self.mapView.selectedAnnotations.firstObject animated:true];
    
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self addAnnotationsToMapView:self.mapView];
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[ClusterAnnotation class]])
    {//多个标注点
        /* dequeue重用annotationView. */
        static NSString *const AnnotatioViewReuseID = @"AnnotatioViewReuseID";
        
        CustomTCMapAnnotationView *annotationView = (CustomTCMapAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotatioViewReuseID];
        
        if (!annotationView)
        {
            annotationView = [[CustomTCMapAnnotationView alloc] initWithAnnotation:annotation
                                                                   reuseIdentifier:AnnotatioViewReuseID];
        }
        ClusterAnnotation *cluster = (ClusterAnnotation *)annotation;
        /* 设置annotationView的属性. */
        annotationView.annotation = annotation;
        /* 不弹出原生annotation */
        annotationView.canShowCallout = NO;
        annotationView.zIndex = 10;
        NSLog(@"cluster.count===%ld",cluster.count);
        annotationView.count = cluster.count;
        if (cluster.pois.count == 1)
        {
            AMapPOI *aPoi = (AMapPOI *)cluster.pois[0];
            PointModel *ann = (PointModel *)aPoi.subPOIs[0];
            annotationView.ann = ann;
        }else
        {
            annotationView.ann = nil;
        }
        return annotationView;
    }
    return nil;
}




#pragma mark - Life Cycle

- (id)init
{
    if (self = [super init])
    {
        self.coordinateQuadTree = [[CoordinateQuadTree alloc] init];
        
        self.customCalloutView = [[CustomCalloutView alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Cluster Annotations"];
    
    self.dataSourceAnnotations = [NSMutableArray array];
    NSDictionary *dic = @{@"latitude":@"39.948560",@"longitude":@"116.474111",@"name":@"北京华联(蓝色港湾店)"};
    NSDictionary *dic1 = @{@"latitude":@"40.224154",@"longitude":@"116.862673",@"name":@"世纪华联购物中心(龙林路店)"};
    NSDictionary *dic2 = @{@"latitude":@"39.877193",@"longitude":@"116.621201",@"name":@"世纪华联超市(东旭花园店)"};
    NSDictionary *dic3 = @{@"latitude":@"39.962415",@"longitude":@"116.209870",@"name":@"世纪华联超市(香山艺墅东)"};
    self.pointsArr =[NSMutableArray arrayWithArray: @[dic,dic1,dic2,dic3]];
    [self.mapView removeAnnotations:self.dataSourceAnnotations];

    [self reload];
    [self initMapView];
    
    
    _shouldRegionChangeReCalculate = NO;
    
    
    for (int i=0; i<self.pointsArr.count; i++) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[self.pointsArr objectAtIndex:i]];
        NSString *numStr = [NSString stringWithFormat:@"%d", i];
        [dic setObject:numStr forKey:@"index"];
        [self.pointsArr replaceObjectAtIndex:i withObject:dic];
        
        double coordX = 0;
        double coordY = 0;
        coordX = [[dic objectForKey:@"latitude"] doubleValue];
        coordY = [[dic objectForKey:@"longitude"] doubleValue];
        PointModel *pointAnnotation = [[PointModel alloc] init];
        pointAnnotation.coordinate = CLLocationCoordinate2DMake(coordX, coordY);
        pointAnnotation.titleStr    = [dic objectForKey:@"name"];
        pointAnnotation.index = [NSString stringWithFormat:@"%d",i];;
        [self.dataSourceAnnotations addObject:pointAnnotation];
        
        
    }
    [self reload];
    [self.mapView addAnnotations:_dataSourceAnnotations];
    
    
}

- (void)dealloc
{
    [self.coordinateQuadTree clean];
}

- (void)initMapView
{
    
    if (self.mapView == nil)
    {
        self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
        self.mapView.delegate = self;
        
    }
    
    self.mapView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height );
    
    [self.view addSubview:self.mapView];
    
    self.mapView.visibleMapRect = MAMapRectMake(220880104, 101476980, 272496, 466656);

    
}
- (void)reload{
    
    if (self.dataSourceAnnotations.count == 0)
    {
        return;
    }
    NSMutableArray *poiArr = [NSMutableArray array];
    for (PointModel *model in self.dataSourceAnnotations)
    {
        AMapPOI *poi = [[AMapPOI alloc]init];
        AMapGeoPoint *loca = [[AMapGeoPoint alloc] init];
        loca.longitude = model.coordinate.longitude;
        loca.latitude = model.coordinate.latitude;
        poi.location = loca;
        poi.subPOIs = @[model];
        
        [poiArr addObject:poi];
    }
    @synchronized(self)
    {
        self.shouldRegionChangeReCalculate = NO;
        
        // 清理
        NSMutableArray *annosToRemove = [NSMutableArray arrayWithArray:self.mapView.annotations];
        [annosToRemove removeObject:self.mapView.userLocation];
        [self.mapView removeAnnotations:annosToRemove];
        
        __weak typeof(self) weakSelf = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            /* 建立四叉树. */
            [weakSelf.coordinateQuadTree buildTreeWithPOIs:poiArr];
            weakSelf.shouldRegionChangeReCalculate = YES;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf addAnnotationsToMapView:self.mapView];
            });
        });
    }
}


@end
