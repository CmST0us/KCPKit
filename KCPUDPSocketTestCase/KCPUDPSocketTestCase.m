//
//  KCPUDPSocketTestCase.m
//  KCPUDPSocketTestCase
//
//  Created by eki on 2020/7/16.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KCPUDPSocket.h"

@interface KCPUDPSocketTestCase : XCTestCase <KCPUDPSocketDelegate>
@property (nonatomic, strong) KCPUDPSocket *socket;
@property (nonatomic, strong) KCPUDPSocket *socketB;
@property (nonatomic, strong) dispatch_source_t sendTimer;
@end

@implementation KCPUDPSocketTestCase

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.socket = [[KCPUDPSocket alloc] initWithSessionID:10 delegate:self];
    [self.socket bindToPort:12001];
    [self.socket connectToHost:@"127.0.0.1" port:12002];
    
    self.socketB = [[KCPUDPSocket alloc] initWithSessionID:10 delegate:self];
    [self.socketB bindToPort:12002];
    [self.socketB connectToHost:@"127.0.0.1" port:12001];
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        [self.socket sendData:[@"helloB" dataUsingEncoding:NSUTF8StringEncoding]];
        [self.socketB sendData:[@"helloA" dataUsingEncoding:NSUTF8StringEncoding]];
    });
    dispatch_resume(timer);
    self.sendTimer = timer;
    
    [[NSRunLoop currentRunLoop] run];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)socket:(KCPUDPSocket *)socket didRecvData:(NSData *)data {
    NSLog(@"[RECV] recv data %@", data);
}
@end
