//
//  MKTestModule.h
//  Merchant
//
//  Created by mikazheng on 2021/7/12.
//

#import "MKWebSocketBaseModule.h"

@protocol MKTestModuleProtocol <MKWebSocketClientDelegate>

- (void)refreshOrder:(id)data;

@end


@interface MKTestModule : MKWebSocketBaseModule

@end
