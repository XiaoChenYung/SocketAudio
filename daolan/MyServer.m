//
//  MyServer.m
//  StudySocketApp
//
//  Created by sean yang on 12-10-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyServer.h"
#include<stdio.h>
#include<unistd.h>
#include<strings.h>
#include<sys/types.h>
#include<sys/socket.h>
#include<netinet/in.h>
#include<netdb.h>
#include "AudioConstant.h"

#define PORT 667788 
#define MAXDATASIZE 100
#define LENGTH_OF_LISTEN_QUEUE  20
#define BUFFER_SIZE 256
#define THREAD_MAX    5
NSLock *lock;  

@implementation MyServer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tempData = [NSMutableData data];
        self.socketData = [NSMutableArray array];
        audioDataIndex = 0;
        [NSThread detachNewThreadSelector:@selector(sendSocketData)
                                 toTarget:self withObject:nil];
    }
    return self;
}

// 初始化服务器
-(void) initServer{
    //设置一个socket地址结构server_addr,代表服务器internet地址, 端口
    struct sockaddr_in server_addr;
    bzero(&server_addr,sizeof(server_addr)); //把一段内存区的内容全部设置为0
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = htons(INADDR_ANY);
    server_addr.sin_port = htons(PORT);
    
    //创建用于internet的流协议(TCP)socket,
    //用server_socket代表服务器socket
    int server_socket = socket(AF_INET,SOCK_STREAM,0);
    if( server_socket < 0)
    {
        printf("Create Socket Failed!");
        exit(1);
    }
    
    //把socket和socket地址结构联系起来
    if( bind(server_socket,(struct sockaddr*)&server_addr,sizeof(server_addr)))
    {
        printf("Server Bind Port : %d Failed!", PORT); 
        exit(1);
    }
    
    //server_socket用于监听
    if ( listen(server_socket, LENGTH_OF_LISTEN_QUEUE) )
    {
        printf("Server Listen Failed!"); 
        exit(1);
    }
    
    isClosed = NO;
    
    while(!isClosed) //服务器端要一直运行
    {
        printf("Server start......\n");
        //定义客户端的socket地址结构client_addr
        struct sockaddr_in client_addr;
        socklen_t length = sizeof(client_addr);
        
        //接受一个到server_socket代表的socket的一个连接
        //如果没有连接请求,就等待到有连接请求--这是accept函数的特性
        //accept函数返回一个新的socket,这个socket(new_server_socket)用于同连接到的客户的通信
        //new_server_socket代表了服务器和客户端之间的一个通信通道
        //accept函数把连接到的客户端信息填写到客户端的socket地址结构client_addr中
        int new_client_socket = accept(server_socket,(struct sockaddr*)&client_addr,&length);
        [self.socketData addObject:@(new_client_socket)];
//        toServerSocket = new_client_socket;
        if ( new_client_socket < 0)
        {
            printf("Server Accept Failed!/n");
            break;
        }
        
        printf(" one client connted..\n");
        [NSThread detachNewThreadSelector:@selector(readData:) 
            toTarget:self 
            withObject:[NSNumber numberWithInt:new_client_socket]];
    }
    //关闭监听用的socket
    close(server_socket);
    NSLog(@"%@",@"server closed....");
}
// 读客户端数据
-(void) readData:(NSNumber*) clientSocket{
    char buffer[BUFFER_SIZE];
    int intSocket = [clientSocket intValue];
    
    while(buffer[0] != '-'){
        
        bzero(buffer,BUFFER_SIZE);
        //接收客户端发送来的信息到buffer中
        recv(intSocket,buffer,BUFFER_SIZE,0);
        NSString * mystring = [NSString stringWithUTF8String:buffer];
        [self.delegate showtitle:mystring];
        printf("client:%s\n",buffer);
    }
    //关闭与客户端的连接
    printf("client:close\n");
    close(intSocket); 

}

// 向客户端发送数据
- (void)sendData:(NSData *)data {
    [self.tempData appendData:data];
    

    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        send(toServerSocket,[data bytes],[data length],0);
//    });
    
}

- (void)sendSocketData {
    while (1) {
//        char tempBuffer[8000];
//        [self.tempData getBytes:tempBuffer range:NSMakeRange(audioDataIndex, 8000)];
        if (self.tempData.length > audioDataIndex + 8000) {
            NSData *sendData = [self.tempData subdataWithRange:NSMakeRange(audioDataIndex, 8000)];
            for (NSNumber *num in self.socketData) {
                int intNum = num.intValue;
                ssize_t count = send(intNum,[sendData bytes],[sendData length],0);
                NSLog(@"数量%zd",count);
            }
            
            audioDataIndex += 8000;
        }

    }
}

// 在新线程中监听客户端
-(void) startListenAndNewThread{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self initServer];
//    });
    [NSThread detachNewThreadSelector:@selector(initServer)
                             toTarget:self withObject:nil];
}
-(void) closeServer{
    isClosed = YES;
}
@end
