//
//  HEggCell.h
//  HappyEggs
//
//  Created by Max on 21.04.13.
//  Copyright (c) 2013 Max Tymchii. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEggCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *imagesContainer;
@property (weak, nonatomic) IBOutlet UIImageView *eggImage;

@property (weak, nonatomic) IBOutlet UIImageView *eggTopBackground;
- (void)startJiggling;
- (void)stopJiggling;

@end
