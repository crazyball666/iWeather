//
//  SearchViewController.m
//  iWeather
//
//  Created by efun on 2019/7/22.
//  Copyright © 2019 EFN. All rights reserved.
//

#import "SearchViewController.h"
#import "ShowDownView.h"
#import "Networking+CB.h"
#import "UpdatingView.h"
#import "IndexViewController.h"
#import "TWMessageBarManager.h"
@import CoreLocation;

@interface SearchViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,NetworkingDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) ShowDownView *showDownView;
@property (nonatomic,strong) NSMutableArray *placeList;
@property (nonatomic,strong) UITextField *textField;
@property (nonatomic,strong) UIButton *searchBtn;
@property (nonatomic, strong) UpdatingView *upDatingView;
@property (nonatomic) BOOL loading;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.placeList = [[NSMutableArray alloc]init];
    self.loading = NO;
    
    CGRect rectTableView = CGRectMake(0, StatusBarDelta, Width, Height - StatusBarDelta);
    self.tableView                 = [[UITableView alloc] initWithFrame:rectTableView style:UITableViewStylePlain];
    
    self.tableView.backgroundColor = CB_Color(180, 180, 180, 0.8);
    self.tableView.delegate        = self;
    self.tableView.dataSource = self;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator   = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SearchItemCell"];
    [self.view addSubview:self.tableView];
    
    if (iPhoneXSeries) {
        UIView *statusBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Width, StatusBarDelta)];
        statusBar.backgroundColor = CB_Color(230, 230, 230, 1);
        [self.view addSubview:statusBar];
    }
    
    UIView *bg = [[UIView alloc]initWithFrame:CGRectMake(0, -Height, Width, Height)];
    bg.backgroundColor = CB_Color(230, 230, 230, 1);
    [self.tableView addSubview:bg];
    // 显示进入更多天气的view的提示信息
    self.showDownView        = [[ShowDownView alloc] initWithFrame:CGRectMake(0, 0, 30.f, 30.f / 3.f)];
    self.showDownView.center = self.view.center;
    self.showDownView.y      = -30.f;
    [self.tableView addSubview:self.showDownView];
    
    // loading
    self.upDatingView        = [[UpdatingView alloc] initWithFrame:CGRectZero];
    self.upDatingView.center = self.view.center;
    [self.view addSubview:self.upDatingView];
}

- (void)viewDidAppear:(BOOL)animated{
    [self.textField becomeFirstResponder];
}

- (void)didTapSearchBtn:(UIButton *)btn{
    if(self.textField.text.length>0 && !self.loading){
        self.loading = YES;
        [self.upDatingView show];
        [self getSearchDataBy:self.textField.text];
    }
}

- (void)getSearchDataBy:(NSString *)str{
    Networking *netWorking = [Networking networkingWithNetworkConfig:searchCity() requestParameter:@{
                                                                                                     @"address":str,
                                                                                                     @"key":@"cd8760ab39721c58569656ba52570fa0"
                                                                                                     } delegate:self];
    [netWorking startRequest];
}

#pragma mark delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Width, 50)];
        searchView.backgroundColor = CB_Color(230, 230, 230, 1);
        
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, searchView.frame.size.width - 30, searchView.frame.size.height - 20)];
        self.textField = textField;
        textField.delegate = self;
        textField.center = searchView.center;
        textField.backgroundColor = [UIColor whiteColor];
        textField.layer.cornerRadius = 15.f;
        textField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 0)];
        textField.leftViewMode = UITextFieldViewModeAlways;
        textField.textColor = CB_Color(60, 60, 60, 1);
        textField.font = [UIFont fontWithName:LATO_BOLD size:12];
        [searchView addSubview:textField];
        
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.searchBtn = btn;
        btn.titleLabel.font =  [UIFont fontWithName:LATO_BOLD size:12];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.frame = CGRectMake(Width, 10, 60, searchView.frame.size.height - 20);
        btn.alpha = 0;
        [btn setTitle:@"Search" forState:UIControlStateNormal];
        [btn setTitleColor:CB_Color(30, 150, 255, 1) forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(didTapSearchBtn:) forControlEvents:UIControlEventTouchUpInside];
        [searchView addSubview:btn];
        
        
        UIView *line         = [[UIView alloc] initWithFrame:CGRectMake(0, searchView.frame.size.height, Width, 0.5)];
        line.backgroundColor = [UIColor blackColor];
        line.alpha           = 0.1f;
        [searchView addSubview:line];
        return searchView;
    } else {
        return nil;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return 50;
    }else{
        return 0;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat percent = (-scrollView.contentOffset.y) / 60.f;
    [self.showDownView showPercent:percent];
    if([self.textField isFirstResponder]){
        [self.textField resignFirstResponder];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // 位移超过60后执行动画效果
    if (scrollView.contentOffset.y <= -60.f) {
        [UIView animateWithDuration:0.5 animations:^{
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        }];
        
        [GCDQueue executeInMainQueue:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        } afterDelaySecs:0.15f];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *loc = _placeList[indexPath.row][@"location"];
    CGFloat lat = [[loc componentsSeparatedByString:@","][1] doubleValue];
    CGFloat lng = [[loc componentsSeparatedByString:@","][0] doubleValue];
    CLLocation *location = [[CLLocation alloc]initWithLatitude:lat longitude:lng];
    IndexViewController *parentVC = (IndexViewController *)self.presentingViewController;
    [self dismissViewControllerAnimated:YES completion:^{
        [parentVC updateWeatherWithLocation:location];
    }];
}

#pragma mark dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.placeList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchItemCell"];
    if(self.textField.text.length > 0 && self.placeList.count > 0){
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont fontWithName:LATO_BOLD size:14];
        NSDictionary *city = _placeList[indexPath.row];
        NSMutableString *str = [[NSMutableString alloc]init];
        if ([city[@"district"] isKindOfClass:[NSString class]]) {
            [str appendFormat:@"%@ -",city[@"district"]];
        }
        if ([city[@"city"] isKindOfClass:[NSString class]]) {
            [str appendFormat:@"%@ -",city[@"city"]];
        }
        if ([city[@"province"] isKindOfClass:[NSString class]]) {
            [str appendFormat:@"%@",city[@"province"]];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%@",
                               str
                               ];
    }
    return cell;
}

#pragma mark textField delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [UIView animateWithDuration:0.5f animations:^{
        CGRect rect = self.textField.frame;
        rect.size.width -= 50;
        self.textField.frame = rect;
        
        CGRect searchRect = self.searchBtn.frame;
        searchRect.origin.x -= 60;
        self.searchBtn.frame = searchRect;
        self.searchBtn.alpha = 1;
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [UIView animateWithDuration:0.5f animations:^{
        CGRect rect = self.textField.frame;
        rect.size.width += 50;
        self.textField.frame = rect;
        
        CGRect searchRect = self.searchBtn.frame;
        searchRect.origin.x += 60;
        self.searchBtn.frame = searchRect;
        self.searchBtn.alpha = 0;
    }];
}

#pragma mark network delegate
/**
 *  请求成功
 *
 *  @param networking networking对象
 *  @param data       数据
 */
- (void)networkingRequestSucess:(Networking *)networking tag:(NSInteger)tag data:(id)data{
    NSLog(@"%@",data);
    if([data[@"status"] intValue] == 1){
        self.placeList = [NSMutableArray arrayWithArray:data[@"geocodes"]];
        [self.tableView reloadData];
        [self.textField resignFirstResponder];
        if (self.placeList.count == 0) {
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"No Data"
                                                           description:@"No data, please search again"
                                                                  type:TWMessageBarMessageTypeInfo
                                                              callback:nil];
        }
    }else{
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Error"
                                                       description:data[@"info"]
                                                              type:TWMessageBarMessageTypeError
                                                          callback:nil];
    }
    [self.upDatingView hide];
    self.loading = NO;
}

/**
 *  请求失败
 *
 *  @param networking networking对象
 *  @param error      错误信息
 */
- (void)networkingRequestFailed:(Networking *)networking tag:(NSInteger)tag error:(NSError *)error{
    [self.upDatingView hide];
    self.loading = NO;
    
    [GCDQueue executeInMainQueue:^{
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Network Unreachable"
                                                       description:@"Please try later."
                                                              type:TWMessageBarMessageTypeError
                                                          callback:nil];
        
    } afterDelaySecs:1.f];
}
@end
