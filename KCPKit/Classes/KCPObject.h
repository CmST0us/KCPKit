//
//  KCPObject.h
//  KCPKit
//
//  Created by eki on 2020/7/16.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KCPObject : NSObject
/// Create KCPObject with session ID
/// @param sessionID data link id. Need the same session ID, that can be received.
- (instancetype)initWithSessionID:(NSUInteger)sessionID;
@end

NS_ASSUME_NONNULL_END
