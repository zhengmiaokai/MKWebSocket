//
//  GCDSource.m
//  Basic
//
//  Created by mikazheng on 2019/7/19.
//  Copyright © 2019 zhengmiaokai. All rights reserved.
//

#import "GCDSource.h"

@interface GCDSource () {
    BOOL _repeats;
    NSTimeInterval _timeInterval;
    BOOL _isSuspend; // 是否挂起
    NSRecursiveLock* _lock;
}

@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, strong) dispatch_queue_t timerQueue;
@property (nonatomic, strong) dispatch_queue_t blockQueue;

@property (nonatomic, copy) void(^timerBlock)(void);

@end

@implementation GCDSource

- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval repeats:(BOOL)repeats timerBlock:(void(^)(void))timerBlock timerQueue:(dispatch_queue_t)timerQueue blockQueue:(dispatch_queue_t)blockQueue {
    self = [super init];
    if (self) {
        _timeInterval = timeInterval;
        _repeats = repeats;
        
        self.timerBlock = timerBlock;
        self.timerQueue = timerQueue;
        self.blockQueue = blockQueue;
        
        [self initTimer];
    }
    return self;
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval repeats:(BOOL)repeats timerBlock:(void(^)(void))timerBlock {
    self = [super init];
    if (self) {
        _timeInterval = timeInterval;
        _repeats = repeats;
        self.timerBlock = timerBlock;
        
        [self initTimer];
    }
    return self;
}

- (void)initTimer {
    dispatch_queue_t timerQueue = self.timerQueue ? self.timerQueue : dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t blockQueue = self.blockQueue ? self.blockQueue : dispatch_get_main_queue();
    
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, timerQueue);
    
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), _timeInterval * NSEC_PER_SEC,  0);
    dispatch_source_set_event_handler(_timer, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(blockQueue, ^{
            strongSelf.timerBlock();
        });
        if (strongSelf->_repeats == NO) {
            [strongSelf stopTimer];
        }
    });
    dispatch_resume(_timer);
    _isSuspend = NO;
}

- (void)pauseTimer {
    [_lock lock];
    if(self.timer && _isSuspend == NO){
        dispatch_suspend(_timer);
        _isSuspend = YES;
    }
    [_lock unlock];
}

- (void)resumeTimer {
    [_lock lock];
    if(self.timer && _isSuspend == YES){
        dispatch_resume(_timer);
        _isSuspend = NO;
    }
    [_lock unlock];
}

- (void)stopTimer {
    [_lock lock];
    if(self.timer){
        if (_isSuspend == YES) {
            [self resumeTimer];
        }
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
    [_lock unlock];
}

- (void)dealloc {
    [self stopTimer];
}

@end
