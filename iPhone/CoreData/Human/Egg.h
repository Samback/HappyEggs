#import "_Egg.h"

@interface Egg : _Egg {}

+ (void)addEggWithName:(NSString *)name background:(NSString *)background couldDelete:(BOOL)couldDelete eggId:(NSInteger)eggId andContext:(NSManagedObjectContext *)context;
@end
