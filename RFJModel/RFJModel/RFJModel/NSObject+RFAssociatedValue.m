//
//  NSObject+RFAssociatedValue.m
//  RFJModel
//
//  Created by GZH on 2017/7/4.
//  Copyright © 2017年 TechAtk. All rights reserved.
//

#import "NSObject+RFAssociatedValue.h"
#import <objc/runtime.h>

@interface RFAssociatedWeakObject : NSObject
@property (nonatomic, weak) id weakObject;
@end
@implementation RFAssociatedWeakObject
@end

@implementation NSObject (RFAssociatedValue)

- (void)rfj_setAssociatedValue:(nullable id)value forKey:(const void *)key access:(RFModelPropertyAccessType)access atomic:(BOOL)bAtomic
{
	objc_AssociationPolicy policy = OBJC_ASSOCIATION_ASSIGN;
	id inputValue = value;
	switch (access)
	{
		case RFModelPropertyAccessTypeAssign:
			policy = OBJC_ASSOCIATION_ASSIGN;
			break;
		case RFModelPropertyAccessTypeStrong:
			policy = bAtomic ? OBJC_ASSOCIATION_RETAIN : OBJC_ASSOCIATION_RETAIN_NONATOMIC;
			break;
		case RFModelPropertyAccessTypeWeak:
		{
			policy = bAtomic ? OBJC_ASSOCIATION_RETAIN : OBJC_ASSOCIATION_RETAIN_NONATOMIC;
			
			id obj = objc_getAssociatedObject(self, key);
			if (obj != nil && [obj isKindOfClass:[RFAssociatedWeakObject class]]) {
				RFAssociatedWeakObject *wo = obj;
				wo.weakObject = value;
				inputValue = wo;
			}
			else
			{
				RFAssociatedWeakObject *wo = [[RFAssociatedWeakObject alloc] init];
				wo.weakObject = value;
				inputValue = wo;
			}
		}
			break;
		case RFModelPropertyAccessTypeCopy:
			policy = bAtomic ? OBJC_ASSOCIATION_COPY : OBJC_ASSOCIATION_COPY_NONATOMIC;
			break;
		default:
			break;
	}
	objc_setAssociatedObject(self, key, inputValue, policy);
}

- (id)rfj_getAssociatedValueOfKey:(const void *)key
{
	id value = objc_getAssociatedObject(self, key);
	id outputValue = value;
	if (value != nil && [value isKindOfClass:[RFAssociatedWeakObject class]])
	{
		RFAssociatedWeakObject *wo = value;
		outputValue = wo.weakObject;
	}
	return outputValue;
}

@end
