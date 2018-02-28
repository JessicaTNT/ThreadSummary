//
//  AppDelegate.h
//  GCD
//
//  Created by weisheng on 13-8-20.
//  Copyright (c) 2013年 tianya2416. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDViewController.h"
#import "Reachability.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> 
{
    Reachability * Reach;
   
}

@property (strong, nonatomic) UIWindow *window;

@end
