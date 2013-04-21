#import "Egg.h"

@implementation Egg
+ (void)addEggWithName:(NSString *)name background:(NSString *)background couldDelete:(BOOL)couldDelete eggId:(NSInteger)eggId andContext:(NSManagedObjectContext *)context
{
    Egg *egg = nil;
    egg = [NSEntityDescription insertNewObjectForEntityForName:[Egg entityName] inManagedObjectContext:context];
    egg.name = name;
    egg.background = name;
    egg.couldDelete = @(couldDelete);
    egg.eggId = @(eggId);
}

@end
