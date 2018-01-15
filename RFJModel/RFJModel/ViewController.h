//
//  ViewController.h
//  RFJModel
//
//  Created by gouzhehua on 14-12-10.
//  Copyright (c) 2014年 TechAtk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{

}
@property (nonatomic, strong) IBOutlet UITextView *tvJson;
@property (nonatomic, strong) IBOutlet UITextView *tvResult;

- (IBAction)btnType_Click:(id)sender;
- (IBAction)btnJson_Click:(id)sender;
- (IBAction)btnInherit_Click:(id)sender;
- (IBAction)btnCustomStorage_Click:(id)sender;

@end

