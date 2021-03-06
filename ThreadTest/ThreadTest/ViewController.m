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
#import "TaskSingle.h"
#import "CustomOperation.h"
@interface ViewController ()
@property (nonatomic, strong) NSOperationQueue *operQueue;
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
    
    
    // 单例
    UIButton *singleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    singleBtn.frame = CGRectMake(100, 240, 100, 30);
    [singleBtn setTitle:@"单例" forState:UIControlStateNormal];
    [singleBtn addTarget:self action:@selector(singleBtnAction) forControlEvents:UIControlEventTouchUpInside];
    singleBtn.backgroundColor = [UIColor blueColor];
    [self.view addSubview:singleBtn];
    
    // 延迟执行
    UIButton *delayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    delayBtn.frame = CGRectMake(100, 300, 100, 30);
    [delayBtn setTitle:@"延迟执行" forState:UIControlStateNormal];
    [delayBtn addTarget:self action:@selector(delayBtnAction) forControlEvents:UIControlEventTouchUpInside];
    delayBtn.backgroundColor = [UIColor blueColor];
    [self.view addSubview:delayBtn];
    
    
    // NSOperation
    UIButton *operationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    operationBtn.frame = CGRectMake(100, 360, 150, 30);
    [operationBtn setTitle:@"NSOperation" forState:UIControlStateNormal];
    [operationBtn addTarget:self action:@selector(operationBtnAction) forControlEvents:UIControlEventTouchUpInside];
    operationBtn.backgroundColor = [UIColor blueColor];
    [self.view addSubview:operationBtn];
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
    // 1.经典的GCD用法
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
    
    
    // 4.GCD-Group的使用
    dispatch_queue_t queueGroup = dispatch_queue_create("gcd_group", DISPATCH_QUEUE_CONCURRENT); // 创建并行的queue
    dispatch_group_t group  = dispatch_group_create();
    
    // 1. 完成执行异步请求,并且统一通知任务完成(enter和leave成对出现)
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
    /*
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
    */
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


#pragma mark -- 单例
- (void)singleBtnAction{
//    [TaskSingle shareInstance];
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSLog(@"excuted only once");
    });
}
#pragma mark -- 延迟执行
- (void)delayBtnAction{
    NSLog(@"开始执行");
    // 缺点:只要执行了就不能停止
    // 参数:DISPATCH_TIME_NOW, DISPATCH_TIME_FOREVER
    // 参数:NSEC_PER_SEC ,NSEC_PER_MSEC, USEC_PER_SEC, NSEC_PER_USEC
    // 延迟2s执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"delay了");
    });
}

#pragma mark -- NSOperation
- (void)operationBtnAction{
    // 两种使用方式:
    // 1.NSInvocationOperation和NSBlockOperation 都是同步执行 会阻塞当前线程
    
    /*
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocationTask) object:nil];
    // 1).执行start方法会阻塞当前线程,同步执行
    [operation start];
    */
    

//    NSBlockOperation *blockOper = [NSBlockOperation blockOperationWithBlock:^{
//        for (int i = 0; i < 3; i++) {
//            NSLog(@"invocation %d", i);
//            [NSThread sleepForTimeInterval:1];
//        }
//    }];
        // 异步执行
    if (!self.operQueue) {
        self.operQueue = [[NSOperationQueue alloc] init];
    }
//    [blockOper start];
//    [self.operQueue addOperation:blockOper];
    NSLog(@"end");
    // 2.自定义类继承NSOperation
    CustomOperation *operationA = [[CustomOperation alloc] initWithName:@"It's me A ok? "];
    CustomOperation *operationB = [[CustomOperation alloc] initWithName:@"It's me B ok? "];
    CustomOperation *operationC = [[CustomOperation alloc] initWithName:@"It's me C ok? "];
    CustomOperation *operationD = [[CustomOperation alloc] initWithName:@"It's me D ok? "];

    // 设置最大并发数
    [self.operQueue setMaxConcurrentOperationCount:1];
    // 设置依赖关系:执行顺序B->C->A->D
    [operationD addDependency:operationA];
    [operationA addDependency:operationC];
    [operationC addDependency:operationB];
    // 4个线程并发执行
    [self.operQueue addOperation:operationA];
    [self.operQueue addOperation:operationB];
    [self.operQueue addOperation:operationC];
    [self.operQueue addOperation:operationD];
}
- (void)invocationTask{
    NSLog(@"main thread");
    // 耗时任务
    for (int i = 0; i < 3; i++) {
        NSLog(@"invocation %d", i);
        [NSThread sleepForTimeInterval:1];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
