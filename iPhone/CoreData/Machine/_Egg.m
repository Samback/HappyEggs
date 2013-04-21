// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Egg.m instead.

#import "_Egg.h"

const struct EggAttributes EggAttributes = {
	.background = @"background",
	.couldDelete = @"couldDelete",
	.eggId = @"eggId",
	.name = @"name",
	.type = @"type",
};

const struct EggRelationships EggRelationships = {
};

const struct EggFetchedProperties EggFetchedProperties = {
};

@implementation EggID
@end

@implementation _Egg

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Egg" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Egg";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Egg" inManagedObjectContext:moc_];
}

- (EggID*)objectID {
	return (EggID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"couldDeleteValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"couldDelete"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"eggIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"eggId"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic background;






@dynamic couldDelete;



- (BOOL)couldDeleteValue {
	NSNumber *result = [self couldDelete];
	return [result boolValue];
}

- (void)setCouldDeleteValue:(BOOL)value_ {
	[self setCouldDelete:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveCouldDeleteValue {
	NSNumber *result = [self primitiveCouldDelete];
	return [result boolValue];
}

- (void)setPrimitiveCouldDeleteValue:(BOOL)value_ {
	[self setPrimitiveCouldDelete:[NSNumber numberWithBool:value_]];
}





@dynamic eggId;



- (int16_t)eggIdValue {
	NSNumber *result = [self eggId];
	return [result shortValue];
}

- (void)setEggIdValue:(int16_t)value_ {
	[self setEggId:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveEggIdValue {
	NSNumber *result = [self primitiveEggId];
	return [result shortValue];
}

- (void)setPrimitiveEggIdValue:(int16_t)value_ {
	[self setPrimitiveEggId:[NSNumber numberWithShort:value_]];
}





@dynamic name;






@dynamic type;











@end
