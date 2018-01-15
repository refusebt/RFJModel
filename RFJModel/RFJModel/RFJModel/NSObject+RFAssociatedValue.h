//
//  NSObject+RFAssociatedValue.h
//  RFJModel
//
//  Created by GZH on 2017/7/4.
//  Copyright © 2017年 TechAtk. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, RFModelPropertyAccessType)
{
	RFModelPropertyAccessTypeAssign = 0,
	RFModelPropertyAccessTypeStrong,
	RFModelPropertyAccessTypeWeak,
	RFModelPropertyAccessTypeCopy,
};

@interface NSObject (RFAssociatedValue)
- (void)rfj_setAssociatedValue:(nullable id)value forKey:(const void *)key access:(RFModelPropertyAccessType)access atomic:(BOOL)bAtomic;
- (id)rfj_getAssociatedValueOfKey:(const void *)key;
@end

NS_ASSUME_NONNULL_END
