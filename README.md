RFJModel
========

RFJModel是一个IOS类库，可以将JSON字典自动装填到OBJC对象。

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
ExampleJModel *model = [[ExampleJModel alloc] init];
NSDictionary *json = ...;
[model fillWithJsonDict:json];
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
*所有的[NSNull null]对象都会被适当转换，不会赋值到JProperty属性。（因缺乏对[NSNull null]防护导致的崩溃，是JSON解析崩溃最主要的原因）
*赋值时，会根据JProperty声明的属性类型对JSON值进行转换。比如JSON中的Number赋值时可以被自动转换为NSString。
*JSON字典中多余或者缺失的字段不报错。

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
ExampleJModel *model = [[ExampleJModel alloc] init];
NSDictionary *json = ...;
[model fillWithJsonDict:json];
NSLog(@"%@", model.value_NSString);	// "hello world"

ExampleJSubModel *model = [[ExampleJModel alloc] init];
NSDictionary *json = ...;
[model fillWithJsonDict:json];
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
*BOOL
*Number(NSInteger, short, long long, double, etc)
*NSString
*NSMutableString
*NSArray
*NSMutableArray
*NSDictionary
*NSMutableDictionary
*RFJModel's subclass
*NSArray <RFJModel's subclass>
*NSMutableArray <RFJModel's subclass>

