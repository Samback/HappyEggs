//
//  HEggLoginVC.m
//  HappyEggs
//
//  Created by Max on 01.05.13.
//  Copyright (c) 2013 Max Tymchii. All rights reserved.
//

#import "HEggLoginVC.h"

@interface HEggLoginVC () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation HEggLoginVC 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textField.delegate = self;
    UIImage *backgrounImage = nil;
    if (IS_IPHONE_5) {
       backgrounImage = [UIImage imageNamed:@"splash_background_5"];
    }
    else {
        backgrounImage =   [UIImage imageNamed:@"Default"];
    }
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgrounImage];
        
	// Do any additional setup after loading the view.
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect containerRect = self.container.frame;
                         CGFloat yPosition = (self.view.frame.size.height - containerRect.size.height) * 0.25;
                         containerRect.origin.y = yPosition;
                         self.container.frame = containerRect;                        
                     }completion:NULL];
}


#pragma mark - UITextField methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([textField.text isEqualToString:@""]) {
        return NO;
    }
    else {
        [HEggHelperMethods saveUserNickName:textField.text];
        [UIView animateWithDuration:.5
                              delay:0.0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear
                         animations:^{
                             CGRect containerRect = self.container.frame;
                             containerRect.origin.y = -containerRect.size.height;
                             self.container.frame = containerRect;
                         }
                         completion:^(BOOL finished) {
                             [DELEGATE makeMainMenuAsRootController];
                         }];
        
        return YES;
    }
}

@end
