//
//  AppDelegate.m
//  MKWebSocket
//
//  Created by zhengmiaokai on 2021/7/5.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    ViewController* rootVC = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:rootVC];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
