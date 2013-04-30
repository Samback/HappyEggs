//
//  HEggHelperMethods.h
//  HappyEggs
//
//  Created by Max on 30.04.13.
//  Copyright (c) 2013 Max Tymchii. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEggHelperMethods : NSObject
+ (NSString *)getUUID;
+ (NSString *)userNickName;
+ (void)saveUserNickName:(NSString *)nick;

@end
