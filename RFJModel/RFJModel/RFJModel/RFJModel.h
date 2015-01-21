//
//  RFJModel.h
//  RF
//
//  Created by gouzhehua on 14-12-5.
//  Copyright (c) 2014年 GZH. All rights reserved.
//

#import <Foundation/Foundation.h>

#define JProperty(Property, MapName)	\
	@property (nonatomic, setter=_rfjm_##MapName:) Property

#define IS_EMPTY_STR(value)	\
	[NSString isEmpty:value]

#define J2Str(value)	\
	[RFJModel toStringWithJsonValue:value]

#define J2Integer(value)	\
	[RFJModel toIntegerWithJsonValue:value]

#define J2Bool(value)	\
	[RFJModel toBoolWithJsonValue:value]

#define J2Int16(value)	\
	[RFJModel toInt16WithJsonValue:value]

#define J2Int32(value)	\
	[RFJModel toInt32WithJsonValue:value]

#define J2Int64(value)	\
	[RFJModel toInt64WithJsonValue:value]

#define J2Short(value)	\
	[RFJModel toShortWithJsonValue:value]

#define J2Float(value)	\
	[RFJModel toFloatWithJsonValue:value]

#define J2Double(value)	\
	[RFJModel toDoubleWithJsonValue:value]

#define J2Array(value)	\
	[RFJModel toArrayWithJsonValue:value]

#define J2Dict(value)	\
	[RFJModel toDictionaryWithJsonValue:value]

#define J2NumInteger(value)	\
	[NSNumber numberWithInteger:[RFJModel toIntegerWithJsonValue:value]]

#define J2NumBool(value)	\
	[NSNumber numberWithBool:[RFJModel toBoolWithJsonValue:value]]

#define J2NumInt16(value)	\
	[NSNumber numberWithShort:[RFJModel toInt16WithJsonValue:value]]

#define J2NumInt32(value)	\
	[NSNumber numberWithInt:[RFJModel toInt32WithJsonValue:value]]

#define J2NumInt64(value)	\
	[NSNumber numberWithLongLong:[RFJModel toInt64WithJsonValue:value]]

#define J2NumShort(value)	\
	[NSNumber numberWithShort:[RFJModel toShortWithJsonValue:value]]

#define J2NumFloat(value)	\
	[NSNumber numberWithFloat:[RFJModel toFloatWithJsonValue:value]]

#define J2NumDouble(value)	\
	[NSNumber numberWithDouble:[RFJModel toDoubleWithJsonValue:value]]

#define V2Str(value)	\
	[NSString ifNilToStr:(value)]

#define V2NumInteger(value)	\
	[NSNumber numberWithInteger:(value)]

#define V2NumBool(value)	\
	[NSNumber numberWithBool:(value)]

#define V2NumInt16(value)	\
	[NSNumber numberWithShort:(value)]

#define V2NumInt32(value)	\
	[NSNumber numberWithInt:(value)]

#define V2NumInt64(value)	\
	[NSNumber numberWithLongLong:(value)]

#define V2NumShort(value)	\
	[NSNumber numberWithShort:(value)]
	
#define V2NumDouble(value)	\
	[NSNumber numberWithDouble:(value)]

@interface RFJModel : NSObject
{
	
}

- (id)initWithJsonDict:(NSDictionary *)jsonDict;

- (void)fillWithJsonDict:(NSDictionary *)jsonDict;

+ (NSString *)toStringWithJsonValue:(id)value;
+ (NSInteger)toIntegerWithJsonValue:(id)value;
+ (BOOL)toBoolWithJsonValue:(id)value;
+ (int16_t)toInt16WithJsonValue:(id)value;
+ (int32_t)toInt32WithJsonValue:(id)value;
+ (int64_t)toInt64WithJsonValue:(id)value;
+ (short)toShortWithJsonValue:(id)value;
+ (float)toFloatWithJsonValue:(id)value;
+ (double)toDoubleWithJsonValue:(id)value;
+ (id)toArrayWithJsonValue:(id)value;
+ (id)toDictionaryWithJsonValue:(id)value;

+ (id)deepMutableCopyWithJson:(id)json;

@end

#pragma mark NSString (RFJModel)

@interface NSString (RFJModel)

+ (BOOL)isEmpty:(NSString *)value;
+ (NSString *)ifNilToStr:(NSString *)value;

+ (NSString *)stringWithInteger:(NSInteger)value;
+ (NSString *)stringWithLong:(long)value;
+ (NSString *)stringWithLongLong:(int64_t)value;
+ (NSString *)stringWithFloat:(float)value;
+ (NSString *)stringWithDouble:(double)value;

@end
