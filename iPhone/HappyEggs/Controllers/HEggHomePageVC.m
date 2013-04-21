//
//  HEggHomePageVC.m
//  HappyEggs
//
//  Created by Max on 21.04.13.
//  Copyright (c) 2013 Max Tymchii. All rights reserved.
//

#import "HEggHomePageVC.h"
#import "Egg.h"
#import "HEggCell.h"
#import "SBJson.h"


@interface HEggHomePageVC ()<NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UICollectionView *eggsList;
@property (nonatomic, strong) REActivityViewController *activityViewController;
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
    
    return [sectionInfo numberOfObjects];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"HEggCell";
    HEggCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    Egg *egg = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"Egg background %@", egg.background);
    cell.eggImage.image = [UIImage imageNamed:egg.background];
    cell.contentView.backgroundColor = [UIColor redColor];
    return cell;
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.eggsList reloadData];
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
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *response = [jsonString JSONValue];
        NSLog(@"Parsewd answer %@  %@", response, jsonString);
        
        NSLog(@"Data received from %@: %@",
              [[BumpClient sharedClient] userIDForChannel:channel], response
              );
    }];
}


- (void)sendBumpData{
    NSDictionary *dictionary = @{
                                 @"attack":@"0",
                                };
    
    
    
    [[BumpClient sharedClient] setChannelConfirmedBlock:^(BumpChannelID channel) {
        NSLog(@"Channel with %@ confirmed.", [[BumpClient sharedClient] userIDForChannel:channel]);
        NSError *error ;
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
        if (!error) {
            [[BumpClient sharedClient] sendData:jsonData
                                      toChannel:channel];
            
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


#pragma mark - Sharing metods

- (IBAction)shareWithFriends:(UIBarButtonItem *)sender {
    [self.activityViewController presentFromRootViewController];
}



@end
