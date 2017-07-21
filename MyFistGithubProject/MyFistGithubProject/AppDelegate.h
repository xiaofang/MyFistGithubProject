//
//  AppDelegate.h
//  MyFistGithubProject
//
//  Created by zyf on 17/7/21.
//  Copyright © 2017年 zyf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

