//
//  RFJUserDefaults.h
//  RFJModel
//
//  Created by GZH on 2017/7/7.
//  Copyright © 2017年 GZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+RFJModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RFJUserDefaults : NSObject <RFJModelStorageDelegate>

@property (nonatomic, strong) NSString *domain;
@property (nonatomic, strong) NSUserDefaults *userDefaults;

- (instancetype)initWithDomain:(NSString *)domain;

- (nullable id)rfj_objectForKey:(nonnull NSString *)key ofModel:(nonnull id)rfjModel;
- (void)rfj_setObject:(nullable id)value forKey:(nonnull NSString *)key ofModel:(nonnull id)rfjModel;
- (NSString *)rfj_transformKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
