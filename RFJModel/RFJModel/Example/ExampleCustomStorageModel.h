//
//  ExampleCustomStorageModel.h
//  RFJModel
//
//  Created by GZH on 2017/6/29.
//  Copyright © 2017年 TechAtk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFJModel.h"

@interface ExampleCustomStorageModel : RFJModel

JProperty(NSString *jpValue, jpValueJsonKey);
JProperty(NSString *jpStorageValue, jpStorageValueJsonKey);

@property (atomic, retain) NSString *normalValue;
@property (nonatomic, strong) NSString *normalStorageValue;
@property (nonatomic, weak) NSMutableString *weakStorageValue;
@property (nonatomic, assign) NSInteger assignIntValue;
@property (nonatomic, unsafe_unretained) double assignDoubleStorageValue;
@property (getter=customGetter, setter=customSetter:, assign) NSInteger getterSetterIntValue;
@property (getter=customGetter1, setter=customSetter1:) NSInteger getterSetterIntStorageValue;
@property (getter=customGetter2, setter=customSetter2:, copy) NSString *copyGetterSetterStringStorageValue;
JProperty(char jpStorageCharValue1, jpStorageCharValueJsonKey1);
JProperty(char jpStorageCharValue2, jpStorageCharValueJsonKey2);

@end
