//
//  MKWebSocketMessage.m
//  MKWebSocket
//
//  Created by zhengmiaokai on 2021/6/22.
//  Copyright © 2021年 zhengmiaokai. All rights reserved.
//

#import "MKWebSocketMessage.h"

@implementation MKWebSocketMessage

+ (instancetype)modelWithMessage:(id)message {
    MKWebSocketMessage* item = [[MKWebSocketMessage alloc] init];
    item.message = message;
    return item;
}

@end
