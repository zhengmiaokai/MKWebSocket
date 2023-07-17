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

+ (instancetype)semaphoreWithValue:(long)value {
    GCDSemaphore* instance = [[GCDSemaphore alloc] init];
    instance.semaphore = dispatch_semaphore_create(value);
    return instance;
}

+ (instancetype)semaphore {
    GCDSemaphore* semaphore = [GCDSemaphore semaphoreWithValue:1];
    return semaphore;
}

- (void)wait {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
}

- (void)signal {
    dispatch_semaphore_signal(_semaphore);
}

@end
