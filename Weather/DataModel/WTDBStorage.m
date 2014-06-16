//
//  DBStorage.m
//  Weather
//
//  Created by mmakankov on 14/06/14.
//  Copyright (c) 2014 mmakankov. All rights reserved.
//

#import "WTDBStorage.h"
#import <CoreData/CoreData.h>
#import "City.h"

NSString *const entityNameCity = @"City";

@interface WTDBStorage ()

@property (nonatomic) NSManagedObjectModel *model;
@property (nonatomic) NSPersistentStoreCoordinator *coordinator;

@end

@implementation WTDBStorage

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initUniqueInstance];
    });
    
    return sharedInstance;
}

- (instancetype)initUniqueInstance {
    
    self = [super init];
    if (self) {
        
        NSString *doc = APP_DELEGATE.documentsDirectory;
        NSURL *dbFilePath = [NSURL fileURLWithPath:[doc stringByAppendingPathComponent:@"data.sqlite"]];
        
        BOOL isFileExist =  [[NSFileManager defaultManager] fileExistsAtPath:dbFilePath.path];
        
        NSString * path = [[NSBundle mainBundle] pathForResource:@"Model" ofType:@"momd"];
        
        NSURL * momURL = [NSURL fileURLWithPath:path];
        self.model = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
        
        self.coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        
        NSError * error = nil;
        if (![_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:dbFilePath options:options error:&error]) {
            DLog(@"CoreDataProxy: Could Not Start Persistent Store: %@, %@", error, error.userInfo);
        }
        
        self.context = [[NSManagedObjectContext alloc] init];
        self.context.persistentStoreCoordinator = _coordinator;
        
        if (!isFileExist) {
            [self fillDataBase];
        }
    }
    return self;
}

- (void)fillDataBase {
    City *moscow =  [NSEntityDescription insertNewObjectForEntityForName:entityNameCity inManagedObjectContext:self.context];
    moscow.name = @"Moscow";
    moscow.lastDate = [NSDate date];
    moscow.temperature = @20.0;
    moscow.id = @524901;
    
    City *stPetersburg =  [NSEntityDescription insertNewObjectForEntityForName:entityNameCity inManagedObjectContext:self.context];
    stPetersburg.name = @"Saint Petersburg";
    stPetersburg.lastDate = [NSDate date];
    stPetersburg.temperature = @20.0;
    stPetersburg.id = @498817;
    
    [self commitContext];
}

#pragma mark - Public methods

- (void)insertOrUpdateObjectWithDictionary:(NSDictionary *)dictionary {
    
    City *city = [self objectWithId:dictionary[@"id"]];
    
    if (!city) {
        city =  [NSEntityDescription insertNewObjectForEntityForName:entityNameCity inManagedObjectContext:[WTDBStorage sharedInstance].context];
    }
    
    city.name = dictionary[@"name"];
    city.id = dictionary[@"id"];
    //NSNumber *dateTime = dictionary[@"dt"];
    //city.lastDate = [NSDate dateWithTimeIntervalSince1970:dateTime.integerValue];
    city.temperature = dictionary[@"main"][@"temp"];
    city.weather = dictionary[@"weather"][0][@"main"];
    city.weatherDescription = dictionary[@"weather"][0][@"description"];
    city.iconId = dictionary[@"weather"][0][@"icon"];
    city.windSpeed = dictionary[@"wind"][@"speed"];
    
    [self commitContext];
}

- (void)removeObject:(City *)city {
    
    [self.context deleteObject:city];
    [self commitContext];
}
                      
- (void)commitContext {
    NSError * error = nil;
    [self.context save:&error];
    if (error) {
        DLog(@"%@", error);
    }
}

- (void)rollbackContext {
    [self.context rollback];
}

#pragma mark - Private methods

- (City *)objectWithId:(NSNumber *)objectId {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityNameCity inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", objectId];
    [fetchRequest setPredicate:predicate];

    NSError *errorFetch = nil;
    NSArray *items = [self.context executeFetchRequest:fetchRequest error:&errorFetch];
    if (errorFetch != nil) {
        DLog(@"executeFetchRequest error: %@", [errorFetch localizedDescription]);
    }
    if (items.count > 0) {
        return items.firstObject;
    }
    return nil;
}

@end
