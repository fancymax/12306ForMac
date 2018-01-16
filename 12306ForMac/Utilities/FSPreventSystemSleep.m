//
//  FSPreventSystemSleep.m
//
//  Created by fancymax on 16/01/2018.
//

#import "FSPreventSystemSleep.h"
#import <IOKit/pwr_mgt/IOPMLib.h>

NSString * const kMPXPowerSaveAssertion    = @"Query Tickets";

@implementation FSPreventSystemSleep
IOPMAssertionID nonSleepHandler;

- (instancetype)init {
    if (self = [super init]) {
        nonSleepHandler = kIOPMNullAssertionID;
    }
    
    return self;
}

- (void)dealloc {
    if (nonSleepHandler != kIOPMNullAssertionID) {
        IOPMAssertionRelease(nonSleepHandler);
        nonSleepHandler = kIOPMNullAssertionID;
    }
}

-(void)preventSystemSleep:(BOOL)disabled {
    if (disabled) {
        if (nonSleepHandler == kIOPMNullAssertionID) {
            IOReturn err =
            IOPMAssertionCreateWithName(kIOPMAssertionTypePreventUserIdleSystemSleep, kIOPMAssertionLevelOn,
                                        (__bridge CFStringRef)kMPXPowerSaveAssertion, &nonSleepHandler);
            if (err != kIOReturnSuccess) {
                NSLog(@"Can't preventSystemSleep");
            }
        }
    } else {
        if (nonSleepHandler != kIOPMNullAssertionID) {
            IOPMAssertionRelease(nonSleepHandler);
            nonSleepHandler = kIOPMNullAssertionID;
        }
    }
}

@end
