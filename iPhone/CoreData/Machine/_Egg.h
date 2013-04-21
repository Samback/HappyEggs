// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Egg.h instead.

#import <CoreData/CoreData.h>


extern const struct EggAttributes {
	__unsafe_unretained NSString *background;
	__unsafe_unretained NSString *couldDelete;
	__unsafe_unretained NSString *eggId;
	__unsafe_unretained NSString *name;
} EggAttributes;

extern const struct EggRelationships {
} EggRelationships;

extern const struct EggFetchedProperties {
} EggFetchedProperties;







@interface EggID : NSManagedObjectID {}
@end

@interface _Egg : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (EggID*)objectID;




@property (nonatomic, strong) NSString* background;


//- (BOOL)validateBackground:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* couldDelete;


@property BOOL couldDeleteValue;
- (BOOL)couldDeleteValue;
- (void)setCouldDeleteValue:(BOOL)value_;

//- (BOOL)validateCouldDelete:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* eggId;


@property int16_t eggIdValue;
- (int16_t)eggIdValue;
- (void)setEggIdValue:(int16_t)value_;

//- (BOOL)validateEggId:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;






@end

@interface _Egg (CoreDataGeneratedAccessors)

@end

@interface _Egg (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveBackground;
- (void)setPrimitiveBackground:(NSString*)value;




- (NSNumber*)primitiveCouldDelete;
- (void)setPrimitiveCouldDelete:(NSNumber*)value;

- (BOOL)primitiveCouldDeleteValue;
- (void)setPrimitiveCouldDeleteValue:(BOOL)value_;




- (NSNumber*)primitiveEggId;
- (void)setPrimitiveEggId:(NSNumber*)value;

- (int16_t)primitiveEggIdValue;
- (void)setPrimitiveEggIdValue:(int16_t)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




@end
