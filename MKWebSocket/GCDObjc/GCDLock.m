//
//  GCDLock.m
//  Basic
//
//  Created by zhengmiaokai on 2018/8/14.
//  Copyright © 2018年 zhengmiaokai. All rights reserved.
//

#import "GCDLock.h"

@interface GCDLock ()

@property (nonatomic, strong) dispatch_queue_t serialQueue;

@end

@implementation GCDLock

- (instancetype)init {
    self = [super init];
    if (self) {
        self.serialQueue = dispatch_queue_create("GCD_SERIAL_QUEUE", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)lock:(void(^)(void))block {
    dispatch_sync(_serialQueue,block);
}

@end
