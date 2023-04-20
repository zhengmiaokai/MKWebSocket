//
//  MKWSBaseModule.h
//  MKWebSocket
//
//  Created by zhengMK on 2021/6/23.
//  Copyright © 2021 zhengmiaokai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKWebSocktDelegate.h"

/* 添加对应的业务处理 */

@interface MKWebSocketBaseModule : NSObject <MKWebSocketClientDelegate>

/// 遍历获取delegate
- (void)enumerateDelegate:(void(^)(id <MKWebSocketClientDelegate> delegate))enumerateHandler;
- (void)enumerateDelegate:(void(^)(id <MKWebSocketClientDelegate> delegate))enumerateHandler onMainThread:(BOOL)onMainThread;

- (void)addDelegate:(id<MKWebSocketClientDelegate>)delegate;
- (void)removeDelegate:(id<MKWebSocketClientDelegate>)delegate;

@end
