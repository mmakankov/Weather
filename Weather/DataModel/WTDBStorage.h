//
//  DBStorage.h
//  Weather
//
//  Created by mmakankov on 14/06/14.
//  Copyright (c) 2014 mmakankov. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const dataBaseDidChangeNotification;
extern NSString *entityNameCity;

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

- (void)insertOrUpdateObjectWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic) NSManagedObjectContext *context;

@end
