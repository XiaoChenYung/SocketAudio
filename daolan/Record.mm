#import "Record.h"

@implementation Record
@synthesize aqc;
@synthesize audioDataLength;

static void AQInputCallback(
                            void * __nullable               inUserData,
                            AudioQueueRef                   inAQ,
                            AudioQueueBufferRef             inBuffer,
                            const AudioTimeStamp *          inStartTime,
                            UInt32                          inNumberPacketDescriptions,
                            const AudioStreamPacketDescription * __nullable inPacketDescs)
{
    
    Record * engine = (__bridge Record *) inUserData;
    if (inStartTime > 0)
    {
        [engine processAudioBuffer:inBuffer withQueue:inAQ];
    }
    
    if (engine.aqc.run)
    {
        AudioQueueEnqueueBuffer(engine.aqc.queue, inBuffer, 0, NULL);
    }
}

- (id) init
{
    self = [super init];
    if (self)
    {
        aqc.mDataFormat.mSampleRate = kSamplingRate;
        aqc.mDataFormat.mFormatID = kAudioFormatLinearPCM;
        aqc.mDataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger; // |kLinearPCMFormatFlagIsPacked;
        aqc.mDataFormat.mFramesPerPacket = 1;
        aqc.mDataFormat.mChannelsPerFrame = kNumberChannels;
        aqc.mDataFormat.mBitsPerChannel = kBitsPerChannels;
        aqc.mDataFormat.mBytesPerPacket = kBytesPerFrame;
        aqc.mDataFormat.mBytesPerFrame = kBytesPerFrame;
        aqc.frameSize = kFrameSize;
        
        AudioQueueNewInput(&aqc.mDataFormat, AQInputCallback, (__bridge void *)(self), NULL, kCFRunLoopCommonModes,0, &aqc.queue);
        
        for (int i=0;i<kNumberBuffers;i++)
        {
            AudioQueueAllocateBuffer(aqc.queue, aqc.frameSize, &aqc.mBuffers[i]);
            AudioQueueEnqueueBuffer(aqc.queue, aqc.mBuffers[i], 0, NULL);
        }
        aqc.recPtr = 0;
        aqc.run = 1;
        self.tempData = [NSMutableData data];
    }
    audioDataIndex = 0;
    return self;
}

- (void) dealloc
{
    AudioQueueStop(aqc.queue, true);
    aqc.run = 0;
    AudioQueueDispose(aqc.queue, true);
}

- (void) start
{
    AudioQueueStart(aqc.queue, NULL);
}

- (void) stop
{
    AudioQueueStop(aqc.queue, true);
}

- (void) pause
{
    AudioQueuePause(aqc.queue);
}

- (Byte *)getBytes
{
    return audioByte;
}

- (void) processAudioBuffer:(AudioQueueBufferRef) buffer withQueue:(AudioQueueRef) queue
{
    
//    NSLog(@"processAudioData :%u", (unsigned int)buffer->mAudioDataByteSize);
    //处理data：忘记oc怎么copy内存了，于是采用的C++代码，记得把类后缀改为.mm。同Play
    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        memcpy(audioByte+audioDataIndex, buffer->mAudioData, buffer->mAudioDataByteSize);
        audioDataIndex +=buffer->mAudioDataByteSize;
        audioDataLength = audioDataIndex;
        
        NSData *data = [NSData dataWithBytes:buffer->mAudioData length:buffer->mAudioDataByteSize];
        
        if (self.tempData.length >= 10240) {
            NSData *sendData = [self.tempData subdataWithRange:NSMakeRange(0, 10240)];
            if (self.delegate && [self.delegate respondsToSelector:@selector(record:AudioBuffer:withQueue:)]) {
                NSLog(@"%ld",sendData.length);
                [self.delegate record:self AudioBuffer:sendData withQueue:queue];
            }
            self.tempData = [self.tempData subdataWithRange:NSMakeRange(10240, self.tempData.length - 10240)].mutableCopy;
        } else {
            [self.tempData appendData:data];
        }
//    });
    

    
    
    
    
}

@end
