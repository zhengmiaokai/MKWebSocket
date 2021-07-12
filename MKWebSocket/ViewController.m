//
//  ViewController.m
//  MKWebSocket
//
//  Created by zhengmiaokai on 2021/7/5.
//

#import "ViewController.h"
#import "MKWebSocketClient.h"
#import "MKWebSocketMessage.h"
#import "MKTestModule.h"

@interface ViewController () <MKTestModuleProtocol>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
    [SOCKET_MODULE(MKTestModule) addDelegate:self]; /// 注册子模块
    // [[MKWebSocketClient sharedInstance] addDelegate:self];
    
    _connectBtn.enabled = YES;
    _sendBtn.enabled = NO;
    _closeBtn.enabled = NO;
}

- (IBAction)connect:(UIButton *)sender {
    if (_adressTF.text.length) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_adressTF.text]];
        [request setValue:@"" forHTTPHeaderField:@"Cookie"];
        
        [MKWebSocketClient sharedInstance].serverRequest = request;
        [[MKWebSocketClient sharedInstance] connect];
    }
}

- (IBAction)close:(UIButton *)sender {
    [[MKWebSocketClient sharedInstance] disconnect];
}

- (IBAction)send:(UIButton *)sender {
    if (_contentTF.text.length) {
        [[MKWebSocketClient sharedInstance] sendMessage:_contentTF.text];
    }
}

- (IBAction)clean:(UIButton *)sender {
    _contentTV.text = nil;
    [self.contentTV setContentOffset:CGPointZero];
}

- (void)scollToBottom {
    if (self.contentTV.contentSize.height > self.contentTV.frame.size.height) {
        [self.contentTV setContentOffset:CGPointMake(0, self.contentTV.contentSize.height - self.contentTV.frame.size.height) animated:YES];
    }
}

#pragma mark - MKWebSocketClientDelegate -
- (void)webSocketClient:(id)webSocketClient didReceiveMessage:(MKWebSocketMessage *)message {
    self.contentTV.text = [NSString stringWithFormat:@"%@\n\n服务端：%@", self.contentTV.text, message.message];
    [self scollToBottom];
}

- (void)webSocketClient:(id)webSocketClient didReciveStatusChanged:(MKWebSocketStatus)status {
    if (status == MKWebSocketStatusOpen) {
        self.contentTV.text = [NSString stringWithFormat:@"%@\n\n%@", self.contentTV.text, @"已连接对应的服务。。。"];
        [self scollToBottom];
        
        self.sendBtn.enabled = YES;
        self.closeBtn.enabled = YES;
        self.connectBtn.enabled = NO;
    } else {
        self.sendBtn.enabled = NO;
        self.closeBtn.enabled = NO;
        self.connectBtn.enabled = YES;
        
        if (status == MKWebSocketStatusClose) {
            self.contentTV.text = [NSString stringWithFormat:@"%@\n\n%@", self.contentTV.text, @"服务已断开。。。"];
            [self scollToBottom];
        } else if (status == MKWebSocketStatusConnecting) {
            self.contentTV.text = [NSString stringWithFormat:@"%@\n\n%@", self.contentTV.text, @"正在连接中。。。"];
            [self scollToBottom];
        }
    }
}

- (void)webSocketClient:(id)webSocketClient didSendMessage:(MKWebSocketMessage *)message {
    self.contentTV.text = [NSString stringWithFormat:@"%@\n\n客户端：%@", self.contentTV.text, message.message];
    [self scollToBottom];
}

- (void)refreshOrder:(id)data {
    
}

@end

