//
//  NSObject+RFSafeTransform.h
//  RFJModel
//
//  Created by GZH on 2017/7/4.
//  Copyright © 2017年 TechAtk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+RFSafeTransform.h"

NS_ASSUME_NONNULL_BEGIN

#define IS_EMPTY_STR(value)	\
	[NSString isEmpty:value]

#define J2Str(value)	\
	[NSObject rfj_toStringWithJsonValue:value]

#define J2Integer(value)	\
	[NSObject rfj_toIntegerWithJsonValue:value]

#define J2Bool(value)	\
	[NSObject rfj_toBoolWithJsonValue:value]

#define J2Char(value)	\
	[NSObject rfj_toCharWithJsonValue:value]

#define J2Int16(value)	\
	[NSObject rfj_toInt16WithJsonValue:value]

#define J2Int32(value)	\
	[NSObject rfj_toInt32WithJsonValue:value]

#define J2Int64(value)	\
	[NSObject rfj_toInt64WithJsonValue:value]

#define J2Short(value)	\
	[NSObject rfj_toShortWithJsonValue:value]

#define J2Float(value)	\
	[NSObject rfj_toFloatWithJsonValue:value]

#define J2Double(value)	\
	[NSObject rfj_toDoubleWithJsonValue:value]

#define J2Array(value)	\
	[NSObject rfj_toArrayWithJsonValue:value]

#define J2Dict(value)	\
	[NSObject rfj_toDictionaryWithJsonValue:value]

#define J2NumInteger(value)	\
	[NSNumber numberWithInteger:[NSObject rfj_toIntegerWithJsonValue:value]]

#define J2NumBool(value)	\
	[NSNumber numberWithBool:[NSObject rfj_toBoolWithJsonValue:value]]

#define J2NumChar(value)	\
	[NSNumber numberWithChar:[NSObject rfj_toCharWithJsonValue:value]]

#define J2NumInt16(value)	\
	[NSNumber numberWithShort:[NSObject rfj_toInt16WithJsonValue:value]]

#define J2NumInt32(value)	\
	[NSNumber numberWithInt:[NSObject rfj_toInt32WithJsonValue:value]]

#define J2NumInt64(value)	\
	[NSNumber numberWithLongLong:[NSObject rfj_toInt64WithJsonValue:value]]

#define J2NumShort(value)	\
	[NSNumber numberWithShort:[NSObject rfj_toShortWithJsonValue:value]]

#define J2NumFloat(value)	\
	[NSNumber numberWithFloat:[NSObject rfj_toFloatWithJsonValue:value]]

#define J2NumDouble(value)	\
	[NSNumber numberWithDouble:[NSObject rfj_toDoubleWithJsonValue:value]]

#define V2Str(value)	\
	[NSString ifNilToStr:(value)]

#define V2NumInteger(value)	\
	[NSNumber numberWithInteger:(value)]

#define V2NumBool(value)	\
	[NSNumber numberWithBool:(value)]

#define V2NumChar(value)	\
	[NSNumber numberWithChar:(value)]

#define V2NumInt16(value)	\
	[NSNumber numberWithShort:(value)]

#define V2NumInt32(value)	\
	[NSNumber numberWithInt:(value)]

#define V2NumInt64(value)	\
	[NSNumber numberWithLongLong:(value)]

#define V2NumShort(value)	\
	[NSNumber numberWithShort:(value)]

#define V2NumFloat(value)	\
	[NSNumber numberWithFloat:(value)]

#define V2NumDouble(value)	\
	[NSNumber numberWithDouble:(value)]

#define V2Obj(value, class)	\
	[NSObject rfj_toValue:value ofClass:class]

@interface NSObject (RFSafeTransform)

+ (NSString *)rfj_toStringWithJsonValue:(id)value;
+ (NSInteger)rfj_toIntegerWithJsonValue:(id)value;
+ (BOOL)rfj_toBoolWithJsonValue:(id)value;
+ (char)rfj_toCharWithJsonValue:(id)value;
+ (int16_t)rfj_toInt16WithJsonValue:(id)value;
+ (int32_t)rfj_toInt32WithJsonValue:(id)value;
+ (int64_t)rfj_toInt64WithJsonValue:(id)value;
+ (short)rfj_toShortWithJsonValue:(id)value;
+ (float)rfj_toFloatWithJsonValue:(id)value;
+ (double)rfj_toDoubleWithJsonValue:(id)value;
+ (id)rfj_toArrayWithJsonValue:(id)value;
+ (id)rfj_toDictionaryWithJsonValue:(id)value;
+ (id)rfj_toValue:(id)value ofClass:(Class)cls;

@end

NS_ASSUME_NONNULL_END
