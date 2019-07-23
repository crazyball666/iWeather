//
//  ViewController.h
//  iWeather
//
//  Created by efun on 2019/7/19.
//  Copyright © 2019 EFN. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;

@interface IndexViewController : UIViewController

- (void)updateWeatherWithLocation:(CLLocation *)location;

@end

