//
//  AppDelegate.m
//  HappyEggs
//
//  Created by Max on 21.04.13.
//  Copyright (c) 2013 Max Tymchii. All rights reserved.
//

#import "AppDelegate.h"
#import "Egg.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initRestKitWithCoreDataIntegration];
    [self initSourceInCoreData];
    [self initBump];
    [self initGA];
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Restkit config
- (void)initRestKitWithCoreDataIntegration{
    //Activity indicator
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    RKObjectManager* objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:BASE_URL]];
    [objectManager.HTTPClient setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    [objectManager.HTTPClient setParameterEncoding:AFJSONParameterEncoding];
    NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"DataBase" ofType:@"momd"]];
    // NOTE: Due to an iOS 5 bug, the managed object model returned is immutable.
    NSManagedObjectModel *managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    [managedObjectStore createPersistentStoreCoordinator];
    
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"DataBase.sqlite"];
    
    NSError *error;
    
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error];
    
    NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
    
    [managedObjectStore createManagedObjectContexts];
    
    // Configure a managed object cache to ensure we do not create duplicate objects
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
    
    self.managedObjectModel = managedObjectModel;
    objectManager.managedObjectStore = managedObjectStore;
}

- (void)initSourceInCoreData
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Egg entityName]];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"eggId" ascending:YES]];
   
    NSError *error;
    NSArray *results = [[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSAssert(!error, @"Error performing fetch request: %@", error);
    if (!error) {
        if (results.count == 0) {
            [self fillCoreDataWithBaseEggs];
        }
    }
}


- (void)fillCoreDataWithBaseEggs
{
    NSManagedObjectContext *context = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    
    [Egg addEggWithName:@"Add egg" background:@"addImage.jpg" couldDelete:NO eggId:0 type:ADD_NEW_EGG_TYPE andContext:context];
    NSString *eggName = nil;
    NSString *backgroundImageName = nil;
    for (int i = 1; i <= 10; i++) {
        eggName = [NSString stringWithFormat:@"Egg name %d", i];
        backgroundImageName = [NSString stringWithFormat:@"%d.jpg", i];
        [Egg addEggWithName:eggName background:backgroundImageName couldDelete:NO eggId:1 type:DEFAULT_EGG_TYPE andContext:context];
    }
       
}


- (void)initBump
{
    [BumpClient configureWithAPIKey:BUMP_API_KEY andUserID:[[UIDevice currentDevice] name]];
}

#pragma mark - Init Google analytics

- (void)initGA
{
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = TIME_OF_GA_UPDATE;
    // Optional: set debug to YES for extra debugging information.
    [GAI sharedInstance].debug = NO;
    // Create tracker instance.
    [[GAI sharedInstance] trackerWithTrackingId:GA_API_KEY];
    
}

@end
