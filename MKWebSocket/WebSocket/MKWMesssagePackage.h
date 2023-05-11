//
//  MKWMesssagePackage.h
//  MKWebSocket
//
//  Created by zhengmiaokai on 2021/11/15.
//

#import <Foundation/Foundation.h>

@interface MKWSendPackage : NSObject

@property (nonatomic, copy) NSString *msgType;  // 消息类型，'ACK' 消息回包、'ASK' 数据请求、可扩展...
@property (nonatomic, copy) NSString *source;   // 消息来源，'CLIENT' 客户端
@property (nonatomic, copy) NSDictionary *payload;   // 消息负载
@property (nonatomic, assign) NSTimeInterval timeInterval;   // 时间戳(毫秒)

/// ACK消息体
+ (NSString *)ackWithPayload:(NSDictionary *)payload;

/// ASK消息体
+ (NSString *)askWithPayload:(NSDictionary *)payload;

@end

@interface MKWReceivePackage : NSObject

@property (nonatomic, copy) NSString *msgId;    // 消息id
@property (nonatomic, copy) NSString *msgType;  // 消息类型，'ANSWER' 数据响应、'PUSH' 信息推送、可扩展...
@property (nonatomic, copy) NSString *source;   // 消息来源，'SERVER' 服务端
@property (nonatomic, copy) NSDictionary *payload;   // 消息负载
@property (nonatomic, assign) NSTimeInterval timeInterval;   // 时间戳(毫秒)

@end
