//
//  NSObject+RFJModel.m
//  RFJModel
//
//  Created by GZH on 2017/7/4.
//  Copyright © 2017年 TechAtk. All rights reserved.
//

#import "NSObject+RFJModel.h"

@interface NSObject (RFJModelInner)
+ (NSMutableDictionary *)rfj_swizzledRootModels;
@end

static NSRecursiveLock *s_RFJModelTransformKeyLock = nil;
static NSRecursiveLock *s_RFJModelSwizzledRootModelLock = nil;

@implementation NSObject (RFJModel)
@dynamic rfj_storageDelegate;

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		s_RFJModelTransformKeyLock = [[NSRecursiveLock alloc] init];
		s_RFJModelTransformKeyLock.name = @"RFJModelTransformKeyLock";
		s_RFJModelSwizzledRootModelLock = [[NSRecursiveLock alloc] init];
		s_RFJModelSwizzledRootModelLock.name = @"RFJModelSwizzledRootModelLock";
	});
}

+ (void)rfj_initializeModelWithClass:(Class)cls rootModelClass:(Class)rootModelClass
{
	[s_RFJModelSwizzledRootModelLock lock];
	{
		NSString *className = NSStringFromClass(rootModelClass);
		if ([[NSObject rfj_swizzledRootModels] objectForKey:className] == nil)
		{
			[NSObject rfj_swizzledNSObjectKeyValueMethodWithRootModelClass:rootModelClass];
			[[NSObject rfj_swizzledRootModels] setObject:className forKey:className];
		}
	}
	[s_RFJModelSwizzledRootModelLock unlock];
	
	if (cls != rootModelClass)
	{
		[NSObject rfj_analyseModelWithClass:cls rootModelClass:rootModelClass];
	}
}

- (void)rfj_fillWithJsonDict:(NSDictionary *)jsonDict usePropertyKey:(BOOL)bUsePropertyKey
{
	NSDictionary *mapPropertyInfos = [self rfj_getPropertyInfos];
	
	for (NSString *key in mapPropertyInfos)
	{
		RFJModelPropertyInfo *info = mapPropertyInfos[key];
		if (info != nil)
		{
			if (!bUsePropertyKey && !info.isJsonProperty)
				continue;
			
			NSString *jsonKey = bUsePropertyKey ? info.name : info.mapName;
			if (IS_EMPTY_STR(jsonKey))
				continue;
			id jsonValue = jsonDict[jsonKey];
			if (jsonValue == nil)
				continue;
			
			switch (info.type)
			{
				case RFJModelPropertyTypeBOOL:
					[self setValue:J2NumBool(jsonValue) forKey:info.name];
					break;
				case RFJModelPropertyTypeChar:
					[self setValue:J2NumChar(jsonValue) forKey:info.name];
					break;
				case RFJModelPropertyTypeInt16:
					[self setValue:J2NumInt16(jsonValue) forKey:info.name];
					break;
				case RFJModelPropertyTypeInt32:
					[self setValue:J2NumInt32(jsonValue) forKey:info.name];
					break;
				case RFJModelPropertyTypeInt64:
					[self setValue:J2NumInt64(jsonValue) forKey:info.name];
					break;
				case RFJModelPropertyTypeFloat:
					[self setValue:J2NumFloat(jsonValue) forKey:info.name];
					break;
				case RFJModelPropertyTypeDouble:
					[self setValue:J2NumDouble(jsonValue) forKey:info.name];
					break;
				case RFJModelPropertyTypeString:
					{
						NSString *value = J2Str(jsonValue);
						[self setValue:value forKey:info.name];
					}
					break;
				case RFJModelPropertyTypeMutableString:
					{
						NSString *value = J2Str(jsonValue);
						if (value != nil)
							[self setValue:[NSObject rfj_deepMutableCopyWithJson:value] forKey:info.name];
						else
							[self setValue:nil forKey:info.name];
					}
					break;
				case RFJModelPropertyTypeArray:
					{
						NSArray *value = J2Array(jsonValue);
						[self setValue:value forKey:info.name];
					}
					break;
				case RFJModelPropertyTypeMutableArray:
					{
						NSArray *value = J2Array(jsonValue);
						if (value != nil)
							[self setValue:[NSObject rfj_deepMutableCopyWithJson:value] forKey:info.name];
						else
							[self setValue:nil forKey:info.name];
					}
					break;
				case RFJModelPropertyTypeModelArray:
				case RFJModelPropertyTypeMutableModelArray:
					{
						NSArray *array = J2Array(jsonValue);
						if (array != nil)
						{
							NSMutableArray *models = [NSMutableArray array];
							for (NSInteger i = 0; i < array.count; i++)
							{
								NSDictionary *dict = J2Dict(array[i]);
								if (dict != nil)
								{
									id model = [[info.modelClass alloc] init];
									[model rfj_fillWithJsonDict:dict usePropertyKey:bUsePropertyKey];
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
						NSDictionary *value = J2Dict(jsonValue);
						[self setValue:value forKey:info.name];
					}
					break;
				case RFJModelPropertyTypeMutableDictionary:
					{
						NSDictionary *value = J2Dict(jsonValue);
						if (value != nil)
							[self setValue:[NSObject rfj_deepMutableCopyWithJson:value] forKey:info.name];
						else
							[self setValue:nil forKey:info.name];
					}
					break;
				case RFJModelPropertyTypeModel:
					{
						NSDictionary *dict = J2Dict(jsonValue);
						if (dict != nil)
						{
							id model = [[info.modelClass alloc] init];
							[model rfj_fillWithJsonDict:dict usePropertyKey:bUsePropertyKey];
							[self setValue:model forKey:info.name];
						}
						else
							[self setValue:nil forKey:info.name];
					}
					break;
				case RFJModelPropertyTypeObject:
					{
						// 不安全的
						[self setValue:jsonValue forKey:info.name];
					}
					break;
				default:
					break;
			}
		}
	}
}

+ (id)rfj_deepMutableCopyWithJson:(id)json
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
			[array addObject:[NSObject rfj_deepMutableCopyWithJson:value]];
		}
		return array;
	}
	
	if ([json isKindOfClass:[NSDictionary class]])
	{
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		for (NSString *key in json)
		{
			id value = [NSObject rfj_deepMutableCopyWithJson:json[key]];
			[dict setObject:value forKey:key];
		}
		return dict;
	}
	
	return json;
}

- (NSMutableDictionary *)rfj_toMutableDictionaryUsePropertyKey:(BOOL)bUsePropertyKey
{
	NSMutableDictionary *container = [NSMutableDictionary dictionary];
	NSDictionary *mapPropertyInfos = [self rfj_getPropertyInfos];
	
	for (NSString *key in mapPropertyInfos)
	{
		RFJModelPropertyInfo *info = mapPropertyInfos[key];
		if (!bUsePropertyKey && !info.isJsonProperty)
			continue;
		
		NSString *jsonKey = bUsePropertyKey ? info.name : info.mapName;
		if (IS_EMPTY_STR(jsonKey))
			continue;
		
		id jsonValue = [self valueForKey:info.name];
		if (jsonValue != nil)
		{
			switch (info.type)
			{
				case RFJModelPropertyTypeBOOL:
				case RFJModelPropertyTypeChar:
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
						[container setObject:jsonValue forKey:jsonKey];
					}
					break;
				case RFJModelPropertyTypeModelArray:
				case RFJModelPropertyTypeMutableModelArray:
					{
						NSMutableArray *newArray = [NSMutableArray array];
						NSArray *array = jsonValue;
						for (NSInteger i = 0; i < array.count; i++)
						{
							id arrayValue = array[i];
							if ([arrayValue rfj_isRFJModel])
							{
								NSMutableDictionary *dict = [arrayValue rfj_toMutableDictionaryUsePropertyKey:bUsePropertyKey];
								if (dict != nil)
								{
									[newArray addObject:dict];
								}
							}
						}
						[container setObject:newArray forKey:jsonKey];
					}
					break;
				case RFJModelPropertyTypeModel:
					{
						if ([jsonValue rfj_isRFJModel])
						{
							NSMutableDictionary *dict = [jsonValue rfj_toMutableDictionaryUsePropertyKey:bUsePropertyKey];
							if (dict != nil)
							{
								[container setObject:dict forKey:jsonKey];
							}
						}
					}
					break;
				case RFJModelPropertyTypeObject:
					{
						// 不安全的
						[container setObject:jsonValue forKey:jsonKey];
					}
					break;
				default:
					break;
			}
		}
	}
	
	return container;
}

- (NSString *)rfj_toJsonStringUsePropertyKey:(BOOL)bUsePropertyKey
{
	NSMutableDictionary *dict = [self rfj_toMutableDictionaryUsePropertyKey:bUsePropertyKey];
	NSData *buffer = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
	return [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding];
}

+ (NSUInteger)rfj_modelVersion
{
	return 2;
}

+ (NSString *)rfj_modelVersionSerializeKey
{
	return @"rfj_modelVersionSerializeKey";
}

- (void)rfj_decodeCoder:(NSCoder *)coder
{
	if ([coder isKindOfClass:[NSKeyedUnarchiver class]])
	{
		NSDictionary *mapPropertyInfos = [self rfj_getPropertyInfos];
		for (NSString *key in mapPropertyInfos)
		{
			RFJModelPropertyInfo *info = mapPropertyInfos[key];
			id value = [coder decodeObjectForKey:info.name];
			if (value != nil)
			{
				[self setValue:value forKey:info.name];
			}
		}
	}
}

- (void)rfj_encodeCoder:(NSCoder *)coder
{
	NSDictionary *mapPropertyInfos = [self rfj_getPropertyInfos];
	for (NSString *key in mapPropertyInfos)
	{
		RFJModelPropertyInfo *info = mapPropertyInfos[key];
		id value = [self valueForKey:info.name];
		if (value != nil && [value conformsToProtocol:@protocol(NSCoding)])
		{
			[coder encodeObject:value forKey:info.name];
		}
	}
	
	[coder encodeObject:[NSNumber numberWithUnsignedInteger:[NSObject rfj_modelVersion]]
				 forKey:[NSObject rfj_modelVersionSerializeKey]];
}

+ (NSData *)rfj_toDataWithModel:(id)rfjModel
{
	if (rfjModel != nil && [rfjModel conformsToProtocol:@protocol(NSCoding)])
	{
		@autoreleasepool
		{
			NSMutableData* saveData = [[NSMutableData alloc] init];
			NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:saveData];
			[archiver encodeRootObject:rfjModel];
			[archiver finishEncoding];
			return saveData;
		}
	}
	return nil;
}

+ (id)rfj_toModelWithData:(NSData *)data class:(Class)cls
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

- (void)rfj_descriptionWithBuffer:(NSMutableString *)buffer indent:(NSInteger)indent
{
	NSMutableString *indentString = [NSMutableString string];
	for (NSInteger i = 0; i < indent; i++)
	{
		[indentString appendString:@"\t"];
	}
	NSString *replaceString = [NSString stringWithFormat:@"\n%@", indentString];
	
	NSDictionary *mapPropertyInfos = [self rfj_getPropertyInfos];;
	NSArray *values = [mapPropertyInfos allValues];
	values = [values sortedArrayUsingComparator:^(RFJModelPropertyInfo *info1, RFJModelPropertyInfo *info2){
		if (info1.propertyIdx < info2.propertyIdx)
		{
			return NSOrderedAscending;
		}
		else if (info1.propertyIdx == info2.propertyIdx)
		{
			return NSOrderedSame;
		}
		else
		{
			return NSOrderedDescending;
		}
	}];
	
	for (RFJModelPropertyInfo *info in values)
	{
		if (info.isJsonProperty)
		{
			// JProperty
			id value = [self valueForKey:info.name];
			switch (info.type)
			{
				case RFJModelPropertyTypeModel:
					{
						[buffer appendFormat:@"\n%@JP name:%@ type:%s map:%@ value:", indentString, info.name, s_RFJModelPropertyTypeName[info.type], info.mapName];
						if ([value rfj_isRFJModel])
						{
							[value rfj_descriptionWithBuffer:buffer indent:indent+1];
						}
					}
					break;
				case RFJModelPropertyTypeModelArray:
				case RFJModelPropertyTypeMutableModelArray:
					{
						[buffer appendFormat:@"\n%@JP name:%@ type:%s map:%@ value:", indentString, info.name, s_RFJModelPropertyTypeName[info.type], info.mapName];
						NSArray *models = value;
						for (NSInteger i = 0; i < models.count; i++)
						{
							id model = models[i];
							[buffer appendFormat:@"\n\t%@-", indentString];
							if ([model rfj_isRFJModel])
							{
								[model rfj_descriptionWithBuffer:buffer indent:indent+1];
							}
						}
					}
					break;
				default:
					{
						NSString *valueString = [value description];
						valueString = [valueString stringByReplacingOccurrencesOfString:@"\n" withString:replaceString];
						[buffer appendFormat:@"\n%@JP name:%@ type:%s map:%@ value:%@", indentString, info.name, s_RFJModelPropertyTypeName[info.type], info.mapName, valueString];
					}
					break;
			}
		}
		else
		{
			// no JProperty
			id value = [self valueForKey:info.name];
			NSString *valueString = [value description];
			valueString = [valueString stringByReplacingOccurrencesOfString:@"\n" withString:replaceString];
			[buffer appendFormat:@"\n%@ P name:%@ value:%@", indentString, info.name, valueString];
		}
	}
}

#pragma mark - 自定义存储区

+ (NSMutableDictionary *)rfj_swizzledRootModels
{
	static NSMutableDictionary *s_instance = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		s_instance = [[NSMutableDictionary alloc] init];
	});
	
	return s_instance;
}

+ (void)rfj_swizzledNSObjectKeyValueMethodWithRootModelClass:(Class)rootModelClass
{
	Class class = rootModelClass;
	{
		SEL originalSelector = @selector(valueForKey:);
		SEL swizzledSelector = @selector(rfj_valueForKey:);
		
		Method originalMethod = class_getInstanceMethod(class, originalSelector);
		Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
		
		BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
		if (success)
		{
			class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
		}
		else
		{
			method_exchangeImplementations(originalMethod, swizzledMethod);
		}
	}
	{
		SEL originalSelector = @selector(setValue:forKey:);
		SEL swizzledSelector = @selector(rfj_setValue:forKey:);
		
		Method originalMethod = class_getInstanceMethod(class, originalSelector);
		Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
		
		BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
		if (success)
		{
			class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
		}
		else
		{
			method_exchangeImplementations(originalMethod, swizzledMethod);
		}
	}
}

static void *kRFJModelStorageDelegate = "kRFJModelStorageDelegate";

- (void)setRfj_storageDelegate:(id<RFJModelStorageDelegate>)delegate
{
	[self rfj_setAssociatedValue:delegate forKey:kRFJModelStorageDelegate access:RFModelPropertyAccessTypeWeak atomic:NO];
}

- (id<RFJModelStorageDelegate>)rfj_storageDelegate
{
	return [self rfj_getAssociatedValueOfKey:kRFJModelStorageDelegate];
}

- (NSString *)_rfj_transformKey:(NSString *)key
{
	NSMutableDictionary *dict = [self rfj_cachedTransformKeys];
	NSString *newKey = dict[key];
	if (IS_EMPTY_STR(newKey))
	{
		if (self.rfj_storageDelegate != nil
			&& [self.rfj_storageDelegate respondsToSelector:@selector(rfj_transformKey:)])
			newKey = [self.rfj_storageDelegate rfj_transformKey:key];
		else
			newKey = key;
		[s_RFJModelTransformKeyLock lock];
		{
			dict[key] = newKey;
		}
		[s_RFJModelTransformKeyLock unlock];
	}
	return newKey;
}

- (NSMutableDictionary *)rfj_cachedTransformKeys
{
	static NSMutableDictionary *s_allDict = nil;
	NSMutableDictionary *dict = nil;
	
	[s_RFJModelTransformKeyLock lock];
	{
		if (s_allDict == nil) {
			s_allDict = [[NSMutableDictionary alloc] init];
		}
		dict = s_allDict[[self rfj_getClassName]];
		if (dict == nil) {
			dict = [[NSMutableDictionary alloc] init];
			s_allDict[[self rfj_getClassName]] = dict;
		}
	}
	[s_RFJModelTransformKeyLock unlock];
	
	return dict;
}

- (nullable id)rfj_valueForKey:(NSString *)key
{
	NSDictionary *mapPropertyInfos = [self rfj_getPropertyInfos];
	
	// 动态属性存取
	RFJModelPropertyInfo *info = mapPropertyInfos[key];
	if (info != nil && info.isDynamic) {
		// 优先自定义存取
		if (self.rfj_storageDelegate != nil) {
			return [self.rfj_storageDelegate rfj_objectForKey:[self _rfj_transformKey:key] ofModel:self];
		}
		// 关联对象存取
		return [self rfj_getAssociatedValueOfKey:info.chName];
	}
	
	// 静态属性存取
	return [self rfj_valueForKey:key];
}

- (void)rfj_setValue:(nullable id)value forKey:(NSString *)key
{
	NSDictionary *mapPropertyInfos = [self rfj_getPropertyInfos];
	
	// 动态属性存取
	RFJModelPropertyInfo *info = mapPropertyInfos[key];
	if (info != nil && info.isDynamic) {
		// 优先自定义存取
		if (self.rfj_storageDelegate != nil) {
			[self.rfj_storageDelegate rfj_setObject:value forKey:[self _rfj_transformKey:key] ofModel:self];
			return;
		}
		// 关联对象存取
		[self willChangeValueForKey:key];
		[self rfj_setAssociatedValue:value forKey:info.chName access:info.accessType atomic:!info.isNonatomic];
		[self didChangeValueForKey:key];
		return;
	}
	
	// 静态属性存取
	[self rfj_setValue:value forKey:key];
}


@end
