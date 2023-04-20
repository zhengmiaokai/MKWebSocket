//
//  MKTestModule.m
//  Merchant
//
//  Created by mikazheng on 2021/7/12.
//

#import "MKTestModule.h"
#import "MKWebSocketMessage.h"

@implementation MKTestModule

- (void)webSocketClient:(id)webSocketClient didReceiveMessage:(MKWebSocketMessage *)message {
    NSDictionary* data = @{@"type": @"5"};
    NSString* type = [data objectForKey:@"type"];
    if (type.intValue == 7) {
        [self enumerateDelegate:^(id<MKWebSocketClientDelegate> delegate) {
            if ([delegate respondsToSelector:@selector(refreshOrder:)]) {
                [(id <MKTestModuleProtocol>)delegate refreshOrder:message];
            }
        }];
        
    } else {
        [super webSocketClient:webSocketClient didReceiveMessage:message];
    }
}

@end
