//
//  ViewController.m
//  RFJModel
//
//  Created by gouzhehua on 14-12-10.
//  Copyright (c) 2014年 TechAtk. All rights reserved.
//

#import "ViewController.h"
#import "ExampleModel.h"
#import "ExampleCustomStorageModel.h"
#import "ExampleUD.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)btnType_Click:(id)sender
{
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ExampleType" ofType:@"txt"];
	NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
	self.tvJson.text = content;
	
	ExampleModelTestType *model = [[ExampleModelTestType alloc] init];
	self.tvResult.text = [model description];
	
	NSString *result1 = [NSString stringWithFormat:@"\ninput:\n%@\n\noutput:\n%@", self.tvJson.text, self.tvResult.text];
	NSString *result2 = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"result_Type" ofType:@"txt"]
												  encoding:NSUTF8StringEncoding error:nil];
	NSLog(@"%@", result1);
	if ([result1 isEqualToString:result2])
	{
		NSLog(@"result_Type OK");
	}
	else
	{
		NSLog(@"result_Type FAIL");
	}
}

- (IBAction)btnJson_Click:(id)sender
{
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ExampleJson" ofType:@"txt"];
	NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
	self.tvJson.text = content;
	
	NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:NSJSONReadingMutableContainers error:nil];
	ExampleModelTestJson *model = [[ExampleModelTestJson alloc] initWithJsonDict:json];
	self.tvResult.text = [model description];
	
	NSString *result1 = [NSString stringWithFormat:@"\ninput:\n%@\n\noutput:\n%@", self.tvJson.text, self.tvResult.text];
	NSString *result2 = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"result_Json" ofType:@"txt"]
												  encoding:NSUTF8StringEncoding error:nil];
	NSLog(@"%@", result1);
	if ([result1 isEqualToString:result2])
	{
		NSLog(@"result_Type OK");
	}
	else
	{
		NSLog(@"result_Type FAIL");
	}
}

- (IBAction)btnInherit_Click:(id)sender
{
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ExampleJson" ofType:@"txt"];
	NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
	self.tvJson.text = content;
	
	NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:NSJSONReadingMutableContainers error:nil];
	ExampleModelTestChild *model = [[ExampleModelTestChild alloc] initWithJsonDict:json];
	self.tvResult.text = [model description];
	
	NSString *result1 = [NSString stringWithFormat:@"\ninput:\n%@\n\noutput:\n%@", self.tvJson.text, self.tvResult.text];
	NSString *result2 = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"result_Inherit" ofType:@"txt"]
												  encoding:NSUTF8StringEncoding error:nil];
	NSLog(@"%@", result1);
	if ([result1 isEqualToString:result2])
	{
		NSLog(@"result_Type OK");
	}
	else
	{
		NSLog(@"result_Type FAIL");
	}
	
	// 序列化
	{
		NSData* saveData = [NSObject rfj_toDataWithModel:model];
		ExampleModelTestChild *newModel = [NSObject rfj_toModelWithData:saveData class:[ExampleModelTestChild class]];
		NSString *value1 = [model description];
		NSString *value2 = [newModel description];
		if ([value1 isEqualToString:value2])
		{
			NSLog(@"序列化成功");
		}
		else
		{
			NSLog(@"序列化失败");
		}
	}
	
//	// NSObject属性排除测试
//	{
//		ExampleProtocolModel *oldM = [[ExampleProtocolModel alloc] init];
//		oldM.name = [NSString stringWithFormat:@"test"];
//		NSData *data = [RFJModel toDataWithModel:oldM];
//		ExampleProtocolModel *newM = [RFJModel toModelWithData:data class:[ExampleProtocolModel class]];
//		NSLog(@"%@", newM);
//	}
}

- (IBAction)btnCustomStorage_Click:(id)sender
{
//	ExampleUD *ud = [[ExampleUD alloc] initWithDomain:@"www.test.com"];
//	ud.testString = @"aaa";
//	ud.testInt = 123;
//	
//	return;
//	
//	
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ExampleCustomStorageModelJson" ofType:@"txt"];
	NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
	self.tvJson.text = content;
	
	NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:NSJSONReadingMutableContainers error:nil];
	ExampleCustomStorageModel *model = [[ExampleCustomStorageModel alloc] initWithJsonDict:json];
	self.tvResult.text = [model description];
	
	NSString *result1 = [NSString stringWithFormat:@"\ninput:\n%@\n\noutput:\n%@", self.tvJson.text, self.tvResult.text];
	NSString *result2 = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"result_CustomStorage" ofType:@"txt"]
												  encoding:NSUTF8StringEncoding error:nil];
	NSLog(@"%@", result1);
	if ([result1 isEqualToString:result2])
	{
		NSLog(@"result_Type OK");
	}
	else
	{
		NSLog(@"result_Type FAIL");
	}
	
	model.normalValue = @"hahaha";
	model.normalStorageValue = @"aaaa";
	model.weakStorageValue = [[NSMutableString alloc] initWithFormat:@"test%@", model.normalValue];
	model.jpStorageCharValue1 = 'a';
	model.jpStorageCharValue2 = 123;
	model.assignIntValue = J2Integer(@"01234567890");
	
	static ExampleCustomStorageModel *s_model = nil;
	s_model = model;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		NSLog(@"%@", s_model.weakStorageValue);
	});
	
}

@end
