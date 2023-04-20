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
        self.delegateOnMainQueue = YES;
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

- (void)enumerateDelegate:(void(^)(id <MKWebSocketClientDelegate> delegate))enumerateHandler {
    [MKWebSocketUitls performOnMainThread:^{
        NSDictionary* delegateItems = [self getDelegateItems];
        [delegateItems enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, MKDelegateItem *delegateItem, BOOL * _Nonnull stop) {
            if (enumerateHandler) {
                enumerateHandler(delegateItem.delegate);
            }
        }];
    } available:_delegateOnMainQueue];
}

- (void)addDelegate:(id<MKWebSocketClientDelegate>)delegate {
    @synchronized (self) {
        MKDelegateItem* delegateItem = [[MKDelegateItem alloc] initWithDelegate:delegate];
        [self.delegateItems setValue:delegateItem forKey:delegateItem.delegateTag];
    }
}

- (void)removeDelegate:(id <MKWebSocketClientDelegate>)delegate {
    @synchronized (self) {
        [_delegateItems removeObjectForKey:[MKWebSocketUitls generateTag:delegate]];
    }
}

#pragma mark -- MKWebSocketClientDelegate --
- (void)webSocketClient:(id)webSocketClient didReceiveMessage:(id)message {
    [MKWebSocketUitls performOnMainThread:^{
        NSDictionary* delegateItems = [self getDelegateItems];
        for (NSString* key in delegateItems) {
            MKDelegateItem* obj = [delegateItems objectForKey:key];
            if ([obj.delegate respondsToSelector:@selector(webSocketClient:didReceiveMessage:)]) {
                [obj.delegate webSocketClient:self didReceiveMessage:message];
            }
        }
    } available:_delegateOnMainQueue];
}

- (void)webSocketClient:(id)webSocketClient didSendMessage:(id)message {
    [MKWebSocketUitls performOnMainThread:^{
        NSDictionary* delegateItems = [self getDelegateItems];
        for (NSString* key in delegateItems) {
            MKDelegateItem* obj = [delegateItems objectForKey:key];
            if ([obj.delegate respondsToSelector:@selector(webSocketClient:didReceiveMessage:)]) {
                [obj.delegate webSocketClient:self didSendMessage:message];
            }
        }
    } available:_delegateOnMainQueue];
}

- (void)webSocketClient:(id)webSocketClient didReciveStatusChanged:(MKWebSocketStatus)status {
    [MKWebSocketUitls performOnMainThread:^{
        NSDictionary* delegateItems = [self getDelegateItems];
        for (NSString* key in delegateItems) {
            MKDelegateItem* obj = [delegateItems objectForKey:key];
            if ([obj.delegate respondsToSelector:@selector(webSocketClient:didReciveStatusChanged:)]) {
                [obj.delegate webSocketClient:self didReciveStatusChanged:status];
            }
        }
    } available:_delegateOnMainQueue];
}

@end
