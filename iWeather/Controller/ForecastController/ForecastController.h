//
//  ForecastController.h
//  iWeather
//
//  Created by crazyball on 15/2/26.
//
//  https://github.com/YouXianMing
//  http://www.cnblogs.com/YouXianMing/
//

#import <UIKit/UIKit.h>
#import "CurrentConditions.h"

@interface ForecastController : UIViewController

/**
 *  天气预报
 */
@property (nonatomic, strong) CurrentConditions *weatherCondition;

@end
