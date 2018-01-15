//
//  RFJModelProperty.h
//  RFJModel
//
//  Created by GZH on 2017/7/4.
//  Copyright © 2017年 TechAtk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "NSObject+RFAssociatedValue.h"

NS_ASSUME_NONNULL_BEGIN

#define JProperty(Property, MapName)	\
	@property (nonatomic, setter=_rfjm_##MapName:) Property

typedef NS_ENUM(NSUInteger, RFJModelPropertyType)
{
	RFJModelPropertyTypeNone = 0,
	RFJModelPropertyTypeBOOL,
	RFJModelPropertyTypeChar,
	RFJModelPropertyTypeInt16,
	RFJModelPropertyTypeInt32,
	RFJModelPropertyTypeInt64,
	RFJModelPropertyTypeFloat,
	RFJModelPropertyTypeDouble,
	RFJModelPropertyTypeString,
	RFJModelPropertyTypeMutableString,
	RFJModelPropertyTypeArray,
	RFJModelPropertyTypeMutableArray,
	RFJModelPropertyTypeModelArray,
	RFJModelPropertyTypeMutableModelArray,
	RFJModelPropertyTypeDictionary,
	RFJModelPropertyTypeMutableDictionary,
	RFJModelPropertyTypeModel,
	RFJModelPropertyTypeObject,
};

static char * _Nonnull s_RFJModelPropertyTypeName[] =
{
	"RFJModelPropertyTypeNone",
	"RFJModelPropertyTypeBOOL",
	"RFJModelPropertyTypeChar",
	"RFJModelPropertyTypeInt16",
	"RFJModelPropertyTypeInt32",
	"RFJModelPropertyTypeInt64",
	"RFJModelPropertyTypeFloat",
	"RFJModelPropertyTypeDouble",
	"RFJModelPropertyTypeString",
	"RFJModelPropertyTypeMutableString",
	"RFJModelPropertyTypeArray",
	"RFJModelPropertyTypeMutableArray",
	"RFJModelPropertyTypeModelArray",
	"RFJModelPropertyTypeMutableModelArray",
	"RFJModelPropertyTypeDictionary",
	"RFJModelPropertyTypeMutableDictionary",
	"RFJModelPropertyTypeModel",
	"RFJModelPropertyTypeObject",
};

@interface RFJModelPropertyInfo : NSObject

@property (nonatomic, assign) NSInteger propertyIdx;
@property (nonatomic, assign) const char * chName;
@property (nonatomic, assign) BOOL isJsonProperty;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *mapName;
@property (nonatomic, strong) NSString *var;
@property (nonatomic, assign) RFJModelPropertyType type;
@property (nonatomic, strong) NSString *typePropertyAttrib;
@property (nonatomic, assign) const char *modelClassName;
@property (nonatomic, weak) Class modelClass;
@property (nonatomic, assign) BOOL isDynamic;
@property (nonatomic, assign) SEL getterSelector;
@property (nonatomic, strong) NSString *getterSelectorName;
@property (nonatomic, assign) SEL setterSelector;
@property (nonatomic, strong) NSString *setterSelectorName;
@property (nonatomic, assign) BOOL isNonatomic;
@property (nonatomic, assign) RFModelPropertyAccessType accessType;

+ (RFJModelPropertyInfo *)propertyInfoWithProperty:(objc_property_t _Nonnull *_Nonnull)property rootModelClass:(Class)rootModelClass;

@end

NS_ASSUME_NONNULL_END
