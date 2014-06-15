//
//  WTDetailsViewController.h
//  Weather
//
//  Created by mmakankov on 14/06/14.
//  Copyright (c) 2014 mmakankov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class City;

@interface WTDetailsViewController : UIViewController

/**
 City to display
 */
@property (nonatomic) City *currentCity;

@end
