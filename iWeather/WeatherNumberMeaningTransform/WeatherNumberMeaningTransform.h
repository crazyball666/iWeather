//
//  WeatherNumberMeaningTransform.h
//  iWeather
//
//  Created by crazyball on 15/3/4.
//
//  https://github.com/YouXianMing
//  http://www.cnblogs.com/YouXianMing/
//

#import <Foundation/Foundation.h>
#import "EmitterLayerView.h"

@interface WeatherNumberMeaningTransform : NSObject

+ (NSString *)fontTextWeatherNumber:(NSNumber *)number;
+ (UIColor *)iconColor:(NSNumber *)number;
+ (EMitterType)emitterTypeWithNumber:(NSNumber *)number;

@end
