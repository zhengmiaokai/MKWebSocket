//
//  GCDSemaphore.h
//  Basic
//
//  Created by zhengmiaokai on 2018/8/13.
//  Copyright © 2018年 zhengmiaokai. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 ** 信号量为：0; wait-signal：把异步操作转为同步操作
 ** 信号量为：1、2...设置线程最多的执行数量
 **/

@interface GCDSemaphore : NSObject

+ (instancetype)semaphoreWithValue:(long)value;

+ (instancetype)semaphore;

- (void)wait;

- (void)signal;

@end

/* 示例
 --------------------------------------------------------------
 GCDSemaphore *semaphore = [GCDSemaphore semaphoreWithValue:0];
 [GCDQueue asyncGlobal:^{
     // do something
     [semaphore signal];
 }];
 [semaphore wait];
 // continue after signal
 --------------------------------------------------------------
 */
