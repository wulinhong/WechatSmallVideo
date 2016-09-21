//
//  ViewController.h
//  测试2
//
//  Created by linxun on 15/12/11.
//  Copyright © 2015年 linxun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *preview;
- (IBAction)startBUttonClick:(id)sender; // 开始录制
- (IBAction)startToPaly:(id)sender; // 开始播放

@end

