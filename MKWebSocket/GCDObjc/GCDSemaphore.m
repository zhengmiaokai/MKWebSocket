//
//  GCDSemaphore.m
//  Basic
//
//  Created by zhengmiaokai on 2018/8/13.
//  Copyright © 2018年 zhengmiaokai. All rights reserved.
//

#import "GCDSemaphore.h"

@interface GCDSemaphore ()

@property (nonatomic) dispatch_semaphore_t semaphore;

@end

@implementation GCDSemaphore

- (instancetype)initWithValue:(long)value {
    self = [super init];
    if (self) {
        self.semaphore = dispatch_semaphore_create(value);
    }
    return self;
}

+ (instancetype)semaphore {
    GCDSemaphore* semaphore = [[GCDSemaphore alloc] initWithValue:1];
    return semaphore;
}

- (void)wait {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
}

- (void)signal {
    dispatch_semaphore_signal(_semaphore);
}

@end

/*用法
 -------------------------------------------------
 dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
 dispatch_queue_t quene = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
 
 //任务1
 dispatch_async(quene, ^{
      dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
      NSLog(@"run task 1");
      sleep(1);
      NSLog(@"complete task 1");
      dispatch_semaphore_signal(semaphore);
 });
 //任务2
 dispatch_async(quene, ^{
      dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
      NSLog(@"run task 2");
      sleep(1);
      NSLog(@"complete task 2");
      dispatch_semaphore_signal(semaphore);
 });
 //任务3
 dispatch_async(quene, ^{
      dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
      NSLog(@"run task 3");
      sleep(1);
      NSLog(@"complete task 3");
      dispatch_semaphore_signal(semaphore);
 });
 -------------------------------------------------
 dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
 dispatch_async(dispatch_get_global_queue(0, 0), ^{
      sleep(1);
      dispatch_semaphore_signal(sem);
 });
 dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
 //阻塞线程，直到signal的调用
 -------------------------------------------------
 */
