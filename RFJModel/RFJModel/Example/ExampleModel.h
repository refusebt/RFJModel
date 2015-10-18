//
//  ExampleModel1.h
//  RFJModel
//
//  Created by gouzhehua on 14-12-10.
//  Copyright (c) 2014年 TechAtk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RFJModel.h"

@class ExampleModelTestType;
@class ExampleModelTestJson;
@class ExampleModelTestChild;
@class ExampleModelTestSub;
@class GrandsonModel;

@protocol ExampleModelTestSub
@end

@interface ExampleModelTestType : RFJModel
JProperty(NSInteger value_NSInteger, map_value_NSInteger);
JProperty(NSUInteger value_NSUInteger, map_value_NSUInteger);
JProperty(short value_short, map_value_short);
JProperty(unsigned short value_ushort, map_value_ushort);
JProperty(int value_int, map_value_int);
JProperty(unsigned int value_uint, map_value_uint);
JProperty(long value_long, map_value_long);
JProperty(unsigned long value_long_u, map_value_long_u);
JProperty(long long value_long_long, map_value_long_long);
JProperty(unsigned long long value_long_long_u, map_value_long_long_u);
JProperty(int32_t value_int32, map_value_int32);
JProperty(uint32_t value_uint32, map_value_uint32);
JProperty(int16_t value_int16, map_value_int16);
JProperty(uint16_t value_uint16, map_value_uint16);
JProperty(int64_t value_int64, map_value_int64);
JProperty(uint64_t value_uint64, map_value_uint64);
JProperty(NSString *value_NSString, map_value_NSString);
JProperty(NSArray *value_NSArray, map_value_NSArray);
JProperty(NSDictionary *value_NSDictionary, map_value_NSDictionary);
JProperty(BOOL value_Bool, map_value_Bool);
JProperty(ExampleModelTestType *value_Model, map_model);
JProperty(NSArray<ExampleModelTestSub> *value_models, map_models);
@end

@interface ExampleModelTestJson : RFJModel
JProperty(NSString *name, name);
JProperty(short sex, sex);
JProperty(int age, age);
JProperty(NSString *address, address);
JProperty(int64_t uid, uid);
JProperty(NSInteger unset, unset);
JProperty(NSArray *list, list);
JProperty(NSDictionary *dict, dict);
JProperty(ExampleModelTestSub *subModel, model);
JProperty(NSArray<ExampleModelTestSub> *subModels, models);
JProperty(NSMutableString *mstr, mstr);
JProperty(NSMutableArray *mArray, mArray);
JProperty(NSMutableDictionary *mDict, mDict);
JProperty(NSMutableArray<ExampleModelTestSub> *mModelArray, mModelArray);
JProperty(NSString *errString, errString);
JProperty(NSArray *errArray, errArray);
JProperty(NSDictionary *errDict, errDict);
JProperty(NSArray<ExampleModelTestSub> *errModelArray, errModelArray);
JProperty(ExampleModelTestSub *errModel, errModel);
@end

@interface ExampleModelTestChild : ExampleModelTestJson
JProperty(NSString *unuse, unuse);
JProperty(BOOL bYes, bYes);
JProperty(BOOL bTrue, bTrue);
JProperty(BOOL bTrue2, bTrue2);
JProperty(BOOL b0, b0);
JProperty(BOOL b1, b1);
JProperty(BOOL bNo, bNo);
JProperty(BOOL bFalse, bFalse);
@property (nonatomic, strong) UIImage *picImg;
@property (nonatomic, assign) int64_t tag;
@end

@interface ExampleModelTestSub : RFJModel
JProperty(NSString *name, name);
JProperty(NSInteger size, size);
JProperty(GrandsonModel *gm, GrandsonModel);
@end

@interface GrandsonModel : RFJModel
JProperty(NSString *name, name);
@property (nonatomic, assign) int64_t tag;
@end

@protocol ExampleProtocol <NSObject>

@end

@interface ExampleProtocolModel : RFJModel <ExampleProtocol>
@property (nonatomic, strong) NSString *name;
@end
