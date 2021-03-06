//
//  HEggHelperMethods.m
//  HappyEggs
//
//  Created by Max on 30.04.13.
//  Copyright (c) 2013 Max Tymchii. All rights reserved.
//

#import "HEggHelperMethods.h"

@implementation HEggHelperMethods

+ (NSString *)userNickName
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *nick = [prefs objectForKey:USERNAME_KEY];
    return nick;
}


+ (void)saveUserNickName:(NSString *)nick
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:nick forKey:USERNAME_KEY];
    [prefs synchronize];
}


+ (NSString *)getUUID
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    // getting an NSString
    NSString *uuid = [prefs stringForKey:UUID];
    if (!uuid) {
        // Create universally unique identifier (object)
        uuid =  [[UIDevice currentDevice].identifierForVendor UUIDString];
        [prefs setObject:uuid forKey:UUID];
        [prefs synchronize];
    }
    return uuid;
}


+ (UIImage *)imageForEgg:(Egg *)egg
{
    if ([egg.type isEqualToString:USER_EGG_TYPE]) {
        NSString *imageName = egg.background;
        UIImage *eggImage = [DELEGATE.userPhotos objectForKey:imageName];
        if (eggImage) {
            return eggImage;
        }
        eggImage = [UIImage imageWithContentsOfFile:imageName];
        [DELEGATE.userPhotos setObject: eggImage forKey:imageName];
        return eggImage;
    }
    
    return [UIImage imageNamed:egg.background];
}

@end
