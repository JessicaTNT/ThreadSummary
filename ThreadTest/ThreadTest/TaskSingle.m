//
//  TaskSingle.m
//  ThreadTest
//
//  Created by dyso on 2018/2/27.
//  Copyright © 2018年 dyso. All rights reserved.
//

#import "TaskSingle.h"

@implementation TaskSingle
+ (instancetype)shareInstance{
    static dispatch_once_t once;
    static TaskSingle *task;
    dispatch_once(&once, ^{
        NSLog(@"初始化单例");
        task = [[TaskSingle alloc] init];
    });
    return task;
    
}
@end
