#import "BVMPinger.h"
#import "SimplePing.h"

@interface BVMPinger () <SimplePingDelegate>

@property (nonatomic, strong) SimplePing *simplePing;

@property (nonatomic, assign) NSUInteger pingCount;
@property (nonatomic, assign) BOOL simplePingInitialized;
@property (nonatomic, assign) BOOL pingingDesired;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) double currentIntervalTime;
@property (nonatomic, assign) double totalTime;

@end

@implementation BVMPinger

- (id)initWithHost:(NSString *)domainOrIp
{
    self = [super init];
    if (self) {
        self.simplePing = [SimplePing simplePingWithHostName:domainOrIp];
        self.simplePing.delegate = self;
        [self.simplePing start];
    }
    return self;
}

- (void)startPinging
{
    self.pingingDesired = YES;
    if (self.simplePingInitialized) [self startPingInternal];
}

- (void)startPingInternal
{
    [self sendPing];
}

- (void)stopPinging
{
    self.pingingDesired = NO;
}

- (void)sendPing
{
    [self.simplePing sendPingWithData:nil];
}

- (void)timerHandler
{
    self.currentIntervalTime += 0.01;
    // todo clean this up - hardcoded values
}

#pragma mark SimplePingDelegate methods

- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address
{
    self.simplePingInitialized = YES;
    if (self.pingingDesired) [self startPingInternal];
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error
{
//    NSLog(@"failed: %@", [self shortErrorFromError:error]);
#warning TODO CDZ handle error
//    self.simplePing = nil;
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet
{
    NSLog(@"#%u sent", (unsigned int) OSSwapBigToHostInt16(((const ICMPHeader *) [packet bytes])->sequenceNumber) );
    
    self.currentIntervalTime = 0.0;
    self.pingCount++;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(timerHandler) userInfo:nil repeats:YES];
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet error:(NSError *)error
{
#warning TODO CDZ handle error
    //    NSLog(@"#%u send failed: %@", (unsigned int) OSSwapBigToHostInt16(((const ICMPHeader *) [packet bytes])->sequenceNumber), [self shortErrorFromError:error]);
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet
{
    NSLog(@"#%u received", (unsigned int) OSSwapBigToHostInt16([SimplePing icmpInPacket:packet]->sequenceNumber) );

    [self.timer invalidate];
    self.timer = nil;
    self.totalTime += self.currentIntervalTime;

    // todo clean this up - hardcoded values
    if (self.pingingDesired && self.pingCount < 9) [self sendPing];
    if (self.pingCount >= 9) {
        double averageTime = self.totalTime / (double)self.pingCount;
        id delegate = self.timingDelegate;
        if ([delegate respondsToSelector:@selector(pinger:didUpdateWithTime:)]) {
            [delegate pinger:self didUpdateWithTime:averageTime];
        }
    }
}

@end
