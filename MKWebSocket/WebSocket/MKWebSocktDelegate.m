//
//  MKDelegateItem.m
//  MKWebSocket
//
//  Created by mikazheng on 2021/6/21.
//  Copyright © 2021 zhengmiaokai. All rights reserved.
//

#import "MKWebSocktDelegate.h"

NSString * const LCWebSocketDidOpenNotification = @"webSocketDidOpenNotification";
NSString * const LCWebSocketDidCloseNotification = @"webSocketDidCloseNotification";
NSString * const LCWebSocketDidFailNotification = @"webSocketDidFailNotification";
NSString * const LCWebSocketDidReciveNotification = @"webSocketDidReciveNotification";

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
