//
//  MKWSPingVC.m
//  MKWebSocket
//
//  Created by zhengmiaokai on 2021/8/11.
//

#import "MKWSPingVC.h"
#import "MKWebSocketClient.h"

@interface MKWSPingVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView* tableView;

@end

@implementation MKWSPingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:MKWebSocketPingNotification object:nil];
}

- (void)refreshData:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 88, self.view.frame.size.width, self.view.frame.size.height - 88) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MKWSPingCellID"];
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [MKWebSocketClient sharedInstance].pingDatas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MKWSPingCellID"];
    cell.textLabel.text = [[MKWebSocketClient sharedInstance].pingDatas objectAtIndex:indexPath.row];
    return cell;
}

@end
