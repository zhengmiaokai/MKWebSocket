//
//  MKDelegateItem.m
//  MKWebSocket
//
//  Created by mikazheng on 2021/6/21.
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
        _delegateTag = [NSString stringWithFormat: @"%p", delegate];
    }
    return self;
}

@end
