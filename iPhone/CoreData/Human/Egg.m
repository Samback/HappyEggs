#import "Egg.h"

@implementation Egg
+ (void)addEggWithName:(NSString *)name background:(NSString *)background couldDelete:(BOOL)couldDelete eggId:(NSInteger)eggId andContext:(NSManagedObjectContext *)context
{
    Egg *egg = [NSEntityDescription insertNewObjectForEntityForName:@"Egg" inManagedObjectContext:context];;   
    egg.name = name;
    egg.background = name;
    egg.couldDelete = @(couldDelete);
    egg.eggId = @(eggId);
    NSError * error;
    //=====Спроба зберегти=====//
     [[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:&error];
}

@end
