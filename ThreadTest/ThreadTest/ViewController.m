//
//  ViewController.m
//  ThreadTest
//
//  Created by dyso on 2018/2/27.
//  Copyright © 2018年 dyso. All rights reserved.
//

#import "ViewController.h"
#import <pthread.h>
#import "TicketManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // pthread 不常用
    UIButton *clickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    clickBtn.frame = CGRectMake(100, 100, 100, 30);
    [clickBtn setTitle:@"pTread" forState:UIControlStateNormal];
    [clickBtn addTarget:self action:@selector(clickpThread) forControlEvents:UIControlEventTouchUpInside];
    clickBtn.backgroundColor = [UIColor blueColor];
    [self.view addSubview:clickBtn];
    
    // NSTread
    UIButton *nsthreadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nsthreadBtn.frame = CGRectMake(100, 160, 100, 30);
    [nsthreadBtn setTitle:@"NSTread" forState:UIControlStateNormal];
    [nsthreadBtn addTarget:self action:@selector(clickNSThread) forControlEvents:UIControlEventTouchUpInside];
    nsthreadBtn.backgroundColor = [UIColor blueColor];
    [self.view addSubview:nsthreadBtn];
    
    // 模拟售票
    UIButton *sale = [UIButton buttonWithType:UIButtonTypeCustom];
    sale.frame = CGRectMake(100, 220, 100, 30);
    [sale setTitle:@"开始售票" forState:UIControlStateNormal];
    [sale addTarget:self action:@selector(saleTicktes) forControlEvents:UIControlEventTouchUpInside];
    sale.backgroundColor = [UIColor blueColor];
    [self.view addSubview:sale];
    
    // GCD: 为了多核手机的高效率执行,自动管理生命周期
    // (同步&异步, 串行&并行)
    // dispatch_get_main_queue & dispatch_get_global_que
    UIButton *gcdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    gcdBtn.frame = CGRectMake(100, 280, 100, 30);
    [gcdBtn setTitle:@"GCD" forState:UIControlStateNormal];
    [gcdBtn addTarget:self action:@selector(clickGCD) forControlEvents:UIControlEventTouchUpInside];
    gcdBtn.backgroundColor = [UIColor blueColor];
    [self.view addSubview:gcdBtn];
}

- (void)saleTicktes{
    TicketManager *manager = [[TicketManager alloc] init];
    [manager startToSale];
}
#pragma mark -- pThread
- (void)clickpThread{
    NSLog(@"我是主线程中执行");
    // 创建pthread指针
    pthread_t pthread;
    // 创建pthread
    pthread_create(&pthread, NULL, run, NULL);
    // 参数1: pthread指针
    // 参数3: 执行的方法
    
}
void *run(void *data){
    for (int i = 1; i < 10; i++) {
        NSLog(@"我在子线程中执行%d", i);
        // 每执行一次 休眠1s
        sleep(1);
    }
    return NULL;
}

#pragma mark -- NSThread
- (void)clickNSThread{
    // 创建NSThread有3种形式
    // 1.alloc创建(虽然创建比较麻烦,但是开发中用的相对较多),可以设置线程的名字,优先级
    NSLog(@"主线程中执行--NSThread");
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(runNSThread1) object:nil];
    // 给线程设置名字
    [thread1 setName:@"NSThread1"];
    // 设置优先级
    [thread1 setThreadPriority:0.2];
    [thread1 start];
    
    NSThread *thread2 = [[NSThread alloc] initWithTarget:self selector:@selector(runNSThread1) object:nil];
    // 给线程设置名字
    [thread2 setName:@"NSThread2"];
    // 设置优先级
    [thread1 setThreadPriority:0.5];
    [thread2 start];
    // 2.detachNewThreadSelctor 创建
    [NSThread detachNewThreadSelector:@selector(runNSThread1) toTarget:self withObject:nil];
    
    // 3.performSelectorInBackground 创建
    [self performSelectorInBackground:@selector(runNSThread1) withObject:nil];
}
- (void)runNSThread1{
    NSLog(@"%@子线程执行--NSThread", [NSThread currentThread].name);
    for (int i = 1; i < 10; i++) {
        NSLog(@"%d", i);
        sleep(1);
        if (i == 9) {
            [self performSelectorOnMainThread:@selector(runInmainThread) withObject:nil waitUntilDone:YES];
        }
    }
}
- (void)runInmainThread{
    NSLog(@"回到主线程中执行");
}
#pragma MARK -- GCD
- (void)clickGCD{
    NSLog(@"执行GCD");
    // 1.
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 执行耗时操作
        NSLog(@"start task 1");
        [NSThread sleepForTimeInterval:3];
        // 回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"刷新");
        });
    });
    
    // 2.global_queue:全局并发队列
    // 参数1:优先级 DISPATCH_QUEUE_PRIORITY_LOW, DISPATCH_QUEUE_PRIORITY_HIGH, DISPATCH_QUEUE_PRIORITY_DEFAULT
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"task 1");
        [NSThread sleepForTimeInterval:2];
        NSLog(@"task1 end");
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"task 2");
        [NSThread sleepForTimeInterval:2];
        NSLog(@"task2 end");
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"task 3");
        [NSThread sleepForTimeInterval:2];
        NSLog(@"task3 end");
    });
    
    // 3. 执行串行队列
    // 参数1:队列的id
    // 参数2:队列的类型:DISPATCH_QUEUE_CONCURRENT(并行,开辟了多个线程) , 默认的是NULL即串行队列(是在一个线程中执行)
    dispatch_queue_t queue = dispatch_queue_create("gcd_que", NULL);
    dispatch_async(queue, ^{
        NSLog(@"task 1");
        [NSThread sleepForTimeInterval:2];
        NSLog(@"task1 end");
    });
    dispatch_async(queue, ^{
        NSLog(@"task 2");
        [NSThread sleepForTimeInterval:2];
        NSLog(@"task2 end");
    });
    dispatch_async(queue, ^{
        NSLog(@"task 3");
        [NSThread sleepForTimeInterval:2];
        NSLog(@"task3 end");
    });
    
    
    // GCD-Group
    dispatch_queue_t queueGroup = dispatch_queue_create("gcd_group", DISPATCH_QUEUE_CONCURRENT); // 创建并行的queue
    dispatch_group_t group  = dispatch_group_create();
    
    // 1. 完成执行异步请求,并且统一通知任务完成
    dispatch_group_enter(group);
    [self sendRequest1:^{
        NSLog(@"request1 done");
        dispatch_group_leave(group);
    }];
    dispatch_group_enter(group);
    [self sendRequest2:^{
        NSLog(@"request2 done");
        dispatch_group_leave(group);
    }];
    
    // 2. test
    dispatch_group_async(group, queueGroup, ^{
        // 1.
        //        NSLog(@"task 1");
        //        [NSThread sleepForTimeInterval:2];
        //        NSLog(@"task1 end");
        // 2.完成异步请求的任务
        [self sendRequest1:^{
            NSLog(@"request1 done");
        }];
    });
    dispatch_group_async(group, queueGroup, ^{
        // 1.
        //        NSLog(@"task 2");
        //        [NSThread sleepForTimeInterval:2];
        //        NSLog(@"task2 end");
        // 2.加载异步请求的任务
        [self sendRequest2:^{
            NSLog(@"request2 done");
        }];
    });
    dispatch_group_async(group, queueGroup, ^{
        NSLog(@"task 3");
        [NSThread sleepForTimeInterval:2];
        NSLog(@"task3 end");
    });
    
    dispatch_group_notify(group, queueGroup, ^{
        // 在子线程中执行改通知,如果要刷新UI要回到主线程
        NSLog(@"所有group任务结束后的通知");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"回到主线程");
        });
        
    });
}
- (void)sendRequest1:(void(^)(void))block{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"task 1");
        [NSThread sleepForTimeInterval:2];
        NSLog(@"task1 end");
        if (block) {
            block();
        }
    });
}
- (void)sendRequest2:(void(^)(void))block{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"task 2");
        [NSThread sleepForTimeInterval:2];
        NSLog(@"task2 end");
        if (block) {
            block();
        }
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
