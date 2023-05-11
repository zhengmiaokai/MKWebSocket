//
//  MKDelegateItem.m
//  MKWebSocket
//
//  Created by zhengmiaokai on 2021/6/21.
//  Copyright © 2021 zhengmiaokai. All rights reserved.
//

#import "MKWebSocktDelegate.h"

NSString * const MKWebSocketDidOpenNotification = @"webSocketDidOpenNotification";
NSString * const MKWebSocketDidCloseNotification = @"webSocketDidCloseNotification";
NSString * const MKWebSocketDidFailNotification = @"webSocketDidFailNotification";
NSString * const MKWebSocketDidReciveNotification = @"webSocketDidReciveNotification";

NSString * const MKWebSocketPingNotification = @"webSocketPingNotification";

@implementation MKDelegateItem

- (instancetype)initWithDelegate:(id <MKWebSocketClientDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        _delegateTag = [MKWebSocketUitls generateTag:delegate];
    }
    return self;
}

@end


@implementation MKWebSocketUitls

+ (NSString *)generateTag:(id <MKWebSocketClientDelegate>)delegate {
    return [NSString stringWithFormat:@"MKWebSockt-%p", delegate];
}

+ (void)performOnMainThread:(void(^)(void))block available:(BOOL)available {
    if (!block) return;
    
    if (!available) {
        block();
    } else {
        if ([NSThread isMainThread]) {
            block();
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block();
            });
        }
    }
}

@end
