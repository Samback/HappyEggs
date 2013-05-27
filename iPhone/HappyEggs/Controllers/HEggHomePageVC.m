//
//  HEggHomePageVC.m
//  HappyEggs
//
//  Created by Max on 21.04.13.
//  Copyright (c) 2013 Max Tymchii. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "HEggHomePageVC.h"
#import "Egg.h"
#import "HEggCell.h"
#import "SBJson.h"
#import "LBChildBrowserViewController.h"
#import "GADBannerView.h"

#define BOTTOM_BACKGROUND_IMAGE_NAME @"bottom_background"
#define  RADIUS 15

#define TAG_WIN 0
#define TAG_TIE 1
#define TAG_LOSE 2

#define SCALED_TIMES 2.0

@interface HEggHomePageVC ()<NSFetchedResultsControllerDelegate, FDTakeDelegate, UIAlertViewDelegate, AVAudioPlayerDelegate>
@property (nonatomic, strong)   AVAudioPlayer *audioPlayer;
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
@property (atomic) __block BOOL activeToFight;

@property (weak, nonatomic) IBOutlet UIView *tableContainer;
@property (weak, nonatomic) IBOutlet UIImageView *topSkinn;

@property (nonatomic, strong) NSArray *scratchArray;
@property (nonatomic, strong) GADBannerView *mobileBanner;
@property (nonatomic, strong) NSArray *soundsList;
@end

@implementation HEggHomePageVC
#pragma mark - Lazy instantiation


- (NSArray *)soundsList
{
    if (!_soundsList) {
        _soundsList = @[@"sound_1",
                        @"sound_2",
                        @"sound_3"];
    }
    return _soundsList;
}

- (NSArray *)scratchArray
{
    if (!_scratchArray) {
        if (IS_IPHONE_5) {
            _scratchArray = @[
                              @"first_scratch_iphone_5",
                              @"second_scratch_iphone_5",
                              @"third_scratch_iphone_5"
                              ];
        }
        else {
            _scratchArray = @[
                              @"first_scratch",
                              @"second_scratch",
                              @"third_scratch"
                              ];
        }
    }
    return _scratchArray;
}


- (REActivityViewController *)activityViewController{
//    if (!_activityViewController) {
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
        UIGraphicsBeginImageContext(self.view.bounds.size);
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();             UIGraphicsEndImageContext();
        UIGraphicsEndImageContext();
        activityViewController.userInfo = @{
                                            @"image": viewImage,
                                            @"text": SHARING_TEXT,
                                            @"url": [NSURL URLWithString:SHARING_URL_FOR_APP],
                                            };

        _activityViewController = activityViewController;
//    }
    return _activityViewController;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = APP_NAME;
    self.activeToFight = YES;
    self.tableContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BOTTOM_BACKGROUND_IMAGE_NAME]];
    self.topSkinn.image = [UIImage imageNamed:TOP_GROUND_IMAGE_NAME];
    [self configureBump];
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
    [self chooseNewSkinForEgg:self.eggOnScreen];
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
    UIImage *reScaled = [UIImage imageWithCGImage:[HEggHelperMethods imageForEgg:egg].CGImage scale:SCALED_TIMES orientation:egg.orientationValue];
   // UIImage* cropped = [ reScaled cropToSize:CGSizeMake(80, 120) usingMode:NYXCropModeCenter];
    cell.eggImage.image = reScaled;
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
    NSLog(@"Photo %@", photo);
    NSString *path = [self saveImage:photo withName:[[NSDate date] description]];
    if (path) {
        NSManagedObjectContext *context = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
        NSInteger eggId = self.numberOfUniqeEggs;
        [Egg addEggWithName:[NSString stringWithFormat:@"Image name %d", eggId] background:path couldDelete:YES eggId:eggId type:USER_EGG_TYPE orientation:photo.imageOrientation andContext:context];
    }   
}

- (NSString *)saveImage:(UIImage*)image withName:(NSString *)name
{
    if (image != nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"%@.png", name]];
        NSLog(@"Path to file %@", path);
        NSData* data = UIImagePNGRepresentation(image);
        [data writeToFile:path atomically:YES];
        return path;
    }
    return nil;
}

- (void)chooseNewSkinForEgg:(Egg *)newEgg
{
    NSLog(@"reskin");
    self.activeToFight = YES;
    self.eggOnScreen = newEgg;
    self.topSkinn.image = [UIImage imageNamed:TOP_GROUND_IMAGE_NAME];
    UIImage *beforeScale = [HEggHelperMethods imageForEgg:self.eggOnScreen];
    UIImage *scaled = [UIImage imageWithCGImage:beforeScale.CGImage scale:SCALED_TIMES orientation:self.eggOnScreen.orientationValue];
    //UIImage* cropped = [scaled cropToSize:CGSizeMake(480, 480) usingMode:NYXCropModeCenter];
    self.eggSkinImage.contentMode = UIViewContentModeScaleAspectFit;
    self.eggSkinImage.image = scaled;
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


#pragma mark - Open Statistci

- (IBAction)openStatistic:(UIBarButtonItem *)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    LBChildBrowserViewController *browser = [mainStoryboard instantiateViewControllerWithIdentifier:@"LBChildBrowserViewController"];
    NSString *chartURL = [NSString stringWithFormat:@"%@%@%@", BASE_URL, CHART_TAIL_URL, [HEggHelperMethods getUUID]];
    [browser setCurrentURL:chartURL];
    [self presentViewController:browser animated:YES completion:NULL];
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
        if (self.activeToFight) {
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
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_NAME message:UPDATE_YOUR_EGG delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            NSLog(@"Cant to bump");
        }
    }];
}


- (void)sendBumpData
{  
    
    [[BumpClient sharedClient] setChannelConfirmedBlock:^(BumpChannelID channel) {
            NSLog(@"active to fight %d", self.activeToFight);
            if (self.activeToFight) {
                NSLog(@"Channel with %@ confirmed.", [[BumpClient sharedClient] userIDForChannel:channel]);
                self.userAttack = arc4random() % 100;
                NSDictionary *dictionary = @{
                                             @"attack":[NSString stringWithFormat:@"%d", self.userAttack],
                                             };
                
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
    NSString *result = @"win";
    if (self.userAttack > self.enemyAttack) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_NAME message:WIN_MESSAGE delegate:self cancelButtonTitle:@"OK"otherButtonTitles: nil];
        alert.tag = TAG_WIN;
        result = @"win";
        [alert show];
    }
    else if (self.userAttack == self.enemyAttack){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_NAME message:TIE_MESSAGE delegate:self cancelButtonTitle:@"OK"otherButtonTitles: nil];
        result = @"tie";
        [alert show];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_NAME message:LOSE_MESSAGE delegate:self cancelButtonTitle:@"OK"otherButtonTitles: nil];
        result = @"lose";
        [alert show];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.activeToFight = NO;
            [self playScratch];
        });

        
        int numberOfElements = self.scratchArray.count;
        int position = arc4random() % numberOfElements;
        UIImage *scratchImage = [UIImage imageNamed:self.scratchArray[position%numberOfElements]];
        self.topSkinn.image = scratchImage;
    }
    [self sendPostWithResults:result];
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
}


-(UIImage*) drawImage:(UIImage*) fgImage
              inImage:(UIImage*) bgImage
              atPoint:(CGPoint)  point
{
    UIGraphicsBeginImageContextWithOptions(bgImage.size, FALSE, 0.0);
    [bgImage drawInRect:CGRectMake( 0, 0, bgImage.size.width, bgImage.size.height)];
    [fgImage drawInRect:CGRectMake( point.x, point.y, fgImage.size.width, fgImage.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


- (void)sendPostWithResults:(NSString *)fightResult
{
    NSString *path = [NSString stringWithFormat:@"%@%@%@", BASE_URL, POST_TAIL_URL, [HEggHelperMethods getUUID]];
    NSURL *url = [NSURL URLWithString:path];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary *postParameters = @{
                                     @"state" : fightResult,
                                     @"name"  : [HEggHelperMethods userNickName],
                                     @"platform" : @"ios"
                                     };
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:nil parameters:postParameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
     }];
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON){
                                                        NSLog(@"Success result %@", (NSDictionary *)JSON);
                                                    }
                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                        NSLog(@"Request Error [%@] JSon =   %@", [error localizedDescription],(NSDictionary *)JSON);
                                                    }];
        [operation start];
}



#pragma mark - Google Ad 
- (void)addBannerScreen
{
    // Create a view of the standard size at the top of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    self.mobileBanner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    
    // Specify the ad's "unit identifier". This is your AdMob Publisher ID.
    self.mobileBanner.adUnitID = MY_BANNER_UNIT_ID;
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    self.mobileBanner.rootViewController = self;
    [self.view addSubview: self.mobileBanner];
    
    // Initiate a generic request to load it with an ad.
    [self.mobileBanner loadRequest:[GADRequest request]];
}


#pragma mark - Play Scratch

- (void)playScratch
{
    int rand =  arc4random()%(self.soundsList.count - 1);
    NSString *sound = self.soundsList[rand];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:sound
                                         ofType:@"mp3"]];
    
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc]
                   initWithContentsOfURL:url
                   error:&error];
    if (error)
    {
        NSLog(@"Error in audioPlayer: %@",
              [error localizedDescription]);
    } else {
        self.audioPlayer.delegate = self;
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
    }
}

@end
