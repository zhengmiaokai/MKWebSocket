//
//  GCDQueue.h
//  Basic
//
//  Created by zhengmiaokai on 2018/8/13.
//  Copyright © 2018年 zhengmiaokai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDQueue : NSObject

+ (void)asyncQueue:(dispatch_queue_t)queue block:(void(^)(void))block;

+ (void)asyncGlobal:(void(^)(void))block;

+ (void)asyncMain:(void(^)(void))block;

+ (void)delay:(void(^)(void))block timeInterval:(NSTimeInterval)timeInterval;

@end
