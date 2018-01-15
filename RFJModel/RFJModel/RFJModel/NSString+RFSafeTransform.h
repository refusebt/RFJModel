//
//  NSString+RFSafeTransform.h
//  RFJModel
//
//  Created by GZH on 2017/7/4.
//  Copyright © 2017年 TechAtk. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (RFSafeTransform)

+ (BOOL)isEmpty:(NSString *)value;
+ (NSString *)ifNilToStr:(NSString *)value;

+ (NSString *)stringWithInteger:(NSInteger)value;
+ (NSString *)stringWithLong:(long)value;
+ (NSString *)stringWithLongLong:(int64_t)value;
+ (NSString *)stringWithFloat:(float)value;
+ (NSString *)stringWithDouble:(double)value;

@end

NS_ASSUME_NONNULL_END
