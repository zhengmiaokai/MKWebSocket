//
//  MKWebSocketClient.m
//  MKWebSocket
//
//  Created by zhengmiaokai on 2021/6/21.
//  Copyright © 2021年 zhengmiaokai. All rights reserved.
//

#import "MKWebSocketClient.h"
#import <AFNetworking/AFNetworking.h>
#import "NSDate+Additions.h"
#import "GCDConstant.h"
#import "MKWebSocketMessage.h"

/* websocket在线测试：http://coolaf.com/tool/chattest */
static NSString * const kWebSocketURLString = @"ws://82.157.123.54:9010/ajaxchattest";

#define MAX_REPEAT_CONNECT_NUMBER         2   // 失败立即重连次数
#define REPEAT_CONNECT_INTERVAL           3   // 失败立即重连间隔
#define MAX_SOCKET_PING_NUMBER            1   // Ping-Pong异常次数
#define SOCKET_PING_TIME_INTERVAL        15   // Ping心跳间隔
#define SOCKET_FAIL_RECONNECT_INTERVAL   30   // 链接心跳间隔

@interface MKWebSocketClient () <SRWebSocketDelegate> {
    NSRecursiveLock* _lock;
    GCDSemaphore* _semaphore;
    NSMutableDictionary* _modules;
    
    BOOL _isFirstTime;   // 是否为首次连接
    BOOL _isActiveClose; // 是否为主动关闭
}

@property (nonatomic, strong) GCDSource* conntectTimer; // 链接心跳定时
@property (nonatomic, strong) GCDSource* pingTimer; // ping心跳定时
@property (nonatomic, strong) SRWebSocket* webSocket;

@property (nonatomic, strong) NSMutableDictionary* delegateItems;

@property (nonatomic, assign) BOOL isConnecting; // 正在连接-状态标记
@property (nonatomic, assign) NSUInteger reConnectCount; // 已重连次数
@property (nonatomic, assign) NSUInteger pingMQ; // 没有被消费的心跳MQ （ping: +1, pong: -1）

@property (nonatomic, assign) AFNetworkReachabilityStatus reachabilityStatus; // 网络状态

@end

@implementation MKWebSocketClient

+ (instancetype)sharedInstance {
    static MKWebSocketClient* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _pingDatas = [[NSMutableArray alloc] init];
        
        self.isConnecting = NO;
        self.reConnectCount = 0;
        self.delegateItems = [[NSMutableDictionary alloc] init];
        
        _modules = [[NSMutableDictionary alloc] init];
        _lock = [[NSRecursiveLock alloc] init];
        _semaphore = [GCDSemaphore semaphore];
        
        _isFirstTime = YES;
        _isActiveClose = NO;
        
        [self upgradeNetworkStatus];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [self reConnect];
            [self.conntectTimer resumeTimer];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [self.conntectTimer pauseTimer];
        }];
    }
    return self;
}

/// 更新网络状态
- (void)upgradeNetworkStatus {
    __weak typeof(self) weakSelf = self;
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (status == AFNetworkReachabilityStatusUnknown || status == AFNetworkReachabilityStatusNotReachable) {
            NSLog(@"网络不可用");
            strongSelf.reachabilityStatus = AFNetworkReachabilityStatusNotReachable;
        } else {
            NSLog(@"网络可用");
            strongSelf.reachabilityStatus = AFNetworkReachabilityStatusReachableViaWWAN;
            [strongSelf reConnect];
        }
    }];
    [manager startMonitoring];
}

#pragma mark - instance -
- (SRWebSocket *)webSocket {
    if (!_serverRequest && (!_serverLink || !_serverLink.length)) {
        NSLog(@"serverURL is invalid");
        return nil;
    }
    
    if (_webSocket == nil) {
        if (_serverRequest) {
            _webSocket = [[SRWebSocket alloc] initWithURLRequest:_serverRequest];
        } else {
            _webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:_serverLink]];
        }
        dispatch_queue_t dispatchQueue = dispatch_queue_create("com.webSocket.dispatchQueue", DISPATCH_QUEUE_SERIAL);
        [_webSocket setDelegateDispatchQueue:dispatchQueue];
        _webSocket.delegate = self;
    }
    return _webSocket;
}

/// 销毁socket
- (void)destroySocket:(BOOL)isClosed {
    if (_webSocket) {
        _webSocket.delegate = nil;
        if (!isClosed) {
            [_webSocket close];
        }
        self.webSocket = nil;
    }
}

/// 销毁PingTimer
- (void)destroyPingTimer {
    if (_pingTimer) {
        [_pingTimer stopTimer];
        self.pingTimer = nil;
    }
    self.pingMQ = 0;
}

/// 销毁conntectTimer
- (void)destroyConntectTimer {
    if (_conntectTimer) {
        [_conntectTimer stopTimer];
        self.conntectTimer = nil;
    }
}

#pragma mark - 连接 & 断开 -
- (void)connect {
    _isFirstTime = NO;
    _isActiveClose = NO;
    [self _open];

    /// 链接心跳包
    __weak typeof(self) weakSelf = self;
    self.conntectTimer = [[GCDSource alloc] initWithTimeInterval:SOCKET_FAIL_RECONNECT_INTERVAL repeats:YES timerBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf reConnect];
    }];
}

- (void)reConnect {
    if (_webSocket.readyState == SR_OPEN || _isConnecting == YES) {
        NSLog(@"webSocket is open or connecting");
    } else {
        if (_isFirstTime == NO && _isActiveClose == NO) {
            [self _open];
        }
    }
}

- (void)disconnect {
    _isActiveClose = YES;
    
    [_webSocket close];
    [self destroyConntectTimer];
}

// 连接（重连前先 销毁已有的websocket）
- (void)_open {
    [self destroySocket:_webSocket.readyState == SR_CLOSED];
    [self destroyPingTimer];
    
    self.isConnecting = YES;
    [self didReciveStatusChanged:MKWebSocketStatusConnecting];
    [self.webSocket open];
}

#pragma mark - sendData -
- (void)sendMessage:(NSString *)data {
    if (_webSocket.readyState == SR_OPEN) {
        [_webSocket send:data];
        [self didSendMessage:data];
    }
}

- (void)sendData:(NSString *)data {
    if (_webSocket.readyState == SR_OPEN) {
        [_webSocket send:data];
    }
}

/// Ping心跳包校验，超过时长：MAX_SOCKET_PING_NUMBER * SOCKET_PING_TIME_INTERVAL 秒
- (void)sendPing:(NSData *)data {
    if (_pingMQ >= MAX_SOCKET_PING_NUMBER) {
        [self _open];
        NSLog(@"client发出心跳包，server无响应");
    }
    
    if (_webSocket.readyState == SR_OPEN) {
        if (!data) {
            data = [@"SocketTag" dataUsingEncoding:NSASCIIStringEncoding];
        }
        [_webSocket sendPing:data];
        self.pingMQ++;
    }
}

#pragma mark - 代理扩展 -
- (NSDictionary *)getDelegateItems {
    NSDictionary* delegateItems = nil;
    [_semaphore wait];
    delegateItems = [_delegateItems copy];
    [_semaphore signal];
    return delegateItems;
}

- (void)addDelegate:(id <MKWebSocketClientDelegate>)delegate {
    MKDelegateItem* delegateItem = [[MKDelegateItem alloc] initWithDelegate:delegate];
    [_semaphore wait];
    [self.delegateItems setValue:delegateItem forKey:delegateItem.delegateTag];
    [_semaphore signal];
}

- (void)removeDelegate:(id <MKWebSocketClientDelegate>)delegate {
    [_semaphore wait];
    [self.delegateItems removeObjectForKey:[MKWebSocketUitls generateTag:delegate]];
    [_semaphore signal];
}

- (id)socketModule:(NSString *)cls {
    [_lock lock];
    id module = [_modules objectForKey:cls];
    if (module == nil) {
        Class moduleCls = NSClassFromString(cls);
        if (![moduleCls conformsToProtocol:@protocol(MKWebSocketClientDelegate)]) {
            return nil;
        }
        module = [[moduleCls alloc] init];
        [self addDelegate:module];
        [_modules setObject:module forKey:cls];
    }
    [_lock unlock];
    
    return module;
}

- (void)removeSocketModule:(NSString*)cls {
    if (cls.length <= 0) return;
    
    [_lock lock];
    id module = [_modules objectForKey:cls];
    [self removeDelegate:module];
    [_modules removeObjectForKey:cls];
    [_lock unlock];
}

- (void)didSendMessage:(NSString *)data {
    MKWebSocketMessage* messageItem = [MKWebSocketMessage modelWithMessage:data];
    NSDictionary* delegateItems = [self getDelegateItems];
    for (NSString* key in delegateItems) {
        MKDelegateItem* obj = [delegateItems objectForKey:key];
        if ([obj.delegate respondsToSelector:@selector(webSocketClient:didSendMessage:)]) {
            [obj.delegate webSocketClient:self didSendMessage:messageItem];
        }
    }
}

- (void)didReciveStatusChanged:(MKWebSocketStatus)status {
    NSDictionary* delegateItems = [self getDelegateItems];
    for (NSString* key in delegateItems) {
        MKDelegateItem* obj = [delegateItems objectForKey:key];
        if ([obj.delegate respondsToSelector:@selector(webSocketClient:didReciveStatusChanged:)]) {
            [obj.delegate webSocketClient:self didReciveStatusChanged:status];
        }
    }
}

- (void)didReceiveMessage:(id)message {
    MKWebSocketMessage* messageItem = [MKWebSocketMessage modelWithMessage:message];
    NSDictionary* delegateItems = [self getDelegateItems];
    for (NSString* key in delegateItems) {
        MKDelegateItem* obj = [delegateItems objectForKey:key];
        if ([obj.delegate respondsToSelector:@selector(webSocketClient:didReceiveMessage:)]) {
            [obj.delegate webSocketClient:self didReceiveMessage:messageItem];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MKWebSocketDidReciveNotification object:messageItem];
}

#pragma mark -- MKWebSocketDelegate --
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    [self didReceiveMessage:message];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    self.isConnecting = NO;
    self.reConnectCount = 0;
    
    // ping心跳包，防止服务端杀死
    __weak typeof(self) weakSelf = self;
    self.pingTimer = [[GCDSource alloc] initWithTimeInterval:SOCKET_PING_TIME_INTERVAL repeats:YES timerBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf sendPing:nil];
    }];
    
    // 状态更新
    [self didReciveStatusChanged:MKWebSocketStatusOpen];
    [[NSNotificationCenter defaultCenter] postNotificationName:MKWebSocketDidOpenNotification object:nil];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    self.isConnecting = NO;
    
    // 断开重连，重连失败再走下方代理
    if (self.reConnectCount < MAX_REPEAT_CONNECT_NUMBER && self.reachabilityStatus ==AFNetworkReachabilityStatusReachableViaWWAN) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(REPEAT_CONNECT_INTERVAL * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 延后重连，避免服务短时间无响应
            [self _open];
        });
        self.reConnectCount ++;
    } else {
        [self destroySocket:webSocket.readyState == SR_CLOSED];
        [self destroyPingTimer];
        
        self.reConnectCount = 0;
        [self didReciveStatusChanged:MKWebSocketStatusClose];
        [[NSNotificationCenter defaultCenter] postNotificationName:MKWebSocketDidFailNotification object:error];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    self.isConnecting = NO;
    [self didReciveStatusChanged:MKWebSocketStatusClose];
    
    if (code == SRStatusCodeGoingAway || code == SRStatusCodeNormal) {
        // 主动断开后销毁 Socket & Timer
        [self destroySocket:webSocket.readyState == SR_CLOSED];
        [self destroyPingTimer];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:MKWebSocketDidCloseNotification object:@{@"code": @(code), @"reason": (reason?reason:@"")}];
    } else {
        // 非主动断开，重新连接 （SRStatusCodeTryAgainLater、SRStatusCodeServiceRestart等状态）
        if (self.reachabilityStatus ==AFNetworkReachabilityStatusReachableViaWWAN) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(REPEAT_CONNECT_INTERVAL * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 延后重连
                [self _open];
            });
        } else {
            [self destroySocket:webSocket.readyState == SR_CLOSED];
            [self destroyPingTimer];
        }
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSString* pongTag = [[NSString alloc] initWithData:pongPayload encoding:NSASCIIStringEncoding];
    if ([pongTag isEqualToString:@"SocketTag"]) {
        self.pingMQ = 0; /// 归零，链路正常
        
        [self addWSLogInfo:@"接收到server返回的pong"];
    }
}

- (BOOL)webSocketShouldConvertTextFrameToString:(SRWebSocket *)webSocket {
    return YES;
}

#pragma mark - LogInfo -
- (void)addWSLogInfo:(NSString *)logInfo {
    NSLog(@"%@", logInfo);
    
    NSString* homeTime = [NSDate dateToString:[NSDate date] withDateFormat:@"HH:mm:ss"];
    [self.pingDatas insertObject:[NSString stringWithFormat:@"%@: %@", homeTime, logInfo] atIndex:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:MKWebSocketPingNotification object:nil];
}

@end
