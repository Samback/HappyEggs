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

@interface HEggHomePageVC ()<NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UICollectionView *eggsList;
@end

@implementation HEggHomePageVC
#pragma mark - Lazy instantiation


- (void)viewDidLoad
{
    [super viewDidLoad];
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
    cell.eggImage.image = [UIImage imageNamed:egg.background];
    cell.contentView.backgroundColor = [UIColor redColor];
    return cell;
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.eggsList reloadData];
}



@end
