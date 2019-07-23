//
//  Networking+CB.m
//  iWeather
//
//  Created by YouXianMing on 2017/11/8.
//  Copyright © 2017年 crazyball. All rights reserved.
//

#import "Networking+CB.h"
#import "CBRequestParameterSerializer.h"
#import "CBNetworkingInfo.h"

@implementation NetworkConfig

@end

@implementation Networking (CB)

+ (instancetype)networkingWithNetworkConfig:(NetworkConfig *)config requestParameter:(id)requestParameter delegate:(id <NetworkingDelegate>)delegate {
    
    Networking *networking = [Networking networkingWithUrlString:config.urlString
                                                requestParameter:requestParameter
                                                          method:config.method
                                      requestParameterSerializer:[CBRequestParameterSerializer new]
                                          responseDataSerializer:nil
                                       constructingBodyWithBlock:nil
                                                        progress:nil
                                                             tag:config.tag
                                                        delegate:delegate
                                               requestSerializer:[AFHTTPRequestSerializer serializer]
                                              responseSerializer:[AFJSONResponseSerializer serializer]];
    networking.timeoutInterval = @(8.f);
    networking.serviceInfo     = config.functionName;
    networking.networkingInfo  = [CBNetworkingInfo new];
    
    return networking;
}

@end
