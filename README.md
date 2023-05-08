# MKWebSocket

## 使用SRWebSocket实现的长链接，支持cookie设置、连接异常 | 网络抖动重连、ping-pong心跳保活

### 基于SRWebSocket的WebSocket长连接：https://blog.csdn.net/z119901214/article/details/119658069

### 具体使用请参考ViewController
```objective-c
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
    /* 添加子模块代理 */
    [SOCKET_MODULE(MKTestModule) addDelegate:self];
     
     /* 添加主模块代理
     [[MKWebSocketClient sharedInstance] addDelegate:self];
     */
    
    _connectBtn.enabled = YES;
    _pingBtn.enabled = NO;
    _sendBtn.enabled = NO;
    _closeBtn.enabled = NO;
}

- (void)dealloc {
    /* 移除子模块代理 */
    [SOCKET_MODULE(MKTestModule) removeDelegate:self];
    
    /* 移除主模块代理
     [[MKWebSocketClient sharedInstance] removeDelegate:self];
     */
}

- (IBAction)connect:(UIButton *)sender {
    if (_adressTF.text.length) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_adressTF.text]];
        request.timeoutInterval = 25;
        [request setValue:@"" forHTTPHeaderField:@"Cookie"];
        
        [MKWebSocketClient sharedInstance].serverRequest = request;
        [[MKWebSocketClient sharedInstance] connect];
    }
}
```

<img width="265" alt="WeChat16372c25ff834ee3641a00cd173912f4" src="https://user-images.githubusercontent.com/13111933/129174671-10f14a11-ff29-4f7e-ac6f-ba15690c4079.png">
