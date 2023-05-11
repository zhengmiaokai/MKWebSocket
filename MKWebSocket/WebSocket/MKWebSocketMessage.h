//
//  MKWebSocketMessage.h
//  MKWebSocket
//
//  Created by zhengmiaokai on 2021/6/22.
//  Copyright © 2021年 zhengmiaokai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKWMesssagePackage.h"

@interface MKWebSocketMessage : NSObject

/// 原始数据
@property (nonatomic, strong) id message;

/// 消息模型
@property (nonatomic, strong) MKWReceivePackage *model;

+ (instancetype)modelWithMessage:(id)message;

@end
