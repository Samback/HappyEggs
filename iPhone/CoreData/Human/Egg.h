#import "_Egg.h"

@interface Egg : _Egg {}

+ (void)addEggWithName:(NSString *)name background:(NSString *)background couldDelete:(BOOL)couldDelete eggId:(NSInteger)eggId type:(NSString *)type andContext:(NSManagedObjectContext *)context;
@end
