//
//  AppDelegate.h
//  HappyEggs
//
//  Created by Max on 21.04.13.
//  Copyright (c) 2013 Max Tymchii. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) RKManagedObjectStore *managedObjectStore;
@property (nonatomic, strong) NSMutableDictionary *userPhotos;

- (void)makeMainMenuAsRootController;

@end
