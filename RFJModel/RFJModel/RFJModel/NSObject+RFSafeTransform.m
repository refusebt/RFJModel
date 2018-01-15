//
//  NSObject+RFSafeTransform.m
//  RFJModel
//
//  Created by GZH on 2017/7/4.
//  Copyright © 2017年 TechAtk. All rights reserved.
//

#import "NSObject+RFSafeTransform.h"

@implementation NSObject (RFSafeTransform)

+ (NSString *)rfj_toStringWithJsonValue:(id)value
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

+ (NSInteger)rfj_toIntegerWithJsonValue:(id)value
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

+ (BOOL)rfj_toBoolWithJsonValue:(id)value
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

+ (char)rfj_toCharWithJsonValue:(id)value
{
	if (value == nil || value == [NSNull null])
	{
		return NO;
	}
	
	if ([value isKindOfClass:[NSNumber class]])
	{
		return [value charValue];
	}
	
	if ([value isKindOfClass:[NSString class]])
	{
		return (char)[value intValue];
	}
	
	return 0;
}

+ (int16_t)rfj_toInt16WithJsonValue:(id)value
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

+ (int32_t)rfj_toInt32WithJsonValue:(id)value
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

+ (int64_t)rfj_toInt64WithJsonValue:(id)value
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

+ (short)rfj_toShortWithJsonValue:(id)value
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

+ (float)rfj_toFloatWithJsonValue:(id)value
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

+ (double)rfj_toDoubleWithJsonValue:(id)value
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

+ (id)rfj_toArrayWithJsonValue:(id)value
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

+ (id)rfj_toDictionaryWithJsonValue:(id)value
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

+ (id)rfj_toValue:(id)value ofClass:(Class)cls
{
	if ([value isKindOfClass:cls])
	{
		return value;
	}
	return nil;
}

@end
