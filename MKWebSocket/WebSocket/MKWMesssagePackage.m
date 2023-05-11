//
//  MKWMesssagePackage.m
//  MKWebSocket
//
//  Created by zhengmiaokai on 2021/11/15.
//

#import "MKWMesssagePackage.h"
#import "NSObject+Additions.h"

@implementation MKWSendPackage

+ (NSString *)ackWithPayload:(NSDictionary *)payload {
    MKWSendPackage* item = [[MKWSendPackage alloc] init];
    item.msgType = @"ACK";
    item.source = @"CLIENT";
    item.payload = payload; // keys: msgId
    item.timeInterval = (NSInteger)([[NSDate date] timeIntervalSince1970] * 1000);
    return [item objectPropertyJSONString];
}

+ (NSString *)askWithPayload:(NSDictionary *)payload {
    MKWSendPackage* item = [[MKWSendPackage alloc] init];
    item.msgType = @"ASK";
    item.source = @"CLIENT";
    item.payload = payload;  // keys: action、parameter、askId
    item.timeInterval = (NSInteger)([[NSDate date] timeIntervalSince1970] * 1000);
    return [item objectPropertyJSONString];
}

@end

@implementation MKWReceivePackage

@end
