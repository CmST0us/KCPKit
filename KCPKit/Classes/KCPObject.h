//
//  KCPObject.h
//  KCPKit
//
//  Created by eki on 2020/7/16.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef int(^KCPObjectOutputDataHandle)(NSData *data);

@interface KCPObject : NSObject
/// Create KCPObject with session ID
/// @param sessionID data link id. Need the same session ID, that can be received.
/// @param outputDataHandle data handle to send kcp data.
- (instancetype)initWithSessionID:(NSUInteger)sessionID
                 outputDataHandle:(KCPObjectOutputDataHandle)outputDataHandle;

- (void)update;
- (int)inputData:(NSData *)data;

- (int)sendData:(NSData *)data;
- (nullable NSData *)recvData;

@end

NS_ASSUME_NONNULL_END
