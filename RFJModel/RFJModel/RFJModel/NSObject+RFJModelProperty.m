//
//  NSObject+RFJModelProperty.m
//  RFJModel
//
//  Created by GZH on 2017/7/4.
//  Copyright © 2017年 TechAtk. All rights reserved.
//

#import "NSObject+RFJModelProperty.h"
#import "NSObject+RFSafeTransform.h"
#import <objc/runtime.h>

@interface NSObject (RFJModelPropertyInner)

+ (NSMutableDictionary *)rfj_model2RootModel;
+ (NSMutableDictionary *)rfj_modelPropertyInfos;

+ (NSMutableDictionary *)rfj_modelSelector2PropertyInfos;
+ (void)rfj_generateUndefineGetterOfClass:(Class)cls byPropertyInfo:(RFJModelPropertyInfo *)pi;
+ (void)rfj_generateUndefineSetterOfClass:(Class)cls byPropertyInfo:(RFJModelPropertyInfo *)pi;

@end

static NSRecursiveLock *s_RFJModelLock = nil;

@implementation NSObject (RFJModelProperty)

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		s_RFJModelLock = [[NSRecursiveLock alloc] init];
		s_RFJModelLock.name = @"RFJModelLock";
	});
}

+ (void)rfj_analyseModelWithClass:(Class)cls rootModelClass:(Class)rootModelClass
{
	[s_RFJModelLock lock];
	
	NSString *className = NSStringFromClass(cls);
	if ([[NSObject rfj_model2RootModel] objectForKey:className] == nil
		&& [cls isSubclassOfClass:rootModelClass])
	{
		NSString *rootModelClassName = NSStringFromClass(rootModelClass);
		NSMutableDictionary *mapProperInfos = [NSMutableDictionary dictionary];
		NSMutableDictionary *mapJsonProperInfos = [NSMutableDictionary dictionary];
		NSMutableDictionary *mapSelector2PropertyInfos = [NSMutableDictionary dictionary];
		
		Class current = cls;
		NSInteger propertyIdx = 0;
		while (current != rootModelClass)
		{
			unsigned count = 0;
			objc_property_t *properties = class_copyPropertyList(current, &count);
			for (unsigned i = 0; i < count; i++)
			{
				objc_property_t property = properties[i];
				RFJModelPropertyInfo *pi = [RFJModelPropertyInfo propertyInfoWithProperty:&property rootModelClass:rootModelClass];
				if (pi != nil)
				{
					pi.propertyIdx = propertyIdx++;
					[mapProperInfos setObject:pi forKey:pi.name];
					if (pi.isJsonProperty && !IS_EMPTY_STR(pi.mapName))
					{
						[mapJsonProperInfos setObject:pi forKey:pi.mapName];
					}
					
					// 建立SEL2Property映射关系
					mapSelector2PropertyInfos[pi.getterSelectorName] = pi;
					mapSelector2PropertyInfos[pi.setterSelectorName] = pi;
					
					// 生成未定义的Property方法
					[NSObject rfj_generateUndefineGetterOfClass:current byPropertyInfo:pi];
					[NSObject rfj_generateUndefineSetterOfClass:current byPropertyInfo:pi];
				}
			}
			free(properties);
			
			current = [current superclass];
		}
		
		[[NSObject rfj_modelPropertyInfos] setObject:mapProperInfos forKey:className];
		[[NSObject rfj_modelSelector2PropertyInfos] setObject:mapSelector2PropertyInfos forKey:className];
		[[NSObject rfj_model2RootModel] setObject:rootModelClassName forKey:className];
	}
	
	[s_RFJModelLock unlock];
}

+ (NSMutableDictionary *)rfj_model2RootModel
{
	static NSMutableDictionary *s_instance = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		s_instance = [[NSMutableDictionary alloc] init];
	});
	
	return s_instance;
}

+ (NSMutableDictionary *)rfj_modelPropertyInfos
{
	static NSMutableDictionary *s_instance = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		s_instance = [[NSMutableDictionary alloc] init];
	});
	
	return s_instance;
}

+ (BOOL)rfj_isRFJModel:(Class)cls
{
	NSString *rootModelClassName = nil;
	[s_RFJModelLock lock];
	{
		rootModelClassName = [[NSObject rfj_model2RootModel] objectForKey:NSStringFromClass(cls)];
	}
	[s_RFJModelLock unlock];
	return (rootModelClassName != nil);
}

- (NSString *)rfj_getClassName
{
	static void *kRFJModelClassNameKey = "kRFJModelClassNameKey";
	NSString *name = (NSString *)objc_getAssociatedObject(self, kRFJModelClassNameKey);
	if (name == nil)
	{
		name = NSStringFromClass([self class]);
		objc_setAssociatedObject(self, kRFJModelClassNameKey, name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return name;
}

- (NSString *)rfj_getRootModelClassName
{
	NSString *rootModelClassName = nil;
	[s_RFJModelLock lock];
	{
		rootModelClassName = [[NSObject rfj_model2RootModel] objectForKey:[self rfj_getClassName]];
	}
	[s_RFJModelLock unlock];
	return rootModelClassName;
}

- (BOOL)rfj_isRFJModel
{
	return ([self rfj_getRootModelClassName] != nil);
}

- (NSMutableDictionary *)rfj_getPropertyInfos
{
	NSMutableDictionary *infos = nil;
	[s_RFJModelLock lock];
	{
		infos = [[NSObject rfj_modelPropertyInfos] objectForKey:[self rfj_getClassName]];
	}
	[s_RFJModelLock unlock];
	return infos;
}

#pragma mark - 自动为动态属性添加方法

- (RFJModelPropertyInfo *)propertyInfoForSelector:(SEL)selector
{
	NSString *key = NSStringFromSelector(selector);
	NSDictionary *mapSelector2PropertyInfos = [self rfj_getSelector2PropertyInfos];
	return [mapSelector2PropertyInfos objectForKey:key];
}

static short rfjModelMappingInt16Getter(id self, SEL _cmd)
{
	RFJModelPropertyInfo *pi = [self propertyInfoForSelector:_cmd];
	return [[self valueForKey:pi.name] shortValue];
}

static void rfjModelMappingInt16Setter(id self, SEL _cmd, short value)
{
	RFJModelPropertyInfo *pi = [self propertyInfoForSelector:_cmd];
	[self setValue:V2NumInt16(value) forKey:pi.name];
}

static int rfjModelMappingInt32Getter(id self, SEL _cmd)
{
	RFJModelPropertyInfo *pi = [self propertyInfoForSelector:_cmd];
	return [[self valueForKey:pi.name] intValue];
}

static void rfjModelMappingInt32Setter(id self, SEL _cmd, int value)
{
	RFJModelPropertyInfo *pi = [self propertyInfoForSelector:_cmd];
	[self setValue:V2NumInt32(value) forKey:pi.name];
}

static long long rfjModelMappingInt64Getter(id self, SEL _cmd)
{
	RFJModelPropertyInfo *pi = [self propertyInfoForSelector:_cmd];
	return [[self valueForKey:pi.name] longLongValue];
}

static void rfjModelMappingInt64Setter(id self, SEL _cmd, long long value)
{
	RFJModelPropertyInfo *pi = [self propertyInfoForSelector:_cmd];
	[self setValue:V2NumInt64(value) forKey:pi.name];
}

static BOOL rfjModelMappingBoolGetter(id self, SEL _cmd)
{
	RFJModelPropertyInfo *pi = [self propertyInfoForSelector:_cmd];
	return [[self valueForKey:pi.name] boolValue];
}

static void rfjModelMappingBoolSetter(id self, SEL _cmd, BOOL value)
{
	RFJModelPropertyInfo *pi = [self propertyInfoForSelector:_cmd];
	[self setValue:V2NumBool(value) forKey:pi.name];
}

static char rfjModelMappingCharGetter(id self, SEL _cmd)
{
	RFJModelPropertyInfo *pi = [self propertyInfoForSelector:_cmd];
	return [[self valueForKey:pi.name] charValue];
}

static void rfjModelMappingCharSetter(id self, SEL _cmd, char value)
{
	RFJModelPropertyInfo *pi = [self propertyInfoForSelector:_cmd];
	[self setValue:V2NumChar(value) forKey:pi.name];
}

static float rfjModelMappingFloatGetter(id self, SEL _cmd)
{
	RFJModelPropertyInfo *pi = [self propertyInfoForSelector:_cmd];
	return [[self valueForKey:pi.name] floatValue];
}

static void rfjModelMappingFloatSetter(id self, SEL _cmd, float value)
{
	RFJModelPropertyInfo *pi = [self propertyInfoForSelector:_cmd];
	[self setValue:V2NumFloat(value) forKey:pi.name];
}

static double rfjModelMappingDoubleGetter(id self, SEL _cmd)
{
	RFJModelPropertyInfo *pi = [self propertyInfoForSelector:_cmd];
	return [[self valueForKey:pi.name] doubleValue];
}

static void rfjModelMappingDoubleSetter(id self, SEL _cmd, double value)
{
	RFJModelPropertyInfo *pi = [self propertyInfoForSelector:_cmd];
	[self setValue:V2NumDouble(value) forKey:pi.name];
}

static id rfjModelMappingObjectGetter(id self, SEL _cmd)
{
	RFJModelPropertyInfo *pi = [self propertyInfoForSelector:_cmd];
	return [self valueForKey:pi.name];
}

static void rfjModelMappingObjectSetter(id self, SEL _cmd, id object)
{
	RFJModelPropertyInfo *pi = [self propertyInfoForSelector:_cmd];
	[self setValue:object forKey:pi.name];
}

+ (NSMutableDictionary *)rfj_modelSelector2PropertyInfos
{
	static NSMutableDictionary *s_instance = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		s_instance = [[NSMutableDictionary alloc] init];
	});
	
	return s_instance;
}

- (NSMutableDictionary *)rfj_getSelector2PropertyInfos
{
	NSMutableDictionary *infos = nil;
	[s_RFJModelLock lock];
	{
		infos = [[NSObject rfj_modelSelector2PropertyInfos] objectForKey:[self rfj_getClassName]];
	}
	[s_RFJModelLock unlock];
	return infos;
}

+ (void)rfj_generateUndefineGetterOfClass:(Class)cls byPropertyInfo:(RFJModelPropertyInfo *)pi
{
	if ([cls instancesRespondToSelector:pi.getterSelector]) {
		return;
	}
	
	const char *getter = [pi.getterSelectorName cStringUsingEncoding:NSASCIIStringEncoding];
	SEL getterSel = sel_registerName(getter);
	
	IMP getterImp = NULL;
	switch (pi.type) {
		case RFJModelPropertyTypeInt16:
			getterImp = (IMP)rfjModelMappingInt16Getter;
			break;
		case RFJModelPropertyTypeInt32:
			getterImp = (IMP)rfjModelMappingInt32Getter;
			break;
		case RFJModelPropertyTypeInt64:
			getterImp = (IMP)rfjModelMappingInt64Getter;
			break;
		case RFJModelPropertyTypeBOOL:
			getterImp = (IMP)rfjModelMappingBoolGetter;
			break;
		case RFJModelPropertyTypeChar:
			getterImp = (IMP)rfjModelMappingCharGetter;
			break;
		case RFJModelPropertyTypeFloat:
			getterImp = (IMP)rfjModelMappingFloatGetter;
			break;
		case RFJModelPropertyTypeDouble:
			getterImp = (IMP)rfjModelMappingDoubleGetter;
			break;
		case RFJModelPropertyTypeString:
		case RFJModelPropertyTypeMutableString:
		case RFJModelPropertyTypeArray:
		case RFJModelPropertyTypeMutableArray:
		case RFJModelPropertyTypeModelArray:
		case RFJModelPropertyTypeMutableModelArray:
		case RFJModelPropertyTypeDictionary:
		case RFJModelPropertyTypeMutableDictionary:
		case RFJModelPropertyTypeModel:
		case RFJModelPropertyTypeObject:
			getterImp = (IMP)rfjModelMappingObjectGetter;
			break;
		default:
			return;
	}
	
	char types[5];
	snprintf(types, 4, "%c@:", [pi.typePropertyAttrib characterAtIndex:1]);
	class_addMethod(cls, getterSel, getterImp, types);
}

+ (void)rfj_generateUndefineSetterOfClass:(Class)cls byPropertyInfo:(RFJModelPropertyInfo *)pi
{
	if ([cls instancesRespondToSelector:pi.setterSelector]) {
		return;
	}
	
	const char *setter = [pi.setterSelectorName cStringUsingEncoding:NSASCIIStringEncoding];
	SEL setterSel = sel_registerName(setter);
	
	IMP setterImp = NULL;
	switch (pi.type) {
		case RFJModelPropertyTypeInt16:
			setterImp = (IMP)rfjModelMappingInt16Setter;
			break;
		case RFJModelPropertyTypeInt32:
			setterImp = (IMP)rfjModelMappingInt32Setter;
			break;
		case RFJModelPropertyTypeInt64:
			setterImp = (IMP)rfjModelMappingInt64Setter;
			break;
		case RFJModelPropertyTypeBOOL:
			setterImp = (IMP)rfjModelMappingBoolSetter;
			break;
		case RFJModelPropertyTypeChar:
			setterImp = (IMP)rfjModelMappingCharSetter;
			break;
		case RFJModelPropertyTypeFloat:
			setterImp = (IMP)rfjModelMappingFloatSetter;
			break;
		case RFJModelPropertyTypeDouble:
			setterImp = (IMP)rfjModelMappingDoubleSetter;
			break;
		case RFJModelPropertyTypeString:
		case RFJModelPropertyTypeMutableString:
		case RFJModelPropertyTypeArray:
		case RFJModelPropertyTypeMutableArray:
		case RFJModelPropertyTypeModelArray:
		case RFJModelPropertyTypeMutableModelArray:
		case RFJModelPropertyTypeDictionary:
		case RFJModelPropertyTypeMutableDictionary:
		case RFJModelPropertyTypeModel:
		case RFJModelPropertyTypeObject:
			setterImp = (IMP)rfjModelMappingObjectSetter;
			break;
		default:
			return;
	}
	
	char types[5];
	snprintf(types, 5, "v@:%c", [pi.typePropertyAttrib characterAtIndex:1]);
	class_addMethod(cls, setterSel, setterImp, types);
}

@end
