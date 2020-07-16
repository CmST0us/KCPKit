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
@property (nonatomic, assign) uint8_t *mtuBuffer;
@property (nonatomic, copy) KCPObjectOutputDataHandle outputDataHandle;
@end

@implementation KCPObject

- (void)dealloc {
    if (_kcp) {
        ikcp_release(_kcp);
        _kcp = NULL;
    }
    if (_mtuBuffer) {
        free(_mtuBuffer);
        _mtuBuffer = NULL;
    }
}

- (instancetype)initWithSessionID:(NSUInteger)sessionID
                 outputDataHandle:(KCPObjectOutputDataHandle)outputDataHandle {
    self = [super init];
    if (self) {
        _kcp = ikcp_create((IUINT32)sessionID, (__bridge void *)self);
        NSAssert(_kcp != NULL, @"can not create kcp");
        _kcp->output = kcp_output;
        self.outputDataHandle = outputDataHandle;
        _mtuBuffer = malloc(_kcp->mtu);
        memset(_mtuBuffer, 0, _kcp->mtu);
    }
    return self;
}

- (void)update {
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
    ikcp_update(_kcp, (IUINT32) currentTime);
}

- (int)inputData:(NSData *)data {
    return ikcp_input(_kcp, data.bytes, data.length);
}

- (int)sendData:(NSData *)data {
    return ikcp_send(_kcp, data.bytes, (int)data.length);
}

- (NSData *)recvData {
    int mtuSize = _kcp->mtu;
    int recvSize = ikcp_recv(_kcp, (char *)_mtuBuffer, mtuSize);
    if (recvSize <= 0) {
        return nil;
    }
    NSData *data = [[NSData alloc] initWithBytes:_mtuBuffer length:recvSize];
    return data;
}

#pragma mark - Handler
- (int)handleKCPOutputWithData:(NSData *)data {
    if (self.outputDataHandle) {
        return self.outputDataHandle(data);
    }
    return -1;
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
