//
//  NSObject+RFJModel.h
//  RFJModel
//
//  Created by GZH on 2017/7/4.
//  Copyright © 2017年 TechAtk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+RFJModelProperty.h"
#import "NSObject+RFSafeTransform.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - RFJModelStorageDelegate

@protocol RFJModelStorageDelegate <NSObject>
- (nullable id)rfj_objectForKey:(nonnull NSString *)key ofModel:(nonnull id)rfjModel;
- (void)rfj_setObject:(nullable id)value forKey:(nonnull NSString *)key ofModel:(nonnull id)rfjModel;
@optional
- (NSString *)rfj_transformKey:(NSString *)key;	// 经过该方法转换为storage对应的key，并存入缓存
@end

#pragma mark - NSObject (RFJModel)

@interface NSObject (RFJModel)

// 模型类initialize时调用一次，只有调用后才视为RFJModel，rfj_isRFJModel为YES。（优先使用）
// 也可以在init时调用，内部做了防护，索引只创建一次。但是每次检查仍然有对象创建，不是0损耗。
+ (void)rfj_initializeModelWithClass:(Class)cls rootModelClass:(Class)rootModelClass;

// Json字典装填到Model。usePropertyKey为NO使用属性定义的JSON Key，为YES使用属性名。
- (void)rfj_fillWithJsonDict:(NSDictionary *)jsonDict usePropertyKey:(BOOL)bUsePropertyKey;

// 深拷贝
+ (id)rfj_deepMutableCopyWithJson:(id)json;

// 转换方法
// fill的逆操作，空值不写入。usePropertyKey为NO使用属性定义的JSON Key，为YES使用属性名。
- (NSMutableDictionary *)rfj_toMutableDictionaryUsePropertyKey:(BOOL)bUsePropertyKey;
- (NSString *)rfj_toJsonStringUsePropertyKey:(BOOL)bUsePropertyKey;

// 序列化用RFJModel版本
+ (NSUInteger)rfj_modelVersion;
+ (NSString *)rfj_modelVersionSerializeKey;

// 序列化装填
- (void)rfj_decodeCoder:(NSCoder *)coder;
- (void)rfj_encodeCoder:(NSCoder *)coder;

// Data转换
+ (NSData *)rfj_toDataWithModel:(id)rfjModel;
+ (id)rfj_toModelWithData:(NSData *)data class:(Class)cls;

// 调试打印用
- (void)rfj_descriptionWithBuffer:(NSMutableString *)buffer indent:(NSInteger)indent;

#pragma mark - 自定义存储区

@property (nonatomic, weak) id<RFJModelStorageDelegate> rfj_storageDelegate;

// storage对应的key的缓存，每个Model种类对应一个字典
- (NSMutableDictionary *)rfj_cachedTransformKeys;

// Model所有的属性存储，无论静态动态均走这个方法。动态属性如果rfj_storageDelegate不为空，存取走rfj_storageDelegate，否则存取到自身关联对象。如果想自定义数据存取可以复写这个方法
- (nullable id)rfj_valueForKey:(NSString *)key;
- (void)rfj_setValue:(nullable id)value forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
