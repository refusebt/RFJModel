//
//  RFJModel.m
//  RF
//
//  Created by gouzhehua on 14-12-5.
//  Copyright (c) 2014年 GZH. All rights reserved.
//

#import "RFJModel.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSUInteger, RFJModelPropertyType)
{
	RFJModelPropertyTypeNone = 0,
	RFJModelPropertyTypeBOOL,
	RFJModelPropertyTypeInt16,
	RFJModelPropertyTypeInt32,
	RFJModelPropertyTypeInt64,
	RFJModelPropertyTypeFloat,
	RFJModelPropertyTypeDouble,
	RFJModelPropertyTypeString,
	RFJModelPropertyTypeMutableString,
	RFJModelPropertyTypeArray,
	RFJModelPropertyTypeMutableArray,
	RFJModelPropertyTypeModelArray,
	RFJModelPropertyTypeMutableModelArray,
	RFJModelPropertyTypeDictionary,
	RFJModelPropertyTypeMutableDictionary,
	RFJModelPropertyTypeModel,
};

static char* s_RFJModelPropertyTypeName[] =
{
	"RFJModelPropertyTypeNone",
	"RFJModelPropertyTypeBOOL",
	"RFJModelPropertyTypeInt16",
	"RFJModelPropertyTypeInt32",
	"RFJModelPropertyTypeInt64",
	"RFJModelPropertyTypeFloat",
	"RFJModelPropertyTypeDouble",
	"RFJModelPropertyTypeString",
	"RFJModelPropertyTypeMutableString",
	"RFJModelPropertyTypeArray",
	"RFJModelPropertyTypeMutableArray",
	"RFJModelPropertyTypeModelArray",
	"RFJModelPropertyTypeMutableModelArray",
	"RFJModelPropertyTypeDictionary",
	"RFJModelPropertyTypeMutableDictionary",
	"RFJModelPropertyTypeModel"
};

@interface RFJModelPropertyInfo : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *mapName;
@property (nonatomic, strong) NSString *var;
@property (nonatomic, assign) RFJModelPropertyType type;
@property (nonatomic, assign) const char *modelClassName;
@property (nonatomic, assign) Class modelClass;

+ (NSMutableDictionary *)mapNSObjectProperties;
+ (NSMutableDictionary *)mapPropertyInfosWithClass:(Class)cls;
+ (NSMutableArray *)propertyNamesWithClass:(Class)cls;
+ (RFJModelPropertyInfo *)propertyInfoWithProperty:(objc_property_t *)property;

@end

@interface RFJModel ()
+ (NSMutableDictionary *)modelInfos;
+ (NSMutableDictionary *)propertyInfos;
- (void)descriptionWithBuffer:(NSMutableString *)buffer indent:(NSInteger)indent;
@end

static NSRecursiveLock *s_RFJModelLock = nil;

#pragma mark - RFJModel

@implementation RFJModel

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		s_RFJModelLock = [[NSRecursiveLock alloc] init];
		s_RFJModelLock.name = @"RFJModelLock";
	});
}

+ (void)initialize
{
	if ([self class] != [RFJModel class])
	{
		[s_RFJModelLock lock];
		{
			const char *className = object_getClassName([self class]);
			
			NSMutableDictionary *mapPropertyInfos = [RFJModelPropertyInfo mapPropertyInfosWithClass:[self class]];
			[[RFJModel modelInfos] setObject:mapPropertyInfos forKey:[NSValue valueWithPointer:className]];
			
			NSArray *propertyNames = [RFJModelPropertyInfo propertyNamesWithClass:[self class]];
			[[RFJModel propertyInfos] setObject:propertyNames forKey:[NSValue valueWithPointer:className]];
		}
		[s_RFJModelLock unlock];
	}
}

- (id)init
{
	self = [super init];
	if (self)
	{
		
	}
	return self;
}

- (id)initWithJsonDict:(NSDictionary *)jsonDict
{
	self = [super init];
	if (self)
	{
		[self fillWithJsonDict:jsonDict];
	}
	return self;
}

- (NSString *)description
{
	NSMutableString *buffer = [NSMutableString string];
	[self descriptionWithBuffer:buffer indent:0];
	return buffer;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if ([aDecoder isKindOfClass:[NSKeyedUnarchiver class]])
	{
		const char *className = object_getClassName([self class]);
		NSArray *propertyNames = nil;
		
		[s_RFJModelLock lock];
		{
			propertyNames = [[RFJModel propertyInfos] objectForKey:[NSValue valueWithPointer:className]];
		}
		[s_RFJModelLock unlock];
		
		for (NSString *propertyName in propertyNames)
		{
			id value = [aDecoder decodeObjectForKey:propertyName];
			if (value != nil)
			{
				[self setValue:value forKey:propertyName];
			}
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	const char *className = object_getClassName([self class]);
	NSArray *propertyNames = nil;
	
	[s_RFJModelLock lock];
	{
		propertyNames = [[RFJModel propertyInfos] objectForKey:[NSValue valueWithPointer:className]];
	}
	[s_RFJModelLock unlock];
	
	for (NSString *propertyName in propertyNames)
	{
		id value = [self valueForKey:propertyName];
		if (value != nil && [value conformsToProtocol:@protocol(NSCoding)])
		{
			[aCoder encodeObject:value forKey:propertyName];
		}
	}
}

- (void)descriptionWithBuffer:(NSMutableString *)buffer indent:(NSInteger)indent
{
	NSMutableDictionary *mapNSObjectProperties = [RFJModelPropertyInfo mapNSObjectProperties];
	
	NSMutableString *indentString = [NSMutableString string];
	for (NSInteger i = 0; i < indent; i++)
	{
		[indentString appendString:@"\t"];
	}
	NSString *replaceString = [NSString stringWithFormat:@"\n%@", indentString];
	
	Class current = [self class];
	while (current != [RFJModel class])
	{
		unsigned count = 0;
		objc_property_t *properties = class_copyPropertyList(current, &count);
		for (unsigned i = 0; i < count; i++)
		{
			objc_property_t property = properties[i];
			RFJModelPropertyInfo *pi = [RFJModelPropertyInfo propertyInfoWithProperty:&property];
			if (pi != nil)
			{
				// JProperty
				id value = [self valueForKey:pi.name];
				switch (pi.type)
				{
					case RFJModelPropertyTypeModel:
						{
							[buffer appendFormat:@"\n%@JP name:%@ type:%s map:%@ value:", indentString, pi.name, s_RFJModelPropertyTypeName[pi.type], pi.mapName];
							RFJModel *model = value;
							[model descriptionWithBuffer:buffer indent:indent+1];
						}
						break;
					case RFJModelPropertyTypeModelArray:
					case RFJModelPropertyTypeMutableModelArray:
						{
							[buffer appendFormat:@"\n%@JP name:%@ type:%s map:%@ value:", indentString, pi.name, s_RFJModelPropertyTypeName[pi.type], pi.mapName];
							NSArray *models = value;
							for (NSInteger i = 0; i < models.count; i++)
							{
								RFJModel *model = models[i];
								[buffer appendFormat:@"\n\t%@-", indentString];
								[model descriptionWithBuffer:buffer indent:indent+1];
							}
						}
						break;
					default:
						{
							NSString *valueString = [value description];
							valueString = [valueString stringByReplacingOccurrencesOfString:@"\n" withString:replaceString];
							[buffer appendFormat:@"\n%@JP name:%@ type:%s map:%@ value:%@", indentString, pi.name, s_RFJModelPropertyTypeName[pi.type], pi.mapName, valueString];
						}
						break;
				}
			}
			else
			{
				// no JProperty
				NSString *name = [NSString stringWithUTF8String:property_getName(property)];
				if ([mapNSObjectProperties valueForKey:name] != nil)
					continue;
				id value = [self valueForKey:name];
				NSString *valueString = [value description];
				valueString = [valueString stringByReplacingOccurrencesOfString:@"\n" withString:replaceString];
				[buffer appendFormat:@"\n%@ P name:%@ value:%@", indentString, name, valueString];
			}
		}
		free(properties);
		
		current = [current superclass];
	}
}

- (void)fillWithJsonDict:(NSDictionary *)jsonDict
{
	const char *className = object_getClassName([self class]);
	NSDictionary *mapPropertyInfos = nil;
	
	[s_RFJModelLock lock];
	{
		mapPropertyInfos = [[RFJModel modelInfos] objectForKey:[NSValue valueWithPointer:className]];
	}
	[s_RFJModelLock unlock];
	
	for (NSString *key in jsonDict)
	{
		RFJModelPropertyInfo *info = mapPropertyInfos[key];
		if (info != nil)
		{
			switch (info.type)
			{
				case RFJModelPropertyTypeBOOL:
					[self setValue:J2NumBool(jsonDict[key]) forKey:info.name];
					break;
				case RFJModelPropertyTypeInt16:
					[self setValue:J2NumInt16(jsonDict[key]) forKey:info.name];
					break;
				case RFJModelPropertyTypeInt32:
					[self setValue:J2NumInt32(jsonDict[key]) forKey:info.name];
					break;
				case RFJModelPropertyTypeInt64:
					[self setValue:J2NumInt64(jsonDict[key]) forKey:info.name];
					break;
				case RFJModelPropertyTypeFloat:
					[self setValue:J2NumFloat(jsonDict[key]) forKey:info.name];
					break;
				case RFJModelPropertyTypeDouble:
					[self setValue:J2NumDouble(jsonDict[key]) forKey:info.name];
					break;
				case RFJModelPropertyTypeString:
					{
						NSString *value = J2Str(jsonDict[key]);
						[self setValue:value forKey:info.name];
					}
					break;
				case RFJModelPropertyTypeMutableString:
					{
						NSString *value = J2Str(jsonDict[key]);
						if (value != nil)
							[self setValue:[RFJModel deepMutableCopyWithJson:value] forKey:info.name];
						else
							[self setValue:nil forKey:info.name];
					}
					break;
				case RFJModelPropertyTypeArray:
					{
						NSArray *value = J2Array(jsonDict[key]);
						[self setValue:value forKey:info.name];
					}
					break;
				case RFJModelPropertyTypeMutableArray:
					{
						NSArray *value = J2Array(jsonDict[key]);
						if (value != nil)
							[self setValue:[RFJModel deepMutableCopyWithJson:value] forKey:info.name];
						else
							[self setValue:nil forKey:info.name];
					}
					break;
				case RFJModelPropertyTypeModelArray:
				case RFJModelPropertyTypeMutableModelArray:
					{
						NSArray *array = J2Array(jsonDict[key]);
						if (array != nil)
						{
							NSMutableArray *models = [NSMutableArray array];
							for (NSInteger i = 0; i < array.count; i++)
							{
								NSDictionary *dict = J2Dict(array[i]);
								if (dict != nil)
								{
									RFJModel *model = [[info.modelClass alloc] init];
									[model fillWithJsonDict:dict];
									[models addObject:model];
								}
							}
							
							if (info.type == RFJModelPropertyTypeModelArray)
								[self setValue:[NSArray arrayWithArray:models] forKey:info.name];
							else
								[self setValue:models forKey:info.name];
						}
						else
							[self setValue:nil forKey:info.name];
					}
					break;
				case RFJModelPropertyTypeDictionary:
					{
						NSDictionary *value = J2Dict(jsonDict[key]);
						[self setValue:value forKey:info.name];
					}
					break;
				case RFJModelPropertyTypeMutableDictionary:
					{
						NSDictionary *value = J2Dict(jsonDict[key]);
						if (value != nil)
							[self setValue:[RFJModel deepMutableCopyWithJson:value] forKey:info.name];
						else
							[self setValue:nil forKey:info.name];
					}
					break;
				case RFJModelPropertyTypeModel:
					{
						NSDictionary *dict = J2Dict(jsonDict[key]);
						if (dict != nil)
						{
							RFJModel *model = [[info.modelClass alloc] init];
							[model fillWithJsonDict:dict];
							[self setValue:model forKey:info.name];
						}
						else
							[self setValue:nil forKey:info.name];
					}
					break;
				default:
					break;
			}
		}
	}
}

- (NSMutableDictionary *)toMutableDictionary
{
	NSMutableDictionary *container = [NSMutableDictionary dictionary];
	const char *className = object_getClassName([self class]);
	NSDictionary *mapPropertyInfos = nil;
	
	[s_RFJModelLock lock];
	{
		mapPropertyInfos = [[RFJModel modelInfos] objectForKey:[NSValue valueWithPointer:className]];
	}
	[s_RFJModelLock unlock];
	
	for (NSString *key in mapPropertyInfos)
	{
		RFJModelPropertyInfo *info = mapPropertyInfos[key];
		id value = [self valueForKey:info.name];
		if (value != nil)
		{
			switch (info.type)
			{
				case RFJModelPropertyTypeBOOL:
				case RFJModelPropertyTypeInt16:
				case RFJModelPropertyTypeInt32:
				case RFJModelPropertyTypeInt64:
				case RFJModelPropertyTypeFloat:
				case RFJModelPropertyTypeDouble:
				case RFJModelPropertyTypeString:
				case RFJModelPropertyTypeMutableString:
				case RFJModelPropertyTypeArray:
				case RFJModelPropertyTypeMutableArray:
				case RFJModelPropertyTypeDictionary:
				case RFJModelPropertyTypeMutableDictionary:
					{
						[container setObject:value forKey:info.mapName];
					}
					break;
				case RFJModelPropertyTypeModelArray:
				case RFJModelPropertyTypeMutableModelArray:
					{
						NSMutableArray *newArray = [NSMutableArray array];
						NSArray *array = value;
						for (NSInteger i = 0; i < array.count; i++)
						{
							id arrayValue = array[i];
							if ([arrayValue isKindOfClass:[RFJModel class]])
							{
								RFJModel *arrayModel = arrayValue;
								NSMutableDictionary *dict = [arrayModel toMutableDictionary];
								if (dict != nil)
								{
									[newArray addObject:dict];
								}
							}
						}
						[container setObject:newArray forKey:info.mapName];
					}
					break;
				case RFJModelPropertyTypeModel:
					{
						RFJModel *arrayModel = value;
						NSMutableDictionary *dict = [arrayModel toMutableDictionary];
						if (dict != nil)
						{
							[container setObject:dict forKey:info.mapName];
						}
					}
					break;
				default:
					break;
			}
		}
	}
	
	return container;
}

- (NSString *)toJsonString
{
	NSMutableDictionary *dict = [self toMutableDictionary];
	NSData *buffer = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
	return [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding];
}

+ (NSString *)toStringWithJsonValue:(id)value
{
	if (value == nil || value == [NSNull null])
	{
		return nil;
	}
	
	if ([value isKindOfClass:[NSString class]])
	{
		return value;
	}
	
	if ([value isKindOfClass:[NSNumber class]])
	{
		return  [value stringValue];
	}
	
	return nil;
}

+ (NSInteger)toIntegerWithJsonValue:(id)value
{
	if (value == nil || value == [NSNull null])
	{
		return 0;
	}
	
	if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]])
	{
		return [value integerValue];
	}
	
	return 0;
}

+ (BOOL)toBoolWithJsonValue:(id)value
{
	if (value == nil || value == [NSNull null])
	{
		return NO;
	}
	
	if ([value isKindOfClass:[NSNumber class]])
	{
		return [value boolValue];
	}
	
	if ([value isKindOfClass:[NSString class]])
	{
		return [value boolValue];
	}
	
	return NO;
}

+ (int16_t)toInt16WithJsonValue:(id)value
{
	if (value == nil || value == [NSNull null])
	{
		return 0;
	}
	
	if ([value isKindOfClass:[NSNumber class]])
	{
		return [value shortValue];
	}
	
	if ([value isKindOfClass:[NSString class]])
	{
		return [value intValue];
	}
	
	return 0;
}

+ (int32_t)toInt32WithJsonValue:(id)value
{
	if (value == nil || value == [NSNull null])
	{
		return 0;
	}
	
	if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]])
	{
		return [value intValue];
	}
	
	return 0;
}

+ (int64_t)toInt64WithJsonValue:(id)value
{
	if (value == nil || value == [NSNull null])
	{
		return 0;
	}
	
	if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]])
	{
		return [value longLongValue];
	}
	
	return 0;
}

+ (short)toShortWithJsonValue:(id)value
{
	if (value == nil || value == [NSNull null])
	{
		return 0;
	}
	
	if ([value isKindOfClass:[NSNumber class]])
	{
		return [value shortValue];
	}
	
	if ([value isKindOfClass:[NSString class]])
	{
		return [value intValue];
	}
	
	return 0;
}

+ (float)toFloatWithJsonValue:(id)value
{
	if (value == nil || value == [NSNull null])
	{
		return 0;
	}
	
	if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]])
	{
		return [value floatValue];
	}
	
	return 0;
}

+ (double)toDoubleWithJsonValue:(id)value
{
	if (value == nil || value == [NSNull null])
	{
		return 0;
	}
	
	if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]])
	{
		return [value doubleValue];
	}
	
	return 0;
}

+ (id)toArrayWithJsonValue:(id)value
{
	if (value == nil || value == [NSNull null])
	{
		return nil;
	}
	
	if ([value isKindOfClass:[NSArray class]])
	{
		return value;
	}
	
	return nil;
}

+ (id)toDictionaryWithJsonValue:(id)value
{
	if (value == nil || value == [NSNull null])
	{
		return nil;
	}
	
	if ([value isKindOfClass:[NSDictionary class]])
	{
		return value;
	}
	
	return nil;
}

+ (id)toValue:(id)value ofClass:(Class)cls
{
	if ([value isKindOfClass:cls])
	{
		return value;
	}
	return nil;
}

+ (id)deepMutableCopyWithJson:(id)json
{
	if (json == nil || [json isKindOfClass:[NSNull class]])
	{
		return [NSMutableString stringWithFormat:@""];
	}
	
	if ([json isKindOfClass:[NSString class]])
	{
		return [NSMutableString stringWithFormat:@"%@", json];
	}
	
	if ([json isKindOfClass:[NSNumber class]])
	{
		return json;
	}
	
	if ([json isKindOfClass:[NSArray class]])
	{
		NSMutableArray *array = [NSMutableArray array];
		for (id value in json)
		{
			[array addObject:[RFJModel deepMutableCopyWithJson:value]];
		}
		return array;
	}
	
	if ([json isKindOfClass:[NSDictionary class]])
	{
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		for (NSString *key in json)
		{
			id value = [RFJModel deepMutableCopyWithJson:json[key]];
			[dict setObject:value forKey:key];
		}
		return dict;
	}
	
	return json;
}

+ (NSData *)toDataWithModel:(RFJModel *)model
{
	@autoreleasepool
	{
		NSMutableData* saveData = [[NSMutableData alloc] init];
		NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:saveData];
		[archiver encodeRootObject:model];
		[archiver finishEncoding];
		return saveData;
	}
}

+ (id)toModelWithData:(NSData *)data class:(Class)cls
{
	@autoreleasepool
	{
		if (data != nil && data.length > 0)
		{
			NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
			id object = [unArchiver decodeObject];
			if (cls == nil)
				return object;
			
			if ([object isKindOfClass:cls])
				return object;
		}
		return nil;
	}
}

+ (NSMutableDictionary *)modelInfos
{
	static NSMutableDictionary *s_instance = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		s_instance = [[NSMutableDictionary alloc] init];
	});
	
	return s_instance;
}

+ (NSMutableDictionary *)propertyInfos
{
	static NSMutableDictionary *s_instance = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		s_instance = [[NSMutableDictionary alloc] init];
	});
	
	return s_instance;
}

@end

#pragma mark - RFJModelPropertyInfo

@implementation RFJModelPropertyInfo

+ (NSMutableDictionary *)mapNSObjectProperties
{
	static NSMutableDictionary *s_map = nil;
	if (s_map == nil)
	{
		s_map = [NSMutableDictionary dictionary];
		Protocol *protocol = objc_getProtocol("NSObject");
		unsigned count = 0;
		objc_property_t *properties = protocol_copyPropertyList(protocol, &count);
		for (unsigned i = 0; i < count; i++)
		{
			objc_property_t property = properties[i];
			NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
			[s_map setObject:propertyName forKey:propertyName];
		}
		free(properties);
		
		// IOS7及以前应对
		if (s_map.count == 0)
		{
			[s_map setObject:@"hash" forKey:@"hash"];
			[s_map setObject:@"superclass" forKey:@"superclass"];
			[s_map setObject:@"description" forKey:@"description"];
			[s_map setObject:@"debugDescription" forKey:@"debugDescription"];
		}
	}
	return s_map;
}

+ (NSMutableDictionary *)mapPropertyInfosWithClass:(Class)cls
{
	NSMutableDictionary *mapProperInfos = [NSMutableDictionary dictionary];
	
	if ([cls isSubclassOfClass:[RFJModel class]])
	{
		Class current = cls;
		while (current != [RFJModel class])
		{
			unsigned count = 0;
			objc_property_t *properties = class_copyPropertyList(current, &count);
			for (unsigned i = 0; i < count; i++)
			{
				objc_property_t property = properties[i];
				RFJModelPropertyInfo *pi = [RFJModelPropertyInfo propertyInfoWithProperty:&property];
				if (pi != nil)
				{
					[mapProperInfos setObject:pi forKey:pi.mapName];
				}
			}
			free(properties);
			
			current = [current superclass];
		}
	}
	
	return mapProperInfos;
}

+ (NSMutableArray *)propertyNamesWithClass:(Class)cls
{
	NSMutableDictionary *mapNSObjectProperties = [RFJModelPropertyInfo mapNSObjectProperties];
	NSMutableArray *mapPropertyNames = [NSMutableArray array];
	
	if ([cls isSubclassOfClass:[RFJModel class]])
	{
		Class current = cls;
		while (current != [RFJModel class])
		{
			unsigned count = 0;
			objc_property_t *properties = class_copyPropertyList(current, &count);
			for (unsigned i = 0; i < count; i++)
			{
				objc_property_t property = properties[i];
				NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
				if ([mapNSObjectProperties objectForKey:propertyName] == nil)
					[mapPropertyNames addObject:propertyName];
			}
			free(properties);
			
			current = [current superclass];
		}
	}
	
	return mapPropertyNames;
}

// TODO: NSScanner
+ (RFJModelPropertyInfo *)propertyInfoWithProperty:(objc_property_t *)property
{
	RFJModelPropertyInfo *info = [[RFJModelPropertyInfo alloc] init];
	info.name = [NSString stringWithUTF8String:property_getName(*property)];
	
	NSString *propertyAttrString = [NSString stringWithUTF8String:property_getAttributes(*property)];
	NSArray *propertyAttrArray = [propertyAttrString componentsSeparatedByString:@","];
	NSString *typeAttrib = @"";
	for (NSString *attrib in propertyAttrArray)
	{
		if ([attrib hasPrefix:@"T"] && attrib.length > 1)
		{
			typeAttrib = attrib;
		}
		else if ([attrib hasPrefix:@"S"] && attrib.length > 7)
		{
			// S_rfjm_mapName:
			info.mapName = [attrib substringWithRange:NSMakeRange(7, attrib.length-8)];
		}
		else if ([attrib hasPrefix:@"V"] && attrib.length > 1)
		{
			// V_name
			info.var = [attrib substringWithRange:NSMakeRange(1, attrib.length-1)];
		}
	}
	
	if (![NSString isEmpty:info.mapName] && ![NSString isEmpty:typeAttrib])
	{
		if ([typeAttrib hasPrefix:@"Tb"] || [typeAttrib hasPrefix:@"TB"] || [typeAttrib hasPrefix:@"Tc"] || [typeAttrib hasPrefix:@"TC"])
		{
			info.type = RFJModelPropertyTypeBOOL;
		}
		else if ([typeAttrib hasPrefix:@"Ti"] || [typeAttrib hasPrefix:@"TI"])
		{
			info.type = RFJModelPropertyTypeInt32;
		}
		else if ([typeAttrib hasPrefix:@"Tl"] || [typeAttrib hasPrefix:@"TL"])
		{
			info.type = RFJModelPropertyTypeInt32;
		}
		else if ([typeAttrib hasPrefix:@"Tq"] || [typeAttrib hasPrefix:@"TQ"])
		{
			info.type = RFJModelPropertyTypeInt64;
		}
		else if ([typeAttrib hasPrefix:@"Ts"] || [typeAttrib hasPrefix:@"TS"])
		{
			info.type = RFJModelPropertyTypeInt16;
		}
		else if ([typeAttrib hasPrefix:@"Tf"] || [typeAttrib hasPrefix:@"TF"])
		{
			info.type = RFJModelPropertyTypeFloat;
		}
		else if ([typeAttrib hasPrefix:@"Td"] || [typeAttrib hasPrefix:@"TD"])
		{
			info.type = RFJModelPropertyTypeDouble;
		}
		else if ([typeAttrib hasPrefix:@"T@\"NSString\""])
		{
			info.type = RFJModelPropertyTypeString;
		}
		else if ([typeAttrib hasPrefix:@"T@\"NSMutableString\""])
		{
			info.type = RFJModelPropertyTypeMutableString;
		}
		else if ([typeAttrib hasPrefix:@"T@\"NSArray\""])
		{
			info.type = RFJModelPropertyTypeArray;
		}
		else if ([typeAttrib hasPrefix:@"T@\"NSMutableArray\""])
		{
			info.type = RFJModelPropertyTypeMutableArray;
		}
		else if ([typeAttrib hasPrefix:@"T@\"NSArray<"])
		{
			// T@"NSArray<ClassName>"
			const char *className = [[typeAttrib substringWithRange:NSMakeRange(11, typeAttrib.length-13)] cStringUsingEncoding:NSUTF8StringEncoding];
			Class cls = objc_getClass(className);
			if (cls != nil && [cls isSubclassOfClass:[RFJModel class]])
			{
				info.type = RFJModelPropertyTypeModelArray;
				info.modelClassName = className;
				info.modelClass = cls;
			}
		}
		else if ([typeAttrib hasPrefix:@"T@\"NSMutableArray<"])
		{
			// T@"NSMutableArray<ClassName>"
			const char *className = [[typeAttrib substringWithRange:NSMakeRange(18, typeAttrib.length-20)] cStringUsingEncoding:NSUTF8StringEncoding];
			Class cls = objc_getClass(className);
			if (cls != nil && [cls isSubclassOfClass:[RFJModel class]])
			{
				info.type = RFJModelPropertyTypeMutableModelArray;
				info.modelClassName = className;
				info.modelClass = cls;
			}
		}
		else if ([typeAttrib hasPrefix:@"T@\"NSDictionary\""])
		{
			info.type = RFJModelPropertyTypeDictionary;
		}
		else if ([typeAttrib hasPrefix:@"T@\"NSMutableDictionary\""])
		{
			info.type = RFJModelPropertyTypeMutableDictionary;
		}
		else if ([typeAttrib hasPrefix:@"T@"] && typeAttrib.length > 4)
		{
			const char *className = [[typeAttrib substringWithRange:NSMakeRange(3, typeAttrib.length-4)] cStringUsingEncoding:NSUTF8StringEncoding];
			Class cls = objc_getClass(className);
			if (cls != nil && [cls isSubclassOfClass:[RFJModel class]])
			{
				info.type = RFJModelPropertyTypeModel;
				info.modelClassName = className;
				info.modelClass = cls;
			}
		}
		
		if (info.type == RFJModelPropertyTypeNone)
		{
			NSException *e = [NSException exceptionWithName:@"Unsupport RFJModel Type"
													 reason:[NSString stringWithFormat:@"Unsupport RFJModel Type (%@, %@)", info.name, typeAttrib]
												   userInfo:nil];
			@throw e;
		}
		
		return info;
	}
	
	return nil;
}

@end

#pragma mark NSString (RFJModel)

@implementation NSString (RFJModel)

+ (BOOL)isEmpty:(NSString *)value
{
	if ((value == nil) || value == (NSString *)[NSNull null] || (value.length == 0))
	{
		return YES;
	}
	return NO;
}

+ (NSString *)ifNilToStr:(NSString *)value
{
	if ((value == nil) || (value == (NSString *)[NSNull null]))
	{
		return @"";
	}
	
	if ([value isKindOfClass:[NSNumber class]])
	{
		return  [(NSNumber *)value stringValue];
	}
	
	return value;
}

+ (NSString *)stringWithInteger:(NSInteger)value
{
	NSNumber *number = [NSNumber numberWithInteger:value];
	return [number stringValue];
}

+ (NSString *)stringWithLong:(long)value
{
	return [NSString stringWithFormat:@"%ld", value];
}

+ (NSString *)stringWithLongLong:(int64_t)value
{
	return [NSString stringWithFormat:@"%lld", value];
}

+ (NSString *)stringWithFloat:(float)value
{
	return [NSString stringWithFormat:@"%f", value];
}

+ (NSString *)stringWithDouble:(double)value
{
	return [NSString stringWithFormat:@"%lf", value];
}

@end
