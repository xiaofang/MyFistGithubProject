//
//  ViewController.h
//  MyFistGithubProject
//
//  Created by zyf on 17/7/21.
//  Copyright © 2017年 zyf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (nonatomic,copy) void(^testBlock)(void);
@property (nonatomic,strong)NSTimer *timer;

@end

