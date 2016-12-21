//
//  ModifyHosts.h
//  12306ForMac
//
//  Created by zc on 2016/12/21.
//  Copyright © 2016年 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModifyHosts : NSObject
+ (nonnull instancetype)sharedInstance;

+(nonnull instancetype)new NS_UNAVAILABLE;
-(nonnull instancetype)init NS_UNAVAILABLE;

// Hosts will be restore when ip is nil
-(BOOL)udpateHostsFor12306:(nullable NSString *)ip;
@end
