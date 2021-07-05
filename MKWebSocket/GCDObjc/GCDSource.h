//
//  GCDSource.h
//  Basic
//
//  Created by mikazheng on 2019/7/19.
//  Copyright © 2019 zhengmiaokai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GCDSource : NSObject

- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval repeats:(BOOL)repeats timerBlock:(void(^)(void))timerBlock;

- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval repeats:(BOOL)repeats timerBlock:(void(^)(void))timerBlock timerQueue:(dispatch_queue_t)timerQueue blockQueue:(dispatch_queue_t)blockQueue;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (void)pauseTimer;

- (void)resumeTimer;

- (void)stopTimer;

@end

NS_ASSUME_NONNULL_END

/*
self.source = [[GCDSource alloc] initWithTimeInterval:3 repeats:YES timerBlock:^{
    
}];

[_source pauseTimer];
[_source resumeTimer];
[_source stopTimer];
 */
