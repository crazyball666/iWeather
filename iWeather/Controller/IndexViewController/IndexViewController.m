//
//  ViewController.m
//  iWeather
//
//  Created by efun on 2019/7/19.
//  Copyright © 2019 EFN. All rights reserved.
//

#import "IndexViewController.h"
#import "MapManager.h"
#import "WeatherView.h"
#import "SearchView.h"
#import "CurrentWeatherData.h"
#import "CurrentConditions.h"
#import "GetWeatherData.h"
#import "ForecastController.h"
#import "UpdatingView.h"
#import "FadeBlackView.h"
#import "FailedLongPressView.h"
#import "TWMessageBarManager.h"
#import "SearchViewController.h"

@interface IndexViewController ()<MapManagerLocationDelegate, UITableViewDelegate, GetWeatherDataDelegate, WeatherViewDelegate, UIViewControllerTransitioningDelegate, FailedLongPressViewDelegate>

@property (nonatomic, strong) MapManager           *mapLoacation;
@property (nonatomic, strong) WeatherView          *weatherView;
@property (nonatomic, strong) GetWeatherData       *getWeatherData;
@property (nonatomic, strong) FadeBlackView        *fadeBlackView;
@property (nonatomic, strong) UpdatingView         *upDatingView;
@property (nonatomic, strong) FailedLongPressView  *failedView;
@property (nonatomic)         BOOL                  firstTimeLoadingData;

@end

@implementation IndexViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    CGRect rectWeatherView = CGRectMake(0, StatusBarDelta, Width, Height - StatusBarDelta);
    
    // 天气的view
    self.weatherView                     = [[WeatherView alloc] initWithFrame:rectWeatherView];
    self.weatherView.layer.masksToBounds = YES;
    self.weatherView.delegate            = self;
    [self.weatherView buildView];
    [self.view addSubview:self.weatherView];
    
//    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [searchBtn setTitle:@"Search" forState:UIControlStateNormal];
//    [searchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    searchBtn.frame = CGRectMake(Width-100, 20, 100, 50);
//    searchBtn.backgroundColor = [UIColor yellowColor];
//    [searchBtn addTarget:self action:@selector(didTapSearchBtn:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:searchBtn];
    
    
    // 变黑
    self.fadeBlackView = [[FadeBlackView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.fadeBlackView];
    
    // loading
    self.upDatingView        = [[UpdatingView alloc] initWithFrame:CGRectZero];
    self.upDatingView.center = self.view.center;
    [self.view addSubview:self.upDatingView];
    
    // 定位功能
    self.mapLoacation          = [MapManager new];
    self.mapLoacation.delegate = self;
    
    // 获取网络请求
    self.getWeatherData          = [GetWeatherData new];
    self.getWeatherData.delegate = self;
    
    // 加载失败后显示的view
    self.failedView          = [[FailedLongPressView alloc] initWithFrame:self.view.bounds];
    self.failedView.delegate = self;
    [self.failedView buildView];
    [self.view addSubview:self.failedView];
    
    // 进入加载数据动画效果
    [self getLocationAndFadeShow];
}

/**
 *  上拉进入新的控制器
 *
 *  @param condition 新控制器需要的数据
 */
- (void)pullUpEventWithData:(CurrentConditions *)condition {
    
    [GCDQueue executeInMainQueue:^{
        
        ForecastController *forecastCV    = [ForecastController new];
        forecastCV.transitioningDelegate  = self;
        forecastCV.modalPresentationStyle = UIModalPresentationCustom;
        forecastCV.weatherCondition       = condition;
        [self presentViewController:forecastCV animated:YES completion:nil];
        
    } afterDelaySecs:0.05f];
}

/**
 *  下拉更新数据
 */
- (void)pullDownToRefreshData {
    
    NSLog(@"下拉获取数据");
    [self getLocationAndFadeShow];
}

- (void)getLocationAndFadeShow {
    
    // 显示出等待页面
    [self.fadeBlackView show];
    [self.upDatingView show];
    
    // 开始定位
    [self.mapLoacation start];
}

- (void)getCityIdAndFadeShow {
    
    // 显示出等待页面
    [self.fadeBlackView show];
    [self.upDatingView show];
}

- (void)mapManager:(MapManager *)manager didUpdateAndGetLastCLLocation:(CLLocation *)location {
    NSLog(@"定位成功 - 并开始获取网路数据");
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(delayRunEvent:) withObject:location afterDelay:0.3f];
}

- (void)mapManager:(MapManager *)manager didFailed:(NSError *)error {
    
    NSLog(@"定位失败");
    [self.upDatingView showFailed];
    
    [GCDQueue executeInMainQueue:^{
        
        [self.fadeBlackView hide];
        [self.upDatingView hide];
        [self.failedView show];
        
    } afterDelaySecs:2.5f];
    
    [GCDQueue executeInMainQueue:^{
        
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Failed to locate"
                                                       description:@"Sorry, temporarily unable to locate your position."
                                                              type:TWMessageBarMessageTypeError
                                                          callback:^{}];
        
    } afterDelaySecs:1.f];
}

- (void)mapManagerServerClosed:(MapManager *)manager {
    
    [GCDQueue executeInMainQueue:^{
        
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Failed to locate"
                                                       description:@"Please turn on your Location Service."
                                                              type:TWMessageBarMessageTypeError
                                                          callback:^{}];
    }];
    
    [GCDQueue executeInMainQueue:^{
        
        [self.fadeBlackView hide];
        [self.upDatingView hide];
        [self.failedView show];
        
    } afterDelaySecs:1.5];
}

/**
 *  延时执行
 *
 *  @param object 过滤掉干扰项目
 */
- (void)delayRunEvent:(id)object {
    
    self.getWeatherData.location = object;
    [self.getWeatherData startGetLocationWeatherData];
}

/**
 *  获取到网络数据的结果
 *
 *  @param object 网络数据
 *  @param sucess YES表示成功,NO表示失败
 */
- (void)weatherData:(id)object sucess:(BOOL)sucess {
    
    if (sucess) {
        
        NSLog(@"%@", object);
        
        // 获取数据
        CurrentWeatherData *data       = [object valueForKey:@"WeatherData"];
        CurrentConditions  *conditions = [object valueForKey:@"WeatherConditions"];
        
        // 先获取温度
        self.weatherView.weahterData       = data;
        self.weatherView.weatherConditions = conditions;
        
        // 先隐藏,再显示
        [self.weatherView hide];
        
        [GCDQueue executeInMainQueue:^{
            
            [self.weatherView show];
            [self.fadeBlackView hide];
            [self.upDatingView hide];
            [self.failedView remove];
            
        } afterDelaySecs:1.f];
        
    } else {
        
        NSLog(@"获取数据失败");
        
        [self.upDatingView showFailed];
        [GCDQueue executeInMainQueue:^{
            
            [self.fadeBlackView hide];
            [self.upDatingView hide];
            [self.failedView show];
            
        } afterDelaySecs:2.51f];
        
        [self showErrorInfo];
    }
}

- (void)showErrorInfo {
    
    [GCDQueue executeInMainQueue:^{
        
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Network Unreachable"
                                                       description:@"Please try later."
                                                              type:TWMessageBarMessageTypeError
                                                          callback:^{}];
        
    } afterDelaySecs:1.f];
}

- (void)pressEvent:(FailedLongPressView *)view {
    
    [self.failedView hide];
    [self getLocationAndFadeShow];
}

- (void)didTapCityBtn:(UIButton *)btn{
    SearchViewController *searchVC = [[SearchViewController alloc]init];
    searchVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:searchVC animated:YES completion:nil];
}


- (void)updateWeatherWithLocation:(CLLocation *)location{
    // 显示出等待页面
    [self.fadeBlackView show];
    [self.upDatingView show];
    [self performSelector:@selector(delayRunEvent:) withObject:location afterDelay:0.3f];
}

@end
