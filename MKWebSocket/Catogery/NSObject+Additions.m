//
//  NSObject+Additions.m
//  MKWebSocket
//
//  Created by zhengmiaokai on 2021/11/16.
//

#import "NSObject+Additions.h"
#import <objc/runtime.h>

@interface NSArray (KeyValue)

- (NSArray *)arrayRecordPropertyArray;

@end

@interface NSDictionary (KeyValue)

- (NSDictionary *)dictionaryRecordPropertyDictionary;

@end

@implementation NSObject (Additions)

- (NSDictionary *)objectPropertyDictionary {
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    id currentClass = [self class];
    while (![NSStringFromClass(currentClass) isEqualToString:@"NSObject"]) {
        /// && ([NSBundle bundleForClass:currentClass] == [NSBundle mainBundle])
        unsigned int propertieCount = 0;
        objc_property_t* properties  = class_copyPropertyList(currentClass, &propertieCount);
        
        @autoreleasepool {
            for (int i = 0; i < propertieCount; i++) {
                objc_property_t property = properties[i];
                
                const char* name = property_getName(property);
                NSString* propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
                
                NSObject* value = [self valueForKey:propertyName];
                Class objectClass = object_getClass(value);
                
                if  (objectClass != nil) {
                    NSString* className = NSStringFromClass(objectClass);
                    
                    if ([className rangeOfString:@"NS"].length != 0) {
                        if ([className rangeOfString:@"String"].length != 0) {
                            parameters[propertyName] = value;
                        } else if ([className rangeOfString:@"Number"].length != 0) {
                            parameters[propertyName] = value;
                        } else if ([className rangeOfString:@"Data"].length != 0) {
                            parameters[propertyName] = value;
                        } else if ([className rangeOfString:@"Array"].length != 0) {
                            NSArray* arr = [(NSArray *)value arrayRecordPropertyArray];
                            parameters[propertyName] = arr;
                        } else if ([className rangeOfString:@"Dictionary"].length != 0)  {
                            NSDictionary* dic = [(NSDictionary *)value dictionaryRecordPropertyDictionary];
                            parameters[propertyName] = dic;
                        } else {
                            continue;
                        }
                    } else if ([className rangeOfString:@"Block"].length != 0) {
                        continue;
                    } else {
                        NSDictionary* dic = [(NSObject *)value objectPropertyDictionary];
                        parameters[propertyName] = dic;
                    }
                }
            }
        }
        
        if (properties) {
            free(properties);
        }
        currentClass = [currentClass superclass];
    }
    return parameters;
}

- (NSString *)objectPropertyJSONString {
    NSDictionary *objectPropertys = [self objectPropertyDictionary];
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:objectPropertys options:kNilOptions error:nil];
    NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
    return JSONString;
}

@end


@implementation NSArray (KeyValue)

- (NSArray *)arrayRecordPropertyArray {
    
    NSInteger count = self.count;
    
    NSMutableArray* parameters = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        
        NSObject* value = self[i];
        
        Class objectClass = object_getClass(value);
        
        if  (objectClass != nil) {
            NSString* className = NSStringFromClass(objectClass);
            
            if ([className rangeOfString:@"NS"].length != 0)  {
                if ([className rangeOfString:@"String"].length != 0) {
                    [parameters addObject:value];
                }
                else if ([className rangeOfString:@"Number"].length != 0) {
                    [parameters addObject:value];
                }
                else if ([className rangeOfString:@"Data"].length != 0) {
                    [parameters addObject:value];
                }
                else if ([className rangeOfString:@"Array"].length != 0) {
                    NSArray* arr = [(NSArray *)value arrayRecordPropertyArray];
                    [parameters addObject: arr];
                }
                else if ([className rangeOfString:@"Dictionary"].length != 0)  {
                    NSDictionary* dic = [(NSDictionary *)value dictionaryRecordPropertyDictionary];
                    [parameters addObject: dic];
                }
                else {
                    continue;
                }
            }
            else if ([className rangeOfString:@"Block"].length != 0) {
                continue;
            }
            else {
                NSDictionary* dic = [(NSObject *)value objectPropertyDictionary];
                [parameters addObject: dic];
            }
        }
    }
    return parameters;
}

@end


@implementation NSDictionary (KeyValue)

- (NSDictionary *)dictionaryRecordPropertyDictionary {
    NSInteger count = self.allKeys.count;
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithCapacity:count];
    
    for (int i = 0; i < count; i++) {
        
        NSString* key = self.allKeys[i];
        NSObject* value = self[key];
        
        Class objectClass = object_getClass(value);
        
        if  (objectClass != nil) {
            NSString* className = NSStringFromClass(objectClass);
            
            if ([className rangeOfString:@"NS"].length != 0)  {
                if ([className rangeOfString:@"String"].length != 0) {
                    [parameters setObject:value forKey:key];
                }
                else if ([className rangeOfString:@"Number"].length != 0) {
                    [parameters setObject:value forKey:key];
                }
                else if ([className rangeOfString:@"Data"].length != 0) {
                    [parameters setObject:value forKey:key];
                }
                else if ([className rangeOfString:@"Array"].length != 0) {
                    NSArray* arr = [(NSArray *)value arrayRecordPropertyArray];
                    [parameters setObject:arr forKey:key];
                }
                else if ([className rangeOfString:@"Dictionary"].length != 0)  {
                    NSDictionary* dic = [(NSDictionary *)value dictionaryRecordPropertyDictionary];
                    [parameters setObject:dic forKey:key];
                }
                else {
                    continue;
                }
            }
            else if ([className rangeOfString:@"Block"].length != 0) {
                continue;
            }
            else {
                NSDictionary* dic = [(NSObject *)value objectPropertyDictionary];
                [parameters setObject:dic forKey:key];
            }
        }
    }
    return parameters;
}

@end
