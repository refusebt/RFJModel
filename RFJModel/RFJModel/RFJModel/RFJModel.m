//
//  RFJModel.m
//  RFJModel
//
//  Created by gouzhehua on 14-12-5.
//  Copyright (c) 2014年 GZH. All rights reserved.
//

#import "RFJModel.h"

@interface RFJModel ()

@end

@implementation RFJModel

+ (void)initialize
{
	[NSObject rfj_initializeModelWithClass:[self class] rootModelClass:[RFJModel class]];
}

- (id)init
{
	self = [super init];
	if (self)
	{
		
	}
	return self;
}

- (id)initWithJsonDict:(NSDictionary *)jsonDict
{
	self = [self init];
	if (self)
	{
		[self rfj_fillWithJsonDict:jsonDict usePropertyKey:NO];
	}
	return self;
}

- (NSString *)description
{
	NSMutableString *buffer = [NSMutableString string];
	[self rfj_descriptionWithBuffer:buffer indent:0];
	return buffer;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (self)
	{
		[self rfj_decodeCoder:aDecoder];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[self rfj_encodeCoder:aCoder];
}

@end
