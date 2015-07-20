RFJModel
========

RFJModel is an easy-to-use JSON modelling library. In comparing with other libraries, it's much easiler and less restricted to use. RFJModel has the following characteristics.

####Note. Support ARC Only

####1. Defining loading rules in the class declaration.
RFJModel uses a macro, called JProperty, to declare loading rules. JProperty declares loading properties, converted types and mapping keys in JSON. The following example is to declare a property called "value_NSString". When JSON is loading, RFJModel gets the value from field "map_value_NSString" in JSON, converts the field type to NSString, and sets the value to the property "value_NSString".

```objective-c
@interface ExampleJModel : RFJModel
JProperty(NSString *value_NSString, map_value_NSString);
@end

@implementation ExampleJModel
@end
```
```json
{
"map_value_NSString":"hello world",
}
```
```objective-c
NSDictionary *json = ...;
ExampleJModel *model = [[ExampleJModel alloc] initWithJsonDict:json];
NSLog(@"%@", model.value_NSString);
```

####2. Supporting JProperty、@property mixing declaration without influencing each other.
In the following example, only "value_NSString" will be loaded, not "tag".

```objective-c
@interface ExampleJModel : RFJModel
JProperty(NSString *value_NSString, map_value_NSString);
@property (nonatomic, assign) int64_t tag;
@end
```
####3. Reducing crashes from errors returned by the servers
* All [NSNull null] objects will be converted appropriately, and would not be set to JProperty. (Lacking protections to [NSNull null] is a main cause of the crashes.)
* When setting the values, the value of JSON will be converted basing on the type of JProperty. For example, the Number in JSON will be converted into NSString in JProperty.
* Extra or missing fields in a JSON dictionary would not be considered as an error.

####4. Supporting class inherits
```objective-c
@interface ExampleJModel : RFJModel
JProperty(NSString *value_NSString, map_value_NSString);
@property (nonatomic, assign) int64_t tag;
@end

@interface ExampleJSubModel : ExampleJModel
JProperty(NSString *name, name);
@end
```
```json
{
"map_value_NSString":"hello world",
"name":"Tom",
}
```
```objective-c
NSDictionary *json = ...;
ExampleJModel *model = [[ExampleJModel alloc] initWithJsonDict:json];
NSLog(@"%@", model.value_NSString);	// "hello world"

NSDictionary *json = ...;
ExampleJSubModel *model = [[ExampleJSubModel alloc] initWithJsonDict:json];
NSLog(@"%@", model.value_NSString);	// "hello world"
NSLog(@"%@", model.name);	// "Tom"
```
####5. Supporting RFJModel subclasses in JProperty
```objective-c
@interface ExampleJModel : RFJModel
JProperty(NSString *value_NSString, map_value_NSString);
@property (nonatomic, assign) int64_t tag;
JProperty(ExampleJUserInfo *userInfo, UserInfo);
@end

@interface ExampleJUserInfo : RFJModel
JProperty(NSString *name, name);
@end
```
```json
{
"map_value_NSString":"hello world",
"UserInfo":
{
"name":"Tom",
},
}
```
####6. Supporting arrays containing instances of RFJModel subclasses in JProperty
```objective-c
@protocol ExampleJUserInfo
@end

@interface ExampleJModel : RFJModel
JProperty(NSString *value_NSString, map_value_NSString);
@property (nonatomic, assign) int64_t tag;
JProperty(NSArray<ExampleJUserInfo> *userInfos, UserInfos);
@end

@interface ExampleJUserInfo : RFJModel
JProperty(NSString *name, name);
@end
```
```json
{
"map_value_NSString":"hello world",
"UserInfos":[
{
"name":"Tom",
},
{
"name":"Alice",
},
],
}
```
####7. Supporting NSMutableString, NSMutableArray and NSMutableDictionary in JProperty and Converting nested containers to mutable containers.

####8. Supporting given types in JProperty only, and an execption will be thrown if any other type is in use
* BOOL
* Number(NSInteger, short, long long, double, etc)
* NSString
* NSMutableString
* NSArray
* NSMutableArray
* NSDictionary
* NSMutableDictionary
* RFJModel's subclass
* NSArray (RFJModel's subclass)
* NSMutableArray (RFJModel's subclass)

####9. The JProperty implements NSCoding protocol. Support automatic serialization.

Finally, thanks to @sunpc for the translation.

========

RFJModel是一个IOS类库，可以将JSON字典自动装填到OBJC对象。相比其他JSON装填库，RFJModel使用上更为简单，限制更少。

####注意：仅支持ARC

RFJModel有以下几个特点

####1、声明时确定装填行为。
RFJModel使用JProperty宏，以声明此属性是否用于JSON装填，装填类型，以及在JSON中的KEY。

下面的例子声明了一个value_NSString属性，他会将字典中的map_value_NSString字段，转换为NSString，设置到属性value_NSString。

```objective-c
@interface ExampleJModel : RFJModel
JProperty(NSString *value_NSString, map_value_NSString);
@end

@implementation ExampleJModel
@end
```
```json
{
	"map_value_NSString":"hello world",
}
```
```objective-c
NSDictionary *json = ...;
ExampleJModel *model = [[ExampleJModel alloc] initWithJsonDict:json];
NSLog(@"%@", model.value_NSString);
```

####2、RFJModel支持JProperty、@property混合声明，不相互影响。

下面的例子中只有value_NSString属性被自动装填，tag属性不被RFJModel所管理
```objective-c
@interface ExampleJModel : RFJModel
JProperty(NSString *value_NSString, map_value_NSString);
@property (nonatomic, assign) int64_t tag;
@end
```
####3、RFJModel设计的目的之一，是为了尽可能减少由于服务端接口定义或返回有误导致IOS客户端崩溃的问题。所以引入以下几个特性
* 所有的[NSNull null]对象都会被适当转换，不会赋值到JProperty属性。（因缺乏对[NSNull null]防护导致的崩溃，是JSON解析崩溃最主要的原因）
* 赋值时，会根据JProperty声明的属性类型对JSON值进行转换。比如JSON中的Number赋值时可以被自动转换为NSString。
* JSON字典中多余或者缺失的字段不报错。

####4、RFJModel支持继承
```objective-c
@interface ExampleJModel : RFJModel
JProperty(NSString *value_NSString, map_value_NSString);
@property (nonatomic, assign) int64_t tag;
@end

@interface ExampleJSubModel : ExampleJModel
JProperty(NSString *name, name);
@end
```
```json
{
	"map_value_NSString":"hello world",
	"name":"Tom",
}
```
```objective-c
NSDictionary *json = ...;
ExampleJModel *model = [[ExampleJModel alloc] initWithJsonDict:json];
NSLog(@"%@", model.value_NSString);	// "hello world"

NSDictionary *json = ...;
ExampleJSubModel *model = [[ExampleJSubModel alloc] initWithJsonDict:json];
NSLog(@"%@", model.value_NSString);	// "hello world"
NSLog(@"%@", model.name);	// "Tom"
```
####5、JProperty支持的类型包括RFJModel的子类。
```objective-c
@interface ExampleJModel : RFJModel
JProperty(NSString *value_NSString, map_value_NSString);
@property (nonatomic, assign) int64_t tag;
JProperty(ExampleJUserInfo *userInfo, UserInfo);
@end

@interface ExampleJUserInfo : RFJModel
JProperty(NSString *name, name);
@end
```
```json
{
	"map_value_NSString":"hello world",
	"UserInfo":
	{
		"name":"Tom",
	},
}
```
####6、JProperty支持的类型包括RFJModel子类的数组。
```objective-c
@protocol ExampleJUserInfo
@end

@interface ExampleJModel : RFJModel
JProperty(NSString *value_NSString, map_value_NSString);
@property (nonatomic, assign) int64_t tag;
JProperty(NSArray<ExampleJUserInfo> *userInfos, UserInfos);
@end

@interface ExampleJUserInfo : RFJModel
JProperty(NSString *name, name);
@end
```
```json
{
	"map_value_NSString":"hello world",
	"UserInfos":[
		{
			"name":"Tom",
		},
		{
			"name":"Alice",
		},
	],
}
```
####7、JProperty支持NSMutableString、NSMutableArray、NSMutableDictionary可变类型。同时NSMutableArray、NSMutableDictionary嵌套的容器也将尽可能转换为可变类型。 

####8、JProperty只支持下面的类型声明。如非以下类型被声明，将在第一次使用时抛出异常
* BOOL
* Number(NSInteger, short, long long, double, etc)
* NSString
* NSMutableString
* NSArray
* NSMutableArray
* NSDictionary
* NSMutableDictionary
* RFJModel's subclass
* NSArray (RFJModel's subclass)
* NSMutableArray (RFJModel's subclass)

####9. JProperty实现了NSCoding协议。支持自动序列化。
