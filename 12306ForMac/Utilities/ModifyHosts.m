//
//  ModifyHosts.m
//  12306ForMac
//
//  Created by zc on 2016/12/21.
//  Copyright © 2016年 fancy. All rights reserved.
//

#import "ModifyHosts.h"

static NSString *HostsFileLocation = @"/etc/hosts";

@interface ModifyHosts ()
@property (nonatomic, assign) AuthorizationRef authorizationRef;
@property (nonatomic, assign) BOOL authorized;
@property (nonatomic, strong) NSFileManager *fileManager;

@end

@implementation ModifyHosts

+ (nonnull instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static ModifyHosts *instance;
    dispatch_once(&onceToken, ^{
        instance = [[ModifyHosts alloc] initPrivate];
    });
    return instance;
}

#pragma mark - Private methods
- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        self.fileManager = [NSFileManager defaultManager];
    }
    return self;
}

-(BOOL)udpateHostsFor12306:(nullable NSString *)ip {
    NSString *reason = @"为了更新 12306 的 cdn，需要动态更新 hosts.\n";
    if (![self ensureHostsFileIsWritable: self.fileManager withReason:reason]) {
        return NO;
    }
    
    NSMutableArray *hostsArray = [[[NSString
                            stringWithContentsOfFile:HostsFileLocation
                            encoding:NSUTF8StringEncoding error:nil]
                                   componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]
                                  mutableCopy];
    [hostsArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj containsString:@"kyfw.12306.cn"]) {
            [hostsArray removeObjectAtIndex:idx];
            *stop = YES;
        }
    }];
    if (ip) {
        [hostsArray addObject:[NSString stringWithFormat:@"%@\tkyfw.12306.cn", ip]];
    }
    NSError *error = NULL;
    NSString * result = [hostsArray componentsJoinedByString:@"\n"];
    [result writeToFile:HostsFileLocation atomically:NO encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Failed to save hosts file [error: %@]", error);
        return NO;
    }
    
    [self flushDirectoryServiceCache];
    return YES;
}

- (BOOL) flushDirectoryServiceCache
{
    NSLog(@"Flushing Directory Service Cache");
    NSArray *arguments = [NSArray arrayWithObject:@"-flushcache"];
    NSTask * task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/dscacheutil" arguments:arguments];
    [task waitUntilExit];
    return [task terminationStatus] == 0;
}

#pragma mark - Auth

/*
 Reference: https://github.com/2ndalpha/gasmask
 */

- (BOOL) ensureHostsFileIsWritable:(NSFileManager*) manager withReason: (NSString*) reason
{
    BOOL writable = NO;
    if ([manager isWritableFileAtPath:HostsFileLocation]) {
        return YES;
    }
    
    writable = [self
                makeWritableForCurrentUser:HostsFileLocation
                prompt:reason];
    if (!writable) {
        NSLog(@"Failed to make \"%@\" writable", HostsFileLocation);
    }
    return writable;
}

- (BOOL)makeWritableForCurrentUser:(NSString*)path prompt:(NSString*)prompt
{
    if (![self authorized] && ![self authorizeWithPrompt:prompt]) {
        return NO;
    }
//    return YES;
    
    NSMutableString *arg = [NSMutableString new];
    [arg appendString:@"user:"];
    [arg appendString:NSUserName()];
    [arg appendString:@":allow write"];
    
    const char * arguments[] = {"+a", [arg UTF8String], [path UTF8String], NULL};
    return [self execute:"/bin/chmod" withArguments: (char **)arguments];
}

-(BOOL)execute:(const char *)command withArguments:(char *const *)arguments
{
    AuthorizationFlags flags = kAuthorizationFlagDefaults;
    
    OSStatus status = AuthorizationExecuteWithPrivileges(_authorizationRef, command, flags, (char **)arguments, NULL);
    
    [NSThread sleepForTimeInterval:1];
    
    return status == errAuthorizationSuccess;
}

- (BOOL)authorizeWithPrompt:(NSString*)prompt
{
    OSStatus status;
    AuthorizationFlags flags = kAuthorizationFlagDefaults;
    
    status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, flags, &_authorizationRef);
    if (status != errAuthorizationSuccess) {
        _authorized = NO;
        return _authorized;
    }
    
    AuthorizationItem items = {kAuthorizationRightExecute, 0, NULL, 0};
    AuthorizationRights rights = {1, &items};
    
    AuthorizationEnvironment *environment = NULL;
    if (prompt != nil) {
        AuthorizationItem auth_prompt = {kAuthorizationEnvironmentPrompt, [prompt length], (void *)[prompt UTF8String], 0};
        AuthorizationEnvironment auth_env = { 1, &auth_prompt };
        environment = &auth_env;
    }
    
    flags = kAuthorizationFlagDefaults |
    kAuthorizationFlagInteractionAllowed |
    kAuthorizationFlagPreAuthorize |
    kAuthorizationFlagExtendRights;
    
    status = AuthorizationCopyRights (_authorizationRef, &rights, environment, flags, NULL);
    
    if (status != errAuthorizationSuccess) {
        _authorized = NO;
        return _authorized;
    }
    
    _authorized = YES;
    return _authorized;
}

@end
