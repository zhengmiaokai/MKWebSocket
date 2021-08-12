//
//  NSDate+Additions.m
//  MKWebSocket
//
//  Created by mikazheng on 2021/8/12.
//

#import "NSDate+Additions.h"

@implementation NSDate (Additions)

+ (NSString *)dateToString:(NSDate *)date withDateFormat:(NSString*)dateFormat {
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
    }
    [formatter setDateFormat:dateFormat];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}

@end
