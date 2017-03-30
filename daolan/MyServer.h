//
//  MyServer.h
//  StudySocketApp
//
//  Created by sean yang on 12-10-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MyServerDelegete <NSObject>

- (void)showtitle:(NSString *)title;

@end

@interface MyServer : NSObject{
    BOOL isClosed;
    int toServerSocket;
    NSUInteger audioDataIndex;
}
// 初始化服务器
-(void) initServer;
// 读客户端数据
//-(void) readData:(NSNumber*) clientSocket;
// 向客户端发送数据
-(void) sendData:(NSData *)data;
// 在新线程中监听客户端
-(void) startListenAndNewThread;
-(void) closeServer;

@property (nonatomic, weak) id <MyServerDelegete> delegate;

@property (strong, nonatomic) NSMutableData *tempData;

@end



