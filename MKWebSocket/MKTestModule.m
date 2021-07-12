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
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSString* key in self.delegateItems) {
                MKDelegateItem* obj = [self.delegateItems objectForKey:key];
                if ([obj.delegate respondsToSelector:@selector(refreshOrder:)]) {
                    [(id <MKTestModuleProtocol>)obj.delegate refreshOrder:message];
                }
            }
        });
    } else {
        [super webSocketClient:webSocketClient didReceiveMessage:message];
    }
}

@end
