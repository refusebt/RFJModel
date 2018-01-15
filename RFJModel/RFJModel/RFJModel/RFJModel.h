//
//  RFJModel.h
//  RFJModel
//
//  Created by gouzhehua on 14-12-5.
//  Copyright (c) 2014年 GZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+RFJModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RFJModel : NSObject <NSCoding>
{
	
}

- (id)initWithJsonDict:(NSDictionary *)jsonDict;

@end

NS_ASSUME_NONNULL_END
