//
//  City.h
//  Weather
//
//  Created by mmakankov on 15/06/14.
//  Copyright (c) 2014 mmakankov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface City : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSDate * lastDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * temperature;
@property (nonatomic, retain) NSString * weather;
@property (nonatomic, retain) NSString * iconId;
@property (nonatomic, retain) NSString * weatherDescription;
@property (nonatomic, retain) NSNumber * windSpeed;

@end
