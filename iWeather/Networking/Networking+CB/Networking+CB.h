//
//  Networking+CB.h
//  iWeather
//
//  Created by YouXianMing on 2017/11/8.
//  Copyright © 2017年 crazyball. All rights reserved.
//

#import "Networking.h"

static NSString *baseURL = @"http://api.openweathermap.org/data/2.5";

typedef enum : NSUInteger {
    
    kWeather = 1000,
    kForecastDaily,
    kSeachCity,
    kCityName
    
} ENetworkConfigTagValue;

#pragma mark - NetworkConfig

@interface NetworkConfig : NSObject

@property (nonatomic, strong) NSString           *urlString;
@property (nonatomic, strong) NSString           *functionName;
@property (nonatomic)         NSInteger           tag;
@property (nonatomic)         ENetworkingMethod   method;

@end

/**
 *  [GET] Current Weather Request.  (/weather)
 */
static inline NetworkConfig *weather() {
    
    NetworkConfig *config = [NetworkConfig new];
    config.urlString      = [baseURL stringByAppendingString:@"/weather"];
    config.functionName   = @"Current Weather Request.";
    config.tag            = kWeather;
    config.method         = kNetworkingGET;
    
    return config;
}

/**
 *  [GET] Forecast Daily.  (/forecast/daily)
 */
static inline NetworkConfig *forecastDaily() {
    
    NetworkConfig *config = [NetworkConfig new];
    config.urlString      = [baseURL stringByAppendingString:@"/forecast/daily"];
    config.functionName   = @"Forecast Daily.";
    config.tag            = kForecastDaily;
    config.method         = kNetworkingGET;
    
    return config;
}

/**
  * [GET] Search City
  */
static inline NetworkConfig *searchCity() {
    
    NetworkConfig *config = [NetworkConfig new];
    config.urlString      = @"https://restapi.amap.com/v3/geocode/geo";
    config.functionName   = @"Search City.";
    config.tag            = kSeachCity;
    config.method         = kNetworkingGET;
    
    return config;
}

/**
 * [GET]  City Name
 */
static inline NetworkConfig *cityName() {
    
    NetworkConfig *config = [NetworkConfig new];
    config.urlString      = @"https://restapi.amap.com/v3/geocode/regeo";
    config.functionName   = @"city Name.";
    config.tag            = kCityName;
    config.method         = kNetworkingGET;
    
    return config;
}

@interface Networking (CB)

+ (instancetype)networkingWithNetworkConfig:(NetworkConfig *)config requestParameter:(id)requestParameter delegate:(id <NetworkingDelegate>)delegate;

@end
