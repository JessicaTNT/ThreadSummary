//
//  GCDViewController.h
//  GCD
//
//  Created by weisheng on 13-8-20.
//  Copyright (c) 2013年 tianya2416. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "ASINetworkQueue.h"
@interface GCDViewController : UIViewController<ASIHTTPRequestDelegate>
@property(retain,nonatomic)NSOperationQueue * queue;
@property(retain,nonatomic)ASINetworkQueue * WorkQueue;
@property(retain,nonatomic)UIImageView * imageView;
@end
