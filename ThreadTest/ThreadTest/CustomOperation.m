//
//  CustomOperation.m
//  ThreadTest
//
//  Created by dyso on 2018/2/28.
//  Copyright © 2018年 dyso. All rights reserved.
//

#import "CustomOperation.h"
@interface CustomOperation ()
@property (nonatomic, copy) NSString *operName;
@property BOOL over;
@end
@implementation CustomOperation
- (instancetype)initWithName:(NSString *)name{
    if (self = [super init]) {
        self.operName = name;
    }
    return self;
}
- (void)main{
    
    // 执行耗时操作
//    for (int i = 0; i < 3; i++) {
//        NSLog(@"%@ %d", self.operName, i);
//        [NSThread sleepForTimeInterval:1];
//    }
    // 执行异步的耗时操作
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [NSThread sleepForTimeInterval:1];
        if (self.cancelled) {
            return ;
        }
        NSLog(@"%@", self.operName);
        self.over = YES;
    });
    while (!self.over && !self.cancelled) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
}
@end
