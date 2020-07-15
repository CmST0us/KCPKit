//
//  KCPObject.m
//  KCPKit
//
//  Created by eki on 2020/7/16.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import "ikcp.h"
#import "KCPObject.h"

@interface KCPObject ()
@property (nonatomic, assign) ikcpcb *kcp;
@end

@implementation KCPObject

- (void)dealloc {
    if (_kcp) {
        ikcp_release(_kcp);
        _kcp = NULL;
    }
}

- (instancetype)initWithSessionID:(NSUInteger)sessionID {
    self = [super init];
    if (self) {
        _kcp = ikcp_create((IUINT32)sessionID, (__bridge void *)self);
        NSAssert(_kcp != NULL, @"can not create kcp");
        _kcp->output = kcp_output;
    }
    return self;
}

#pragma mark - Handler
- (int)handleKCPOutputWithData:(NSData *)data {
    return 0;
}

#pragma mark - KCP Callback
int kcp_output(const char *buf, int len, struct IKCPCB *kcp, void *user) {
    @autoreleasepool {
        KCPObject *object = (__bridge KCPObject *)user;
        if (object) {
            NSData *data = [NSData dataWithBytes:buf length:len];
            return [object handleKCPOutputWithData:data];
        }
        return -1;
    }
}

@end
