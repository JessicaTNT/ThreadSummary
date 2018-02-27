//
//  TicketManager.m
//  Tread
//
//  Created by dyso on 2018/2/26.
//  Copyright © 2018年 dyso. All rights reserved.
//

#import "TicketManager.h"
#define TotalTickets 50
@interface TicketManager ()
// 剩余票数
@property int ticktets;
// 卖出票数
@property int saleCount;

@property (nonatomic, strong) NSThread *threadBJ;
@property (nonatomic, strong) NSThread *threadSH;

// 加锁方式2-- condition
@property (nonatomic, strong) NSCondition *condition;

@end
@implementation TicketManager
- (instancetype)init{
    if (self = [super init]) {
        
        self.condition = [[NSCondition alloc] init];
        
        self.ticktets = TotalTickets;
        self.threadBJ = [[NSThread alloc] initWithTarget:self selector:@selector(sale) object:nil];
        [self.threadBJ setName:@"北京"];
        self.threadSH = [[NSThread alloc] initWithTarget:self selector:@selector(sale) object:nil];
        [self.threadSH setName:@"上海"];
    }
    return  self;
}
- (void)sale{
    while (true) {
        
        // 添加锁方式1
//        @synchronized(self){
        
        // 添加锁方式2
        [self.condition lock];
            // ticket>0 还可以继续卖票
            if (self.ticktets > 0) {
                [NSThread sleepForTimeInterval:0.5];
                self.ticktets--;
                self.saleCount = TotalTickets - self.ticktets;
                NSLog(@"%@: 当前余票: %d, 售出:%d", [NSThread currentThread].name, self.ticktets, self.saleCount);
            }
        [self.condition unlock];
//        }
       
    }
}
- (void)startToSale{
    [self.threadBJ start];
    [self.threadSH start];
}
@end
