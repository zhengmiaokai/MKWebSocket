//
//  MKWebSocketMessage.h
//  MKWebSocket
//
//  Created by zhengmiaokai on 2021/6/22.
//  Copyright © 2021年 zhengmiaokai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKWebSocketMessage : NSObject

@property (nonatomic, strong) id message;

+ (instancetype)modelWithMessage:(id)message;

@end
