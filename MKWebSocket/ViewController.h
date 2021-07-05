//
//  ViewController.h
//  MKWebSocket
//
//  Created by zhengmiaokai on 2021/7/5.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet  UITextField* adressTF;
@property (weak, nonatomic) IBOutlet  UIButton* connectBtn;
@property (weak, nonatomic) IBOutlet  UIButton* closeBtn;

@property (weak, nonatomic) IBOutlet  UITextField* contentTF;
@property (weak, nonatomic) IBOutlet  UIButton* sendBtn;
@property (weak, nonatomic) IBOutlet  UIButton* cleanBtn;

@property (weak, nonatomic) IBOutlet  UITextView* contentTV;

- (IBAction)connect:(UIButton *)sender;
- (IBAction)close:(UIButton *)sender;
- (IBAction)send:(UIButton *)sender;
- (IBAction)clean:(UIButton *)sender;

@end
