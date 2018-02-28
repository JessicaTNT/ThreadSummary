//
//  GCDViewController.m
//  GCD
//
//  Created by weisheng on 13-8-20.
//  Copyright (c) 2013年 tianya2416. All rights reserved.
//

#import "GCDViewController.h"
#import "ASIDownloadCache.h"
@interface GCDViewController ()

@end

@implementation GCDViewController
-(void)dealloc
{
    [super dealloc];
    [_WorkQueue release];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)initWithReachability
{
//  NotReachable     = kNotReachable,
//	ReachableViaWiFi = kReachableViaWiFi,
//	ReachableViaWWAN = kReachableViaWWAN
    Reachability * reach=[Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([reach currentReachabilityStatus])
    {
        case NotReachable:
        {
            NSLog(@"无网络连接");
        }
            break;
        case ReachableViaWiFi:
        {
            NSLog(@"使用WiFi");
        }
            break;
        case ReachableViaWWAN:
        {
            NSLog(@"使用3G网络");
        }
            break;
        default:
            break;
    }
}
//使用GCD创建多线程
-(void)initWithGCD
{
    
    //使用GCD创建多线层
//    dispatch_queue_t groupBack=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

//   dispatch_async(groupBack, ^{
//       [self initWithSameRequest];
//    });
    
    /*1 2 3 线程执行完 才开始执行4 5 6. 也就是说1 2 3 开始执行 4 5 6处于等待状态，1 2 3 执行完4 5 6马上进去执行*/
//    dispatch_queue_t aDQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_group_t group = dispatch_group_create();
//    dispatch_group_async(group, aDQueue, ^{
//        NSLog(@"task 1 \n");
//
//    });
//    dispatch_group_async(group, aDQueue, ^{
//        NSLog(@"task 2 \n");
//    });
//    dispatch_group_async(group, aDQueue, ^{
//        NSLog(@"task 3 \n");
//    });
//    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);//其他同类等待
//    dispatch_release(group);
//    
//    NSLog(@"1 23 完成 4 5 6开始了");
//    
//    
//    group = dispatch_group_create();
//    
//    
//    dispatch_group_async(group, aDQueue, ^{
//        NSLog(@"task 4 \n");
//    });
//    dispatch_group_async(group, aDQueue, ^{
//        NSLog(@"task 5 \n");
//    });
//    dispatch_group_async(group, aDQueue, ^{
//        NSLog(@"task 6 \n");
//    });
//    
//    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
//    dispatch_release(group);
}
//使用GCD通知主线程执行
-(void)initWithGradeCenterDispatch
{
    dispatch_queue_t  Queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(Queue, ^{
        NSURL * URL=[NSURL URLWithString:@"http://avatar.csdn.net/2/C/D/1_totogo2010.jpg"];
        NSData * DATA=[[NSData alloc]initWithContentsOfURL:URL];
        UIImage * image=[[UIImage alloc]initWithData:DATA];
        
        if (DATA!=nil)
        {
            //通知主线程更新界面
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               self.imageView.image=image;
                           });
            
        }
    });
}
//顺序执行
-(void)initDownLocation
{
    dispatch_queue_t  main=dispatch_queue_create("gcdtest.rongfzh.yc",DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(main, ^{
        NSLog(@"任务1");
    });
    dispatch_barrier_async(main, ^{
        NSLog(@"任务2");
    });
    dispatch_async(main, ^{
        NSLog(@"任务3");
    });
    
    
}

//代码执行N次
-(void)Ntimes
{
    dispatch_queue_t groupBack=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(5,groupBack, ^(size_t index)
    {
    // 执行5次
        NSLog(@"执行5次了吗");
    });
}
//创建一个同步请求
-(void)initWithSameRequest
{
 
    NSURL * url=[NSURL URLWithString:@"http://api.douban.com/book/subjects?q=%E4%B8%89&start-index=1&max-results=10&apikey=04f1ae6738f2fc450ed50b35aad8f4cf&alt=json"];
    ASIHTTPRequest * request=[[ASIHTTPRequest alloc]initWithURL:url];
   
    //设置是否按服务器在Header里指定的是否可被缓存或过期策略进行缓存:
    //[[ASIDownloadCache sharedCache]setShouldRespectCacheControlHeaders:NO];
    //设置缓存的有效时间 30天
    //[request setSecondsToCache:60*60*24*30];
    //判断能不能重缓存种读取
    //[request didUseCachedResponse];
    //设置缓存的路径
//    NSArray * path=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString * docpath=[path objectAtIndex:0];
//    [request setDownloadDestinationPath:docpath];
    //设置缓存 把缓存数据永久保存在本 地,
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    
  // [request setDownloadDestinationPath:[[ ASIDownloadCache sharedCache ] pathToStoreCachedResponseDataForRequest:request ]];
    [request startSynchronous];//同步下载
    NSError * error=[request error];
    if (!error)
    {
        //NSString *
        NSDictionary * json=[request.responseData objectFromJSONData];
      
        NSArray * allBooks = [json objectForKey:@"entry"];
        for (NSDictionary * book in allBooks)
        {
            // model=[[BookModel alloc]init];
            //评论
            NSString * avger=[[book objectForKey:@"gd:rating"]objectForKey:@"@average"];
            // model.rating=[avger floatValue];
            NSLog(@"%f",[avger floatValue]);
            NSString * number=[[book objectForKey:@"gd:rating"]objectForKey:@"@numRaters"];
            // model.numRatings=[number intValue];
            NSLog(@"%d",[number intValue]);
            //书的名字
            NSString * titleName=[[book objectForKey:@"title"] objectForKey:@"$t"];
            NSLog(@"书的名字:  %@",titleName);
            
            //model.bookName=titleName;
            //        NSArray * authotArray=[book objectForKey:@"author"];
            //        for (NSDictionary *author in authotArray)
            //        {
            //            NSString * authorName=[[book objectForKey:@"name"] objectForKey:@"$t"];
            //            NSLog(@"作者的名字  :%@",authorName);
            //        }
            
            // NSString * categotyName=[[book objectForKey:@"category"]objectForKey:@"@scheme"];
            // NSLog(@"categoty %@",categotyName);
            
            NSArray * attribute=[book objectForKey:@"db:attribute"];
            for (NSDictionary * attributess in attribute)
            {
                NSString * attraName=[attributess objectForKey:@"@name"];
                
                if ([attraName isEqualToString:@"pubdate"])
                {
                    NSString * pubdate=[attributess objectForKey:@"$t"];
                    NSLog(@"pubdate %@",pubdate);
                }
                else if ([attraName isEqualToString:@"publisher"])
                {
                    NSString * publisher=[attributess objectForKey:@"$t"];
                    // model.publisher=publisher;
                    NSLog(@"publisher %@",publisher);
                }
                else if ([attraName isEqualToString:@"price"])
                {
                    NSString * price=[attributess objectForKey:@"$t"];
                    NSLog(@"price %@",price);
                    //价格
                    // model.price=price;
                }
                else if ([attraName isEqualToString:@"author"])
                {
                    NSString * author=[attributess objectForKey:@"$t"];
                    NSLog(@"author %@",author);
                    //作者的名字
                    // model.autherName=author;
                }
                else if ([attraName isEqualToString:@"translator"])
                {
                    NSString * translator=[attributess objectForKey:@"$t"];
                    NSLog(@"translator %@",translator);
                    //出版社
                    //model.translator=translator;
                }
                
                
                
            }
            NSArray * link=[book objectForKey:@"link"];
            for (NSDictionary * image in link)
            {
                NSString * str=[image objectForKey:@"@rel"];
                if ([str isEqualToString:@"image"])
                {
                    //图片
                    NSString * pubdate=[image objectForKey:@"@href"];
                    NSLog(@"pubdate %@",pubdate);
                    //model.iconUrl=pubdate;
                }
                else if([str isEqualToString:@"mobile"])
                {
                    NSString * mobile=[image objectForKey:@"@href"];
                    // model.introUrl=mobile;
                    NSLog(@"mobile %@",mobile);
                }
            }
            
            
            
        }
     

    }
    [self performSelectorOnMainThread:@selector(hello) withObject:nil waitUntilDone:YES];
[request release];
}
-(void)hello
{
    NSLog(@"下载完成,请主线程注意更新");
}
//创建一个异步请求
-(void)initWithDifferent
{
    NSURL * url1=[NSURL URLWithString:@"http://api.douban.com/book/subjects?q=%E4%B8%89&start-index=1&max-results=10&apikey=04f1ae6738f2fc450ed50b35aad8f4cf&alt=json"];
    ASIHTTPRequest * request=[[ASIHTTPRequest alloc]initWithURL:url1];
   // [request cancel];//取消异步请求 这个是取消所有的异步请求
   // [request clearDelegatesAndCancel];//如果不想调用delegate方法
    request.delegate=self;
    [request startAsynchronous];//异步下载
}
-(void)requestFinished:(ASIHTTPRequest *)request//<ASIHTTPRequest: 0xe8f7c00>
{
    NSLog(@"%@",request);
    NSDictionary * json=[request.responseData objectFromJSONData];
    NSArray * allBooks = [json objectForKey:@"entry"];
    for (NSDictionary * book in allBooks)
    {
        // model=[[BookModel alloc]init];
        //评论
        NSString * avger=[[book objectForKey:@"gd:rating"]objectForKey:@"@average"];
        // model.rating=[avger floatValue];
        NSLog(@"%f",[avger floatValue]);
        NSString * number=[[book objectForKey:@"gd:rating"]objectForKey:@"@numRaters"];
        // model.numRatings=[number intValue];
        NSLog(@"%d",[number intValue]);
        //书的名字
        NSString * titleName=[[book objectForKey:@"title"] objectForKey:@"$t"];
        NSLog(@"书的名字:  %@",titleName);
        
        //model.bookName=titleName;
        //        NSArray * authotArray=[book objectForKey:@"author"];
        //        for (NSDictionary *author in authotArray)
        //        {
        //            NSString * authorName=[[book objectForKey:@"name"] objectForKey:@"$t"];
        //            NSLog(@"作者的名字  :%@",authorName);
        //        }
        
        // NSString * categotyName=[[book objectForKey:@"category"]objectForKey:@"@scheme"];
        // NSLog(@"categoty %@",categotyName);
        
        NSArray * attribute=[book objectForKey:@"db:attribute"];
        for (NSDictionary * attributess in attribute)
        {
            NSString * attraName=[attributess objectForKey:@"@name"];
            
            if ([attraName isEqualToString:@"pubdate"])
            {
                NSString * pubdate=[attributess objectForKey:@"$t"];
                NSLog(@"pubdate %@",pubdate);
            }
            else if ([attraName isEqualToString:@"publisher"])
            {
                NSString * publisher=[attributess objectForKey:@"$t"];
                // model.publisher=publisher;
                NSLog(@"publisher %@",publisher);
            }
            else if ([attraName isEqualToString:@"price"])
            {
                NSString * price=[attributess objectForKey:@"$t"];
                NSLog(@"price %@",price);
                //价格
                // model.price=price;
            }
            else if ([attraName isEqualToString:@"author"])
            {
                NSString * author=[attributess objectForKey:@"$t"];
                NSLog(@"author %@",author);
                //作者的名字
                // model.autherName=author;
            }
            else if ([attraName isEqualToString:@"translator"])
            {
                NSString * translator=[attributess objectForKey:@"$t"];
                NSLog(@"translator %@",translator);
                //出版社
                //model.translator=translator;
            }
            
            
            
        }
        NSArray * link=[book objectForKey:@"link"];
        for (NSDictionary * image in link)
        {
            NSString * str=[image objectForKey:@"@rel"];
            if ([str isEqualToString:@"image"])
            {
                //图片
                NSString * pubdate=[image objectForKey:@"@href"];
                NSLog(@"pubdate %@",pubdate);
                //model.iconUrl=pubdate;
            }
            else if([str isEqualToString:@"mobile"])
            {
                NSString * mobile=[image objectForKey:@"@href"];
                // model.introUrl=mobile;
                NSLog(@"mobile %@",mobile);
            }
        }
        
        
        
    }

}
-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"请求失败");
}

//创建一个NSOPeration队列请求
-(void)initWithQueue
{
    if (self.queue==nil)
    {
        self.queue=[[[NSOperationQueue alloc]init]autorelease];
        
    }
    //self.queue.maxConcurrentOperationCount
    NSURL * url=[NSURL URLWithString:@"http://api.douban.com/book/subjects?q=%E4%B8%89&start-index=1&max-results=10&apikey=04f1ae6738f2fc450ed50b35aad8f4cf&alt=json"];
    ASIHTTPRequest * request=[ASIHTTPRequest requestWithURL:url];
    //队列取消所有的请求
    //[self.queue cancelAllOperations];
   
    request.delegate=self;
    [request setDidFinishSelector:@selector(requestDone:)];
    [request setDidFailSelector:@selector(requestFaileds:)];
    [self.queue addOperation:request];
}

-(void)requestDone:(ASIHTTPRequest *)request
{
    NSDictionary * json=[request.responseData objectFromJSONData];
    NSArray * allBooks = [json objectForKey:@"entry"];
    for (NSDictionary * book in allBooks)
    {
        // model=[[BookModel alloc]init];
        //评论
        NSString * avger=[[book objectForKey:@"gd:rating"]objectForKey:@"@average"];
        // model.rating=[avger floatValue];
        NSLog(@"%f",[avger floatValue]);
        NSString * number=[[book objectForKey:@"gd:rating"]objectForKey:@"@numRaters"];
        // model.numRatings=[number intValue];
        NSLog(@"%d",[number intValue]);
        //书的名字
        NSString * titleName=[[book objectForKey:@"title"] objectForKey:@"$t"];
        NSLog(@"书的名字:  %@",titleName);
        
        //model.bookName=titleName;
        //        NSArray * authotArray=[book objectForKey:@"author"];
        //        for (NSDictionary *author in authotArray)
        //        {
        //            NSString * authorName=[[book objectForKey:@"name"] objectForKey:@"$t"];
        //            NSLog(@"作者的名字  :%@",authorName);
        //        }
        
        // NSString * categotyName=[[book objectForKey:@"category"]objectForKey:@"@scheme"];
        // NSLog(@"categoty %@",categotyName);
        
        NSArray * attribute=[book objectForKey:@"db:attribute"];
        for (NSDictionary * attributess in attribute)
        {
            NSString * attraName=[attributess objectForKey:@"@name"];
            
            if ([attraName isEqualToString:@"pubdate"])
            {
                NSString * pubdate=[attributess objectForKey:@"$t"];
                NSLog(@"pubdate %@",pubdate);
            }
            else if ([attraName isEqualToString:@"publisher"])
            {
                NSString * publisher=[attributess objectForKey:@"$t"];
                // model.publisher=publisher;
                NSLog(@"publisher %@",publisher);
            }
            else if ([attraName isEqualToString:@"price"])
            {
                NSString * price=[attributess objectForKey:@"$t"];
                NSLog(@"price %@",price);
                //价格
                // model.price=price;
            }
            else if ([attraName isEqualToString:@"author"])
            {
                NSString * author=[attributess objectForKey:@"$t"];
                NSLog(@"author %@",author);
                //作者的名字
                // model.autherName=author;
            }
            else if ([attraName isEqualToString:@"translator"])
            {
                NSString * translator=[attributess objectForKey:@"$t"];
                NSLog(@"translator %@",translator);
                //出版社
                //model.translator=translator;
            }
            
            
            
        }
        NSArray * link=[book objectForKey:@"link"];
        for (NSDictionary * image in link)
        {
            NSString * str=[image objectForKey:@"@rel"];
            if ([str isEqualToString:@"image"])
            {
                //图片
                NSString * pubdate=[image objectForKey:@"@href"];
                NSLog(@"pubdate %@",pubdate);
                //model.iconUrl=pubdate;
            }
            else if([str isEqualToString:@"mobile"])
            {
                NSString * mobile=[image objectForKey:@"@href"];
                // model.introUrl=mobile;
                NSLog(@"mobile %@",mobile);
            }
        }
        
        
        
    }
    

}
-(void)requestFaileds:(ASIHTTPRequest *)request
{
    NSLog(@"队列请求失败");
}
//创建一个ASINetWork队列请求
-(void)initWithASINetWorkQueue
{
    if (self.WorkQueue==nil)
    {
        self.WorkQueue=[[ASINetworkQueue alloc]init];
        //取消一个请求 可以设置队列
        self.WorkQueue.shouldCancelAllRequestsOnFailure=NO;
        //取消所有的请求
        //[self.WorkQueue cancelAllOperations];
        self.WorkQueue.showAccurateProgress=YES;
        self.WorkQueue.delegate=self;
        [self.WorkQueue go];
        
    }
    NSURL * url=[NSURL URLWithString:@"http://api.douban.com/book/subjects?q=%E4%B8%89&start-index=1&max-results=10&apikey=04f1ae6738f2fc450ed50b35aad8f4cf&alt=json"];
    ASIHTTPRequest * request=[[ASIHTTPRequest alloc]initWithURL:url];
    request.delegate=self;
    [self.WorkQueue addOperation:request];
}
-(void)requestStarted:(ASIHTTPRequest *)request
{
    NSLog(@"请求开始");
}
-(void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    NSLog(@"队列正在请求中");
}
/*-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"队列请求完成");
}*/
/*-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"队列请求失败");
}
*/
//使用NSThread创建多线程
-(void)initWithNSThread
{   //NSThread创建线程的两种方法
    //[NSThread detachNewThreadSelector:@selector(initWithSameRequest) toTarget:self withObject:nil];
    NSThread * mythread=[[NSThread alloc]initWithTarget:self selector:@selector(initWithSameRequest) object:nil];
    [mythread start];
    [mythread release];
}

//使用block来创建
-(void)initWithblock
{
    NSURL * url=[NSURL URLWithString:@"http://api.douban.com/book/subjects?q=%E4%B8%89&start-index=1&max-results=10&apikey=04f1ae6738f2fc450ed50b35aad8f4cf&alt=json"];
    ASIHTTPRequest * request=[ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
            //NSString *
            NSDictionary * json=[request.responseData objectFromJSONData];
            
            NSArray * allBooks = [json objectForKey:@"entry"];
            for (NSDictionary * book in allBooks)
            {
                // model=[[BookModel alloc]init];
                //评论
                NSString * avger=[[book objectForKey:@"gd:rating"]objectForKey:@"@average"];
                // model.rating=[avger floatValue];
                NSLog(@"%f",[avger floatValue]);
                NSString * number=[[book objectForKey:@"gd:rating"]objectForKey:@"@numRaters"];
                // model.numRatings=[number intValue];
                NSLog(@"%d",[number intValue]);
                //书的名字
                NSString * titleName=[[book objectForKey:@"title"] objectForKey:@"$t"];
                NSLog(@"书的名字:  %@",titleName);
                
                //model.bookName=titleName;
                //        NSArray * authotArray=[book objectForKey:@"author"];
                //        for (NSDictionary *author in authotArray)
                //        {
                //            NSString * authorName=[[book objectForKey:@"name"] objectForKey:@"$t"];
                //            NSLog(@"作者的名字  :%@",authorName);
                //        }
                
                // NSString * categotyName=[[book objectForKey:@"category"]objectForKey:@"@scheme"];
                // NSLog(@"categoty %@",categotyName);
                
                NSArray * attribute=[book objectForKey:@"db:attribute"];
                for (NSDictionary * attributess in attribute)
                {
                    NSString * attraName=[attributess objectForKey:@"@name"];
                    
                    if ([attraName isEqualToString:@"pubdate"])
                    {
                        NSString * pubdate=[attributess objectForKey:@"$t"];
                        NSLog(@"pubdate %@",pubdate);
                    }
                    else if ([attraName isEqualToString:@"publisher"])
                    {
                        NSString * publisher=[attributess objectForKey:@"$t"];
                        // model.publisher=publisher;
                        NSLog(@"publisher %@",publisher);
                    }
                    else if ([attraName isEqualToString:@"price"])
                    {
                        NSString * price=[attributess objectForKey:@"$t"];
                        NSLog(@"price %@",price);
                        //价格
                        // model.price=price;
                    }
                    else if ([attraName isEqualToString:@"author"])
                    {
                        NSString * author=[attributess objectForKey:@"$t"];
                        NSLog(@"author %@",author);
                        //作者的名字
                        // model.autherName=author;
                    }
                    else if ([attraName isEqualToString:@"translator"])
                    {
                        NSString * translator=[attributess objectForKey:@"$t"];
                        NSLog(@"translator %@",translator);
                        //出版社
                        //model.translator=translator;
                    }
                    
                    
                    
                }
                NSArray * link=[book objectForKey:@"link"];
                for (NSDictionary * image in link)
                {
                    NSString * str=[image objectForKey:@"@rel"];
                    if ([str isEqualToString:@"image"])
                    {
                        //图片
                        NSString * pubdate=[image objectForKey:@"@href"];
                        NSLog(@"pubdate %@",pubdate);
                        //model.iconUrl=pubdate;
                    }
                    else if([str isEqualToString:@"mobile"])
                    {
                        NSString * mobile=[image objectForKey:@"@href"];
                        // model.introUrl=mobile;
                        NSLog(@"mobile %@",mobile);
                    }
                }
                
                
                
            }
            
            
        
    }];
    
    [request setFailedBlock:^{
        NSError * error=[request error];
        if (error) {
            NSLog(@"请求出现错误");
        }
    }];
    
    [request startAsynchronous];
}

-(void)initWithButton
{
    UIButton * button1=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button1.frame=CGRectMake(0, 0, 80, 40);
    [button1 setTitle:@"同步请求" forState:UIControlStateNormal];
    [button1 addTarget: self action:@selector(button1) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button1];
    
    UIButton * button2=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button2.frame=CGRectMake(80, 0, 80, 40);
    [button2 setTitle:@"异步请求" forState:UIControlStateNormal];
    [button2 addTarget: self action:@selector(button2) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button2];
    
    UIButton * button3=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button3.frame=CGRectMake(160, 0, 80, 40);
    [button3 setTitle:@"GCD请求" forState:UIControlStateNormal];
    [button3 addTarget: self action:@selector(button3) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button3];
    
    UIButton * button4=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button4.frame=CGRectMake(240, 0, 80, 40);
    [button4 setTitle:@"block请求" forState:UIControlStateNormal];
    [button4 addTarget: self action:@selector(button4) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button4];
    
    UIButton * button5=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button5.frame=CGRectMake(0,40,320, 40);
    [button5 setTitle:@"图片请求" forState:UIControlStateNormal];
    [button5 addTarget: self action:@selector(button5) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button5];
}

-(void)button1
{
    [self initWithSameRequest];
//    [self Ntimes];
}
-(void)button2
{
    [self initWithDifferent];
}
-(void)button3
{
    [self initWithGCD];
}
-(void)button4
{
    [self initWithblock];
}
-(void)button5
{
    [self initWithGradeCenterDispatch];
}
- (void)viewDidLoad//#define DISPATCH_QUEUE_PRIORITY_DEFAULT 0
{
    [super viewDidLoad];
    [self initWithButton];
    //网络检查
    [self initWithReachability];
    //创建一个自动释放池
    NSAutoreleasePool * pool=[[NSAutoreleasePool alloc]init];
    //同步请求数据
    //[self initWithSameRequest];
    //异步请求数据
    //[self initWithDifferent];
    //使用GCD来创建多线程 多线程请求数据
    //[self initWithGCD];
    
    //使用NSOperation队列来创建多线程 多线程请求数据
    //[self initWithQueue];
    
    /*ASINetwork队列请求 使用ASINetwork来创建多现层 多线程请求数据*/
    //[self initWithASINetWorkQueue];
    
    //使用NSThread来创建多线程 用来请求数据
    //[self initWithNSThread];
    
    //使用NSObject来生成一个线程
    //[self performSelectorInBackground:@selector(initWithSameRequest) withObject:nil];
    //[self initWithblock];
    NSLog(@"hello world");
    [pool release];
    UIImageView * image=[[UIImageView alloc]initWithFrame:CGRectMake(0, 80, 320, 380)];
    [self.view addSubview:image];
    self.imageView=image;
   
}




//数据下载完后我门可以通过//[self performSelectorOnMainThread:@selector(updateUI:) withObject:image waitUntilDone:YES];来通知主线程更新

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
