//
//  MKDelegateItem.h
//  MKWebSocket
//
//  Created by zhengmiaokai on 2021/6/21.
//  Copyright © 2021 zhengmiaokai. All rights reserved.
//

#import "SocketRocket.h"

extern NSString * const MKWebSocketDidOpenNotification;
extern NSString * const MKWebSocketDidCloseNotification;
extern NSString * const MKWebSocketDidFailNotification;
extern NSString * const MKWebSocketDidReciveNotification;

extern NSString * const MKWebSocketPingNotification;

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
@property (nonatomic, copy, readonly) NSString* delegateTag;

- (instancetype)initWithDelegate:(id<MKWebSocketClientDelegate>)delegate;

@end


@interface MKWebSocketUitls: NSObject

+ (NSString *)generateTag:(id <MKWebSocketClientDelegate>)delegate;

+ (void)performOnMainThread:(void(^)(void))block available:(BOOL)available;

@end
