//
//  HEggCell.m
//  HappyEggs
//
//  Created by Max on 21.04.13.
//  Copyright (c) 2013 Max Tymchii. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HEggCell.h"

@implementation HEggCell

#define degreesToRadians(x) (M_PI * (x) / 180.0)
#define kAnimationRotateDeg 2.0
#define kAnimationTranslateX 2.0
#define kAnimationTranslateY 2.0

- (void)startJiggling {
    NSInteger count = 1;
    CGAffineTransform leftWobble = CGAffineTransformMakeRotation(degreesToRadians( kAnimationRotateDeg * (count%2 ? +1 : -1 ) ));
    CGAffineTransform rightWobble = CGAffineTransformMakeRotation(degreesToRadians( kAnimationRotateDeg * (count%2 ? -1 : +1 ) ));
    CGAffineTransform moveTransform = CGAffineTransformTranslate(rightWobble, -kAnimationTranslateX, -kAnimationTranslateY);
    CGAffineTransform conCatTransform = CGAffineTransformConcat(rightWobble, moveTransform);
    
    self.transform = leftWobble;  // starting point
    
    [UIView animateWithDuration:0.1
                          delay:(count * 0.08)
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                     animations:^{ self.transform = conCatTransform; }
                     completion:nil];
}

- (void)stopJiggling {
    [self.layer removeAllAnimations];
    self.transform = CGAffineTransformIdentity;  // Set it straight
}

@end
