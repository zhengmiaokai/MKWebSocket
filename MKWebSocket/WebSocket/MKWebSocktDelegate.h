//
//  MKDelegateItem.h
//  MKWebSocket
//
//  Created by mikazheng on 2021/6/21.
//  Copyright © 2021 zhengmiaokai. All rights reserved.
//

#import "SocketRocket.h"

extern NSString * const LCWebSocketDidOpenNotification;
extern NSString * const LCWebSocketDidCloseNotification;
extern NSString * const LCWebSocketDidFailNotification;
extern NSString * const LCWebSocketDidReciveNotification;

typedef NS_ENUM(NSInteger, MKWebSocketStatus) {
    MKWebSocketStatusOpen           = 1,  /// 连接成功
    MKWebSocketStatusClose          = 2,  /// 断开连接
    MKWebSocketStatusConnecting     = 3,  /// 连接中
};

@protocol MKWebSocketClientDelegate <NSObject>

@required
- (void)webSocketClient:(id)webSocketClient didReceiveMessage:(id)message;

@optional
- (void)webSocketClient:(id)webSocketClient didSendMessage:(id)message;
- (void)webSocketClient:(id)webSocketClient didReciveStatusChanged:(MKWebSocketStatus)status;

@end


@interface MKDelegateItem : NSObject

@property (nonatomic, weak) id <MKWebSocketClientDelegate> delegate;
@property (nonatomic, copy, readonly)  NSString* delegateTag;

- (instancetype)initWithDelegate:(id<MKWebSocketClientDelegate>)delegate;

@end
