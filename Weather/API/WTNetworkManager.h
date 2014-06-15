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

/**
 Request and save data for array of cities
 @param cities Cities to request
 */
- (void)requestDataForArray:(NSArray *)cities;

/**
 Request and save data for current city id
 @param cityId Id of a city
 */
- (void)requestDataForCityId:(NSNumber *)cityId;

/**
 Request and save icon for current icon id
 @param iconId Id of a icon
 @param completionHandler Completion handler of current method
 */
- (void)requestIconWithId:(NSString *)iconId completionHandler:(void(^)(NSData *data))completionHandler;

/**
 Request and save daily forecast data for current city id and days number
 @param cityId Id of a city
 @param daysNumber Number of days in forecast
 @param completionHandler Completion handler of current method
 */
- (void)requestDailyForecastForCityId:(NSNumber *)cityId
                           daysNumber:(NSInteger)daysNumber
                    completionHandler:(void(^)(NSArray *list))completionHandler;

/**
 Request cities by string
 @param string String to find
 @param completionHandler Completion handler of current method
 */
- (void)requestCitiesByString:(NSString *)string
            completionHandler:(void(^)(NSArray *list))completionHandler;

/**
 Is network available.
 */
@property (nonatomic) BOOL isOnline;

@end
