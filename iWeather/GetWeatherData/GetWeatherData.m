//
//  GetWeatherData.m
//  iWeather
//
//  Created by crazyball on 15/2/25.
//
//  https://github.com/YouXianMing
//  http://www.cnblogs.com/YouXianMing/
//

#import "GetWeatherData.h"
#import "CurrentConditions.h"
#import "CurrentWeatherData.h"
#import "Networking+CB.h"

@interface GetWeatherData () <NetworkingDelegate>

@property (nonatomic, strong) CurrentConditions  *currentConditions;
@property (nonatomic, strong) CurrentWeatherData *currentWeatherData;
@property (nonatomic, strong) Networking         *networkWeather;
@property (nonatomic, strong) Networking         *networkDaily;
@property (nonatomic, strong) Networking         *networkCityName;
@property (nonatomic, strong) NSDictionary       *city;
@end

@implementation GetWeatherData

- (void)startGetLocationWeatherData {
    
    if (self.location == nil || self.networkWeather.isRunning || self.networkDaily.isRunning || self.networkCityName.isRunning) {
        return;
    }
    
    self.networkCityName = [Networking networkingWithNetworkConfig:cityName() requestParameter:@{
                                                                                                 @"location":[NSString stringWithFormat:@"%f,%f",self.location.coordinate.longitude,self.location.coordinate.latitude],
                                                                                                 @"key":@"cd8760ab39721c58569656ba52570fa0",
                                                                                                 } delegate:self];
    [self.networkCityName startRequest];
}

- (void)networkingRequestSucess:(Networking *)networking tag:(NSInteger)tag data:(id)data {
    
    if (tag == kCityName) {
        if ([data[@"status"] intValue] == 1) {
            self.city = data[@"regeocode"];
            self.networkWeather = [Networking networkingWithNetworkConfig:weather()
                                                         requestParameter:@{@"lat" : [NSString stringWithFormat:@"%f", self.location.coordinate.latitude],
                                                                            @"lon" : [NSString stringWithFormat:@"%f", self.location.coordinate.longitude]}
                                                                 delegate:self];
            [self.networkWeather startRequest];
        } else {
            [_delegate weatherData:nil sucess:NO];
        }
    }
    
    if (tag == kWeather) {
        CurrentWeatherData *currentData = [[CurrentWeatherData alloc] initWithDictionary:data];
        if (currentData.cod.integerValue == 200) {
            if([self.city[@"addressComponent"][@"district"] isKindOfClass:[NSString class]]){
                currentData.name = self.city[@"addressComponent"][@"district"];
            }
            self.currentWeatherData = currentData;
            self.networkDaily       = [Networking networkingWithNetworkConfig:forecastDaily()
                                                             requestParameter:@{@"id"  : self.currentWeatherData.cityId,
                                                                                @"cnt" : @"14"}
                                                                     delegate:self];
            [self.networkDaily startRequest];
        } else {
            [_delegate weatherData:nil sucess:NO];
        }
    }
    
    else if (tag == kForecastDaily) {
        CurrentConditions *currentData = [[CurrentConditions alloc] initWithDictionary:data];
        if (currentData.cod.integerValue == 200) {
            if([self.city[@"addressComponent"][@"district"] isKindOfClass:[NSString class]]){
                currentData.city.name = self.city[@"addressComponent"][@"district"];
            }
            self.currentConditions = currentData;
            [_delegate weatherData:@{@"WeatherData"       : self.currentWeatherData,
                                     @"WeatherConditions" : self.currentConditions}
                            sucess:YES];
        } else {
            [_delegate weatherData:nil sucess:NO];
        }
    }
    
}

- (void)networkingRequestFailed:(Networking *)networking tag:(NSInteger)tag error:(NSError *)error {
    
    [_delegate weatherData:nil sucess:NO];
}

@end
