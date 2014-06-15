//
//  WTNetworkManager.h
//  Weather
//
//  Created by mmakankov on 15/06/14.
//  Copyright (c) 2014 mmakankov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTNetworkManager : NSObject

/**
 @returns Unique shared instance of the WTNetworkManager
 */
+ (instancetype) sharedInstance;

/**
 Unavailable method
 */
+ (instancetype) alloc __attribute__((unavailable("alloc not available, call sharedInstance instead")));

/**
 Unavailable method
 */
- (instancetype) init __attribute__((unavailable("init not available, call sharedInstance instead")));

/**
 Unavailable method
 */
+ (instancetype) new __attribute__((unavailable("new not available, call sharedInstance instead")));

- (void)requestDataForArray:(NSArray *)cities;

- (void)requestDataForCityName:(NSString *)cityName;

- (void)requestIconWithId:(NSString *)iconId;

- (void)requestDailyForecastForCityName:(NSString *)cityName
                             daysNumber:(NSInteger)daysNumber
                      complitionHandler:(void(^)(NSArray *list))complitionHandler;

@end
