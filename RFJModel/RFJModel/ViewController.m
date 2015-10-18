//
//  ViewController.m
//  RFJModel
//
//  Created by gouzhehua on 14-12-10.
//  Copyright (c) 2014年 TechAtk. All rights reserved.
//

#import "ViewController.h"
#import "ExampleModel.h"

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
	
	NSLog(@"\ninput:\n%@\n\noutput:\n%@", self.tvJson.text, self.tvResult.text);
}

- (IBAction)btnJson_Click:(id)sender
{
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ExampleJson" ofType:@"txt"];
	NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
	self.tvJson.text = content;
	
	NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:NSJSONReadingMutableContainers error:nil];
	ExampleModelTestJson *model = [[ExampleModelTestJson alloc] initWithJsonDict:json];
	self.tvResult.text = [model description];
	
	NSLog(@"\ninput:\n%@\n\noutput:\n%@", self.tvJson.text, self.tvResult.text);
}

- (IBAction)btnInherit_Click:(id)sender
{
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ExampleJson" ofType:@"txt"];
	NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
	self.tvJson.text = content;
	
	NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:NSJSONReadingMutableContainers error:nil];
	ExampleModelTestChild *model = [[ExampleModelTestChild alloc] initWithJsonDict:json];
	self.tvResult.text = [model description];
	
	NSLog(@"\ninput:\n%@\n\noutput:\n%@", self.tvJson.text, self.tvResult.text);
	
//	// NSObject属性排除测试
//	{
//		ExampleProtocolModel *oldM = [[ExampleProtocolModel alloc] init];
//		oldM.name = [NSString stringWithFormat:@"test"];
//		NSData *data = [RFJModel toDataWithModel:oldM];
//		ExampleProtocolModel *newM = [RFJModel toModelWithData:data class:[ExampleProtocolModel class]];
//		NSLog(@"%@", newM);
//	}
}

@end
