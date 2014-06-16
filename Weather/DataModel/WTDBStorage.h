//
//  DBStorage.h
//  Weather
//
//  Created by mmakankov on 14/06/14.
//  Copyright (c) 2014 mmakankov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class City;

extern NSString *const entityNameCity;

@interface WTDBStorage : NSObject

/**
 @returns Unique shared instance of the MCDBStorage
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
 Insert or update current object in database with dictionary data
 @param dictionary Dictionary data to save to database
 */
- (void)insertOrUpdateObjectWithDictionary:(NSDictionary *)dictionary;

/**
 Remove object from database
 @param city City to remove
 */
- (void)removeObject:(City *)city;

/**
 Working context
 */
@property (nonatomic) NSManagedObjectContext *context;

@end
