//
//  KCPUDPSocket.m
//  KCPKit
//
//  Created by eki on 2020/7/16.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import "KCPUDPSocket.h"
#import "KCPGCDAsyncUdpSocket.h"
#import "KCPObject.h"

#define kKCPUDPUpdateInterval (10) // 10ms

@interface KCPUDPSocket () <KCPGCDAsyncUdpSocketDelegate>
@property (nonatomic, strong) KCPGCDAsyncUdpSocket *udpSocket;
@property (nonatomic, strong) KCPObject *kcpObject;

@property (nonatomic, strong) dispatch_queue_t delegateQueue;
@property (nonatomic, strong) dispatch_queue_t udpSocketDelegateQueue;
@property (nonatomic, strong) dispatch_source_t kcpUpdateTimer;
@property (nonatomic, strong) dispatch_queue_t kcpWorkQueue;
@end

@implementation KCPUDPSocket

- (instancetype)initWithSessionID:(NSUInteger)sessionID
                         delegate:(id<KCPUDPSocketDelegate>)delegate {
    self = [super init];
    if (self) {
        __weak typeof(self) weakSelf = self;
        _delegate = delegate;
        _udpSocketDelegateQueue = dispatch_queue_create("UDPSocketDelegateQueue", DISPATCH_QUEUE_SERIAL);
        _delegateQueue = dispatch_queue_create("KCPUDPSocketDelegateQueue", DISPATCH_QUEUE_SERIAL);
        _kcpWorkQueue = dispatch_queue_create("KCPWorkQueue", DISPATCH_QUEUE_SERIAL);
        _udpSocket = [[KCPGCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:_udpSocketDelegateQueue];
        _kcpObject = [[KCPObject alloc] initWithSessionID:sessionID
                                         outputDataHandle:^int(NSData * _Nonnull data) {
            [weakSelf.udpSocket sendData:data withTimeout:-1 tag:0];
            return 0;
        }];
    }
    return self;
}

- (NSError *)connectToHost:(NSString *)host
                      port:(NSInteger)port {
    NSError *error = nil;
    [self.udpSocket connectToHost:host onPort:port error:&error];
    return error;
}

- (NSError *)bindToPort:(NSInteger)port {
    NSError *error = nil;
    [self.udpSocket bindToPort:port error:&error];
    return error;
}

- (void)sendData:(NSData *)data {
    dispatch_async(self.kcpWorkQueue, ^{
        [self.kcpObject sendData:data];
    });
}

#pragma mark - Delegate
- (void)udpSocket:(KCPGCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    __weak typeof(self) weakSelf = self;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.kcpWorkQueue);
    self.kcpUpdateTimer = timer;
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC, 0.01 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        [weakSelf.kcpObject update];
        /// try to check recv
        NSData *recvData = [weakSelf.kcpObject recvData];
        if (recvData) {
            dispatch_async(weakSelf.delegateQueue, ^{
                if (weakSelf.delegate &&
                    [weakSelf.delegate respondsToSelector:@selector(socket:didRecvData:)]) {
                    [weakSelf.delegate socket:weakSelf didRecvData:recvData];
                }
            });
        }
    });
    dispatch_resume(timer);
    
    dispatch_async(self.delegateQueue, ^{
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(socketDidConnect:)]) {
            [self.delegate socketDidConnect:self];
        }
    });
}

- (void)udpSocket:(KCPGCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error {
    dispatch_async(self.delegateQueue, ^{
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(socketDidDisconnect:)]) {
            [self.delegate socketDidDisconnect:self];
        }
    });
}

- (void)udpSocket:(KCPGCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    dispatch_async(self.kcpWorkQueue, ^{
        [self.kcpObject inputData:data];
    });
}

- (void)udpSocketDidClose:(KCPGCDAsyncUdpSocket *)sock withError:(NSError  * _Nullable)error {
    if (self.kcpUpdateTimer) {
        dispatch_cancel(self.kcpUpdateTimer);
        self.kcpUpdateTimer = nil;
    }
}

@end
