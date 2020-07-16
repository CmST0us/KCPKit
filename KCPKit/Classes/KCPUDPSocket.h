//
//  KCPUDPSocket.h
//  KCPKit
//
//  Created by eki on 2020/7/16.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class KCPUDPSocket;
@protocol KCPUDPSocketDelegate <NSObject>

- (void)socketDidConnect:(KCPUDPSocket *)socket;
- (void)socket:(KCPUDPSocket *)socket didRecvData:(NSData *)data;
- (void)socketDidDisconnect:(KCPUDPSocket *)socket;

@end

@interface KCPUDPSocket : NSObject

@property (nonatomic, weak) id<KCPUDPSocketDelegate> delegate;

- (instancetype)initWithSessionID:(NSUInteger)sessionID
                         delegate:(id<KCPUDPSocketDelegate>)delegate;

- (NSError *)connectToHost:(NSString *)host
                      port:(NSInteger)port;
- (NSError *)bindToPort:(NSInteger)port;

- (void)sendData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
