//
//  RFJUserDefaults.m
//  RFJModel
//
//  Created by GZH on 2017/7/7.
//  Copyright © 2017年 GZH. All rights reserved.
//

#import "RFJUserDefaults.h"

@implementation RFJUserDefaults

+ (void)initialize
{
	[NSObject rfj_initializeModelWithClass:[self class] rootModelClass:[RFJUserDefaults class]];
}

- (instancetype)initWithDomain:(NSString *)domain
{
	self = [super init];
	if (self)
	{
		self.rfj_storageDelegate = self;
		_domain = domain;
		if (IS_EMPTY_STR(domain))
			_userDefaults = [NSUserDefaults standardUserDefaults];
		else
			_userDefaults = [[NSUserDefaults alloc] initWithSuiteName:domain];
	}
	return self;
}

- (nullable id)rfj_objectForKey:(nonnull NSString *)key ofModel:(nonnull id)rfjModel
{
	return [self.userDefaults objectForKey:key];
}

- (void)rfj_setObject:(nullable id)value forKey:(nonnull NSString *)key ofModel:(nonnull id)rfjMode
{
	[self.userDefaults setObject:value forKey:key];
}

- (NSString *)rfj_transformKey:(NSString *)key
{
	return key;
}

@end
