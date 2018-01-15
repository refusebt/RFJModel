//
//  NSObject+RFJModelProperty.h
//  RFJModel
//
//  Created by GZH on 2017/7/4.
//  Copyright © 2017年 TechAtk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFJModelProperty.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (RFJModelProperty)

+ (void)rfj_analyseModelWithClass:(Class)cls rootModelClass:(Class)rootModelClass;

+ (BOOL)rfj_isRFJModel:(Class)cls;
- (NSString *)rfj_getClassName;
- (NSString *)rfj_getRootModelClassName;
- (BOOL)rfj_isRFJModel;
- (NSMutableDictionary *)rfj_getPropertyInfos;
- (NSMutableDictionary *)rfj_getSelector2PropertyInfos;

@end

NS_ASSUME_NONNULL_END
