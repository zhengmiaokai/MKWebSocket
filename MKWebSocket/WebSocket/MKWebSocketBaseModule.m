//
//  MKWSBaseModule.m
//  MKWebSocket
//
//  Created by zhengMK on 2021/6/23.
//  Copyright © 2021 zhengmiaokai. All rights reserved.
//

#import "MKWebSocketBaseModule.h"

@interface MKWebSocketBaseModule ()

@property (nonatomic, strong) NSMutableDictionary* delegateItems;
@property (nonatomic, strong) NSRecursiveLock* lock;

@end

@implementation MKWebSocketBaseModule

- (instancetype)init {
    self = [super init];
    if (self) {
        self.delegateItems = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSDictionary *)getDelegateItems {
    NSDictionary* delegateItems = nil;
    @synchronized (self) {
       delegateItems = [_delegateItems copy];
    }
    return delegateItems;
}

- (void)addDelegate:(id<MKWebSocketClientDelegate>)delegate {
    @synchronized (self) {
        MKDelegateItem* delegateItem = [[MKDelegateItem alloc] initWithDelegate:delegate];
        [self.delegateItems setValue:delegateItem forKey:[NSString stringWithFormat:@"%p",delegate]];
    }
}

- (void)removeDelegate:(id<MKWebSocketClientDelegate>)delegate {
    @synchronized (self) {
        [_delegateItems removeObjectForKey:[NSString stringWithFormat:@"%p",delegate]];
    }
}

#pragma mark -- MKWebSocketClientDelegate --
- (void)webSocketClient:(id)webSocketClient didReceiveMessage:(id)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary* delegateItems = [self getDelegateItems];
        for (NSString* key in delegateItems) {
            MKDelegateItem* obj = [delegateItems objectForKey:key];
            if ([obj.delegate respondsToSelector:@selector(webSocketClient:didReceiveMessage:)]) {
                [obj.delegate webSocketClient:self didReceiveMessage:message];
            }
        }
    });
}

- (void)webSocketClient:(id)webSocketClient didSendMessage:(id)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary* delegateItems = [self getDelegateItems];
        for (NSString* key in delegateItems) {
            MKDelegateItem* obj = [delegateItems objectForKey:key];
            if ([obj.delegate respondsToSelector:@selector(webSocketClient:didReceiveMessage:)]) {
                [obj.delegate webSocketClient:self didSendMessage:message];
            }
        }
    });
}

- (void)webSocketClient:(id)webSocketClient didReciveStatusChanged:(MKWebSocketStatus)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary* delegateItems = [self getDelegateItems];
        for (NSString* key in delegateItems) {
            MKDelegateItem* obj = [delegateItems objectForKey:key];
            if ([obj.delegate respondsToSelector:@selector(webSocketClient:didReciveStatusChanged:)]) {
                [obj.delegate webSocketClient:self didReciveStatusChanged:status];
            }
        }
    });
}

@end
