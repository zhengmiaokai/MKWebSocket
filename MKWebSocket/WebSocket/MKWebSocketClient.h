//
//  MKWebSocketClient.h
//  MKWebSocket
//
//  Created by zhengmiaokai on 2021/6/21.
//  Copyright © 2021年 zhengmiaokai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SocketRocket.h>
#import "MKWebSocktDelegate.h"

@interface MKWebSocketClient : NSObject

// 用于确认ping-pong是否正常，属于测试数据
@property (nonatomic, strong, readonly) NSMutableArray* pingDatas;

@property (nonatomic, copy) NSString* serverLink;
@property (nonatomic, strong) NSURLRequest* serverRequest;

+ (instancetype)sharedInstance;

- (void)connect;
- (void)reConnect;
- (void)disconnect;

- (void)sendData:(NSString *)data;
- (void)sendMessage:(NSString *)data;

- (NSString *)addDelegate:(id<MKWebSocketClientDelegate>)delegate;
- (void)removeDelegateWithTag:(NSString *)tag;

#pragma mark - 模块化扩展（聊天、系统消息等） -
- (id)socketModule:(NSString *)cls;
- (void)removeSocketModule:(NSString*)cls;

@end

#define SOCKET_MODULE(cls)         ((cls*)[[MKWebSocketClient sharedInstance] socketModule:@#cls])
#define REMOVE_SOCKET_MODULE(cls)  [[MKWebSocketClient sharedInstance] removeSocketModule:@#cls]
