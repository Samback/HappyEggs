#import "Egg.h"

@implementation Egg
+ (void)addEggWithName:(NSString *)name background:(NSString *)background couldDelete:(BOOL)couldDelete eggId:(NSInteger)eggId type:(NSString *)type orientation:(UIImageOrientation)imageOrientation andContext:(NSManagedObjectContext *)context
{
    Egg *egg = [NSEntityDescription insertNewObjectForEntityForName:@"Egg" inManagedObjectContext:context];;   
    egg.name = name;
    egg.background = background;
    egg.couldDelete = @(couldDelete);
    egg.eggId = @(eggId);
    egg.type = type;
    egg.orientation = @(imageOrientation);
    NSError * error;
    //=====Спроба зберегти=====//
     [[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:&error];
}

@end
