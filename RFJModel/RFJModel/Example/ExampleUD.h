//
//  ExampleUD.h
//  RFJModel
//
//  Created by GZH on 2017/8/30.
//  Copyright © 2017年 TechAtk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFJUserDefaults.h"

@interface ExampleUD : RFJUserDefaults

@property (nonatomic, strong) NSString *testString;
@property (nonatomic, assign) NSInteger testInt;

@end
