//
//  RFJModelProperty.m
//  RFJModel
//
//  Created by GZH on 2017/7/4.
//  Copyright © 2017年 TechAtk. All rights reserved.
//

#import "RFJModelProperty.h"
#import "NSObject+RFSafeTransform.h"

@interface RFJModelPropertyInfo ()

+ (NSMutableDictionary *)mapNSObjectProperties;
- (void)setTypeAttrib:(NSString *)typeAttrib rootModelClass:(Class)rootModelClass;

@end

@implementation RFJModelPropertyInfo

+ (NSMutableDictionary *)mapNSObjectProperties
{
	static NSMutableDictionary *s_map = nil;
	if (s_map == nil)
	{
		s_map = [NSMutableDictionary dictionary];
		Protocol *protocol = objc_getProtocol("NSObject");
		unsigned count = 0;
		objc_property_t *properties = protocol_copyPropertyList(protocol, &count);
		for (unsigned i = 0; i < count; i++)
		{
			objc_property_t property = properties[i];
			NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
			[s_map setObject:propertyName forKey:propertyName];
		}
		free(properties);
		
		// IOS7及以前应对
		if (s_map.count == 0)
		{
			[s_map setObject:@"hash" forKey:@"hash"];
			[s_map setObject:@"superclass" forKey:@"superclass"];
			[s_map setObject:@"description" forKey:@"description"];
			[s_map setObject:@"debugDescription" forKey:@"debugDescription"];
		}
	}
	return s_map;
}

+ (RFJModelPropertyInfo *)propertyInfoWithProperty:(objc_property_t _Nonnull *_Nonnull)property rootModelClass:(Class)rootModelClass
{
	RFJModelPropertyInfo *info = [[RFJModelPropertyInfo alloc] init];
	info.chName = property_getName(*property);
	info.name = [NSString stringWithUTF8String:info.chName];
	info.accessType = RFModelPropertyAccessTypeAssign;
	
	// 系统协议属性跳过
	NSMutableDictionary *mapNSObjectProperties = [RFJModelPropertyInfo mapNSObjectProperties];
	if ([mapNSObjectProperties objectForKey:info.name] != nil)
		return nil;
	
	NSString *propertyAttrString = [NSString stringWithUTF8String:property_getAttributes(*property)];
	NSArray *propertyAttrArray = [propertyAttrString componentsSeparatedByString:@","];
	for (NSString *attrib in propertyAttrArray)
	{
		if ([attrib hasPrefix:@"T"] && attrib.length > 1)
		{
			[info setTypeAttrib:attrib rootModelClass:rootModelClass];
			if (info.isJsonProperty && info.type == RFJModelPropertyTypeNone)
			{
				NSException *e = [NSException exceptionWithName:@"Unsupport RFJModel Type"
														 reason:[NSString stringWithFormat:@"Unsupport RFJModel Type (%@, %@)", info.name, attrib]
													   userInfo:nil];
				@throw e;
			}
		}
		else if ([attrib hasPrefix:@"S"] && attrib.length > 1)
		{
			info.setterSelectorName = [attrib substringFromIndex:1];
			SEL sel = NSSelectorFromString(info.setterSelectorName);
			info.setterSelector = sel;
			if ([attrib hasPrefix:@"S_rfjm_"])
			{
				// S_rfjm_mapName:
				info.mapName = [attrib substringWithRange:NSMakeRange(7, attrib.length-8)];
				info.isJsonProperty = YES;
			}
		}
		else if ([attrib hasPrefix:@"G"] && attrib.length > 1)
		{
			info.getterSelectorName = [attrib substringFromIndex:1];
			SEL sel = NSSelectorFromString(info.getterSelectorName);
			info.getterSelector = sel;
		}
		else if ([attrib hasPrefix:@"V"] && attrib.length > 1)
		{
			// V_name
			info.var = [attrib substringWithRange:NSMakeRange(1, attrib.length-1)];
		}
		else if ([attrib isEqualToString:@"D"])
		{
			info.isDynamic = YES;
		}
		else if ([attrib isEqualToString:@"N"])
		{
			info.isNonatomic = YES;
		}
		else if ([attrib isEqualToString:@"&"])
		{
			info.accessType = RFModelPropertyAccessTypeStrong;
		}
		else if ([attrib isEqualToString:@"W"])
		{
			info.accessType = RFModelPropertyAccessTypeWeak;
		}
		else if ([attrib isEqualToString:@"C"])
		{
			info.accessType = RFModelPropertyAccessTypeCopy;
		}
	}
	
	// 补充属性未声明存取SEL定义
	if (IS_EMPTY_STR(info.getterSelectorName))
	{
		info.getterSelectorName = info.name;
		SEL sel = NSSelectorFromString(info.getterSelectorName);
		info.getterSelector = sel;
	}
	if (IS_EMPTY_STR(info.setterSelectorName))
	{
		info.setterSelectorName = [NSString stringWithFormat:@"set%@%@:",
								   [[info.name substringToIndex:1] uppercaseString],
								   [info.name substringFromIndex:1]];
		SEL sel = NSSelectorFromString(info.setterSelectorName);
		info.setterSelector = sel;
	}
	
	return info;
}

- (void)setTypeAttrib:(NSString *)typeAttrib rootModelClass:(Class)rootModelClass
{
	self.typePropertyAttrib = typeAttrib;
	
	if ([typeAttrib hasPrefix:@"Tb"] || [typeAttrib hasPrefix:@"TB"])
	{
		self.type = RFJModelPropertyTypeBOOL;
	}
	else if ([typeAttrib hasPrefix:@"Tc"] || [typeAttrib hasPrefix:@"TC"])
	{
		self.type = RFJModelPropertyTypeChar;
	}
	else if ([typeAttrib hasPrefix:@"Ti"] || [typeAttrib hasPrefix:@"TI"])
	{
		self.type = RFJModelPropertyTypeInt32;
	}
	else if ([typeAttrib hasPrefix:@"Tl"] || [typeAttrib hasPrefix:@"TL"])
	{
		self.type = RFJModelPropertyTypeInt32;
	}
	else if ([typeAttrib hasPrefix:@"Tq"] || [typeAttrib hasPrefix:@"TQ"])
	{
		self.type = RFJModelPropertyTypeInt64;
	}
	else if ([typeAttrib hasPrefix:@"Ts"] || [typeAttrib hasPrefix:@"TS"])
	{
		self.type = RFJModelPropertyTypeInt16;
	}
	else if ([typeAttrib hasPrefix:@"Tf"] || [typeAttrib hasPrefix:@"TF"])
	{
		self.type = RFJModelPropertyTypeFloat;
	}
	else if ([typeAttrib hasPrefix:@"Td"] || [typeAttrib hasPrefix:@"TD"])
	{
		self.type = RFJModelPropertyTypeDouble;
	}
	else if ([typeAttrib hasPrefix:@"T@\"NSString\""])
	{
		self.type = RFJModelPropertyTypeString;
	}
	else if ([typeAttrib hasPrefix:@"T@\"NSMutableString\""])
	{
		self.type = RFJModelPropertyTypeMutableString;
	}
	else if ([typeAttrib hasPrefix:@"T@\"NSArray\""])
	{
		self.type = RFJModelPropertyTypeArray;
	}
	else if ([typeAttrib hasPrefix:@"T@\"NSMutableArray\""])
	{
		self.type = RFJModelPropertyTypeMutableArray;
	}
	else if ([typeAttrib hasPrefix:@"T@\"NSArray<"])
	{
		// T@"NSArray<ClassName>"
		const char *className = [[typeAttrib substringWithRange:NSMakeRange(11, typeAttrib.length-13)] cStringUsingEncoding:NSUTF8StringEncoding];
		Class cls = objc_getClass(className);
		if (cls != nil && [cls isSubclassOfClass:rootModelClass])
		{
			self.type = RFJModelPropertyTypeModelArray;
			self.modelClassName = className;
			self.modelClass = cls;
		}
	}
	else if ([typeAttrib hasPrefix:@"T@\"NSMutableArray<"])
	{
		// T@"NSMutableArray<ClassName>"
		const char *className = [[typeAttrib substringWithRange:NSMakeRange(18, typeAttrib.length-20)] cStringUsingEncoding:NSUTF8StringEncoding];
		Class cls = objc_getClass(className);
		if (cls != nil && [cls isSubclassOfClass:rootModelClass])
		{
			self.type = RFJModelPropertyTypeMutableModelArray;
			self.modelClassName = className;
			self.modelClass = cls;
		}
	}
	else if ([typeAttrib hasPrefix:@"T@\"NSDictionary\""])
	{
		self.type = RFJModelPropertyTypeDictionary;
	}
	else if ([typeAttrib hasPrefix:@"T@\"NSMutableDictionary\""])
	{
		self.type = RFJModelPropertyTypeMutableDictionary;
	}
	else if ([typeAttrib hasPrefix:@"T@"] && typeAttrib.length > 4)
	{
		const char *className = [[typeAttrib substringWithRange:NSMakeRange(3, typeAttrib.length-4)] cStringUsingEncoding:NSUTF8StringEncoding];
		Class cls = objc_getClass(className);
		if (cls != nil)
		{
			// TODO:没测过不同基类的转换
			if ([cls isSubclassOfClass:rootModelClass]) {
				self.type = RFJModelPropertyTypeModel;
				self.modelClassName = className;
				self.modelClass = cls;
			} else {
				self.type = RFJModelPropertyTypeObject;
			}
		}
	}
}

@end
