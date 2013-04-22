//
//  HEggHomePageVC.m
//  HappyEggs
//
//  Created by Max on 21.04.13.
//  Copyright (c) 2013 Max Tymchii. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HEggHomePageVC.h"
#import "Egg.h"
#import "HEggCell.h"
#import "SBJson.h"

#define  RADIUS 15

#define TAG_WIN 0
#define TAG_TIE 1
#define TAG_LOSE 2

@interface HEggHomePageVC ()<NSFetchedResultsControllerDelegate, FDTakeDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UICollectionView *eggsList;
@property (nonatomic, strong) REActivityViewController *activityViewController;
@property (nonatomic) NSInteger numberOfUniqeEggs;
@property (nonatomic, strong) FDTakeController *takeController;
@property (nonatomic, strong) UIAlertView *deleteEggAlert;
@property (nonatomic, strong) Egg *selectedEgg;
@property (weak, nonatomic) IBOutlet UIImageView *eggSkinImage;
@property (nonatomic, strong) Egg *eggOnScreen;
@property (nonatomic) int userAttack;
@property (nonatomic) int enemyAttack;
@property (nonatomic, getter = isActiveToFight) BOOL activeToFight;
@end

@implementation HEggHomePageVC
#pragma mark - Lazy instantiation

- (REActivityViewController *)activityViewController{
    if (!_activityViewController) {
        REFacebookActivity *facebookActivity = [[REFacebookActivity alloc] init];
        RETwitterActivity *twitterActivity = [[RETwitterActivity alloc] init];
        REVKActivity *vkActivity = [[REVKActivity alloc] initWithClientId:VK_APP_ID];
        // Compile activities into an array, we will pass that array to
        // REActivityViewController on the next step
        //
        NSArray *activities = @[facebookActivity, twitterActivity, vkActivity];
        
        // Create REActivityViewController controller and assign data source
        //
        REActivityViewController *activityViewController = [[REActivityViewController alloc] initWithViewController:self activities:activities];
        
        activityViewController.userInfo = @{
                                          //  @"image": [UIImage imageNamed:SHARING_IMAGE],
                                            @"text": SHARING_TEXT,
                                            @"url": [NSURL URLWithString:SHARING_URL_FOR_APP],
                                            };

        _activityViewController = activityViewController;
    }
    return _activityViewController;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureBump];
    self.activeToFight = YES;
    self.trackedViewName = @"Home page";
    
    self.takeController = [[FDTakeController alloc] init];
    self.takeController.delegate = self;
    
    
    NSBundle* myBundle = [NSBundle bundleWithIdentifier:@"FDTakeTranslations"];
    NSLog(@"%@", myBundle);
    NSString *str = NSLocalizedStringFromTableInBundle(@"noSources",
                                                       nil,
                                                       [NSBundle bundleWithIdentifier:@"FDTakeTranslations"],
                                                       @"There are no sources available to select a photo");
    NSLog(@"%@", str);
    self.eggOnScreen = [self.fetchedResultsController fetchedObjects][1];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.eggSkinImage.image = [UIImage imageNamed:self.eggOnScreen.background];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.eggsList scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:SHRT_MAX/2 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}

- (NSFetchedResultsController *)fetchedResultsController{
    
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Egg entityName]];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"eggId" ascending:YES]];
        self.fetchedResultsController  = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
        self.fetchedResultsController.delegate = self;
        
        NSError *error;
        
        [self.fetchedResultsController performFetch:&error];
        
        NSLog(@"Selected %d photos",[self.fetchedResultsController fetchedObjects].count);
        NSAssert(!error, @"Error performing fetch request: %@", error);        
    }    
    return _fetchedResultsController;    
}


#pragma mark - UICollectionView Delegate methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    self.numberOfUniqeEggs = [sectionInfo numberOfObjects];
    return INT16_MAX;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"HEggCell";
    
    HEggCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSLog(@"Fake %d", indexPath.item % self.numberOfUniqeEggs);
    NSIndexPath *fakePosition = [NSIndexPath indexPathForItem:indexPath.item % self.numberOfUniqeEggs inSection:0];
    Egg *egg = [self.fetchedResultsController objectAtIndexPath:fakePosition];
    cell.layer.cornerRadius = RADIUS;
    cell.layer.masksToBounds = YES;
    NSLog(@"Egg background %@", egg.background);
    cell.eggImage.image = [UIImage imageNamed:egg.background];
    cell.contentView.backgroundColor = [UIColor redColor];
    return cell;
}


- (IBAction)tappedCell:(UITapGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self.eggsList];
    NSIndexPath *fakePosition = [NSIndexPath indexPathForItem:[self.eggsList indexPathForItemAtPoint:location].item % self.numberOfUniqeEggs inSection:0];
    Egg *egg = [self.fetchedResultsController objectAtIndexPath:fakePosition];
    if ([egg.type isEqualToString:ADD_NEW_EGG_TYPE]) {
        [self addNewEggBranch];
    }
    else {
        [self chooseNewSkinForEgg:egg];
    }
}


- (void)addNewEggBranch
{
    NSLog(@"Add new Egg");
    [self.takeController takePhotoOrChooseFromLibrary];
}


#pragma mark - FDTakeDelegate

- (void)takeController:(FDTakeController *)controller didCancelAfterAttempting:(BOOL)madeAttempt
{
//    UIAlertView *alertView;
//    if (madeAttempt)
//        alertView = [[UIAlertView alloc] initWithTitle:@"Example app" message:@"The take was cancelled after selecting media" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    else
//        alertView = [[UIAlertView alloc] initWithTitle:@"Example app" message:@"The take was cancelled without selecting media" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alertView show];
}

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)info
{
    NSManagedObjectContext *context = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    NSLog(@"geted image %@", photo);
    NSInteger eggId = self.numberOfUniqeEggs;
    [Egg addEggWithName:[NSString stringWithFormat:@"Image name %d", eggId] background:@"1.jpg" couldDelete:YES eggId:eggId type:USER_EGG_TYPE andContext:context];
}


- (void)chooseNewSkinForEgg:(Egg *)newEgg
{
    NSLog(@"reskin");
    self.activeToFight = YES;
    self.eggOnScreen = newEgg;
    self.eggSkinImage.image = [UIImage imageNamed:self.eggOnScreen.background];
}

- (void)deleteEggAtIndex:(NSIndexPath *)indexPath
{
    if (self.deleteEggAlert) {
        return;
    }
    NSLog(@"Try to delete %@", indexPath);
    NSIndexPath *fakePosition = [NSIndexPath indexPathForItem:indexPath.item % self.numberOfUniqeEggs inSection:0];
    Egg *egg = [self.fetchedResultsController objectAtIndexPath:fakePosition];
    HEggCell *eggCell = (HEggCell *)[self.eggsList cellForItemAtIndexPath:indexPath];
    if ([egg.type isEqualToString:USER_EGG_TYPE]) {
        [eggCell startJiggling];
        
        self.deleteEggAlert = [[UIAlertView alloc] initWithTitle:APP_NAME message:DELETE_EGG_MESSAGE delegate:self cancelButtonTitle:NO_MESSAGE otherButtonTitles:YES_MESSAGE, nil];
        self.selectedEgg = egg;
        [self.deleteEggAlert show];
    }    
}



- (void)deleteEgg
{
    if ([self.selectedEgg isEqual:self.eggOnScreen]) {
        NSInteger position = [[self.fetchedResultsController fetchedObjects] indexOfObject:self.selectedEgg];
        self.eggOnScreen = [self.fetchedResultsController fetchedObjects][position -1];
    }
    [self stopJigglingOnCollection];
    [[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext deleteObject:self.selectedEgg];
    NSError *error = nil;
    [[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:&error];
    if (error) {
        NSLog(@"Some problems on saving at favorites");
    }    
    self.selectedEgg = nil;
    self.deleteEggAlert = nil;
    [self chooseNewSkinForEgg: self.eggOnScreen];
}

- (IBAction)longPressForDelete:(UILongPressGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self.eggsList]; 
    [self deleteEggAtIndex: [self.eggsList indexPathForItemAtPoint:location]];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.eggsList reloadData];
}



#pragma mark - Sharing metods

- (IBAction)shareWithFriends:(UIBarButtonItem *)sender {
    [self.activityViewController presentFromRootViewController];
}



- (void)stopJigglingOnCollection
{
[self.eggsList.visibleCells makeObjectsPerformSelector:@selector(stopJiggling)];
}


#pragma mark - BUMP methods
- (void) configureBump {
    [self getEnemyInfo];
    [self bumpStatus];
    [self getBumpInfo];
    [self sendBumpData];
    [self catchBumpDetection];
}

- (void)getEnemyInfo{
    [[BumpClient sharedClient] setMatchBlock:^(BumpChannelID channel) {
        NSLog(@"Matched with user: %@", [[BumpClient sharedClient] userIDForChannel:channel]);
        [[BumpClient sharedClient] confirmMatch:YES onChannel:channel];
    }];
}

- (void)bumpStatus {
    [[BumpClient sharedClient] setConnectionStateChangedBlock:^(BOOL connected) {
        if (connected) {
            NSLog(@"Bump connected...");
        } else {
            NSLog(@"Bump disconnected...");
        }
    }];
}

- (void)getBumpInfo{
    [[BumpClient sharedClient] setDataReceivedBlock:^(BumpChannelID channel, NSData *data) {
        if (self.isActiveToFight) {
            NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary *response = [jsonString JSONValue];
            NSLog(@"Parsewd answer %@  %@", response, jsonString);
            self.enemyAttack = ((NSString *)response[ATTACK_KEY]).intValue;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showResults];
            });
            NSLog(@"Data received from %@: %@",
                  [[BumpClient sharedClient] userIDForChannel:channel], response
                  );
        }
    }];
}


- (void)sendBumpData
{
    
    self.userAttack = arc4random()%100;
    NSDictionary *dictionary = @{
                                 @"attack":[NSString stringWithFormat:@"%d", self.userAttack],
                                 };   
    
    
    [[BumpClient sharedClient] setChannelConfirmedBlock:^(BumpChannelID channel) {
        if (self.isActiveToFight) {
            NSLog(@"Channel with %@ confirmed.", [[BumpClient sharedClient] userIDForChannel:channel]);
            NSError *error ;
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
            if (!error) {
                [[BumpClient sharedClient] sendData:jsonData
                                          toChannel:channel];
                
            }
            
        }
    }];
    
}

- (void)catchBumpDetection{
    [[BumpClient sharedClient] setBumpEventBlock:^(bump_event event) {
        switch(event) {
            case BUMP_EVENT_BUMP:
                NSLog(@"Bump detected.");
                break;
            case BUMP_EVENT_NO_MATCH:
                NSLog(@"No match.");
                break;
        }
    }];
}

#pragma mark - Game Play
- (void)showResults
{
    self.activeToFight = NO;
    if (self.userAttack > self.enemyAttack) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_NAME message:WIN_MESSAGE delegate:self cancelButtonTitle:@"OK"otherButtonTitles: nil];
        alert.tag = TAG_WIN;
        [alert show];
    }
    else if (self.userAttack == self.enemyAttack){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_NAME message:TIE_MESSAGE delegate:self cancelButtonTitle:@"OK"otherButtonTitles: nil];
        [alert show];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_NAME message:LOSE_MESSAGE delegate:self cancelButtonTitle:@"OK"otherButtonTitles: nil];
        [alert show];     
    }    
}

- (void)crackAnimation
{
    NSLog(@"Show some animation");
}


#pragma mark - UIAlertView Delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isEqual:self.deleteEggAlert]) {
        if (buttonIndex == 0) {//cancel delete
            [self stopJigglingOnCollection];
            self.deleteEggAlert = nil;
            
        }
        else {//delete egg
            [self stopJigglingOnCollection];
            [self deleteEgg];
        }
    }
    else if (alertView.tag == TAG_WIN) {
        self.activeToFight = YES;
    }
    else if (alertView.tag == TAG_TIE) {
        self.activeToFight = YES;
    }
    else if (alertView.tag == TAG_LOSE) {
        self.activeToFight = NO;
    }
}


@end
