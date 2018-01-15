//
//  NSString+RFSafeTransform.m
//  RFJModel
//
//  Created by GZH on 2017/7/4.
//  Copyright © 2017年 TechAtk. All rights reserved.
//

#import "NSString+RFSafeTransform.h"

@implementation NSString (RFSafeTransform)

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
