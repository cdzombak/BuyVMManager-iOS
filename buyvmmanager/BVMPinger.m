#import "BVMPinger.h"
#import "SimplePing.h"

// http://www.youtube.com/watch?v=jr0JaXfKj68
static const NSUInteger kBVMPingerNumPings = 20;

@interface BVMPinger () <SimplePingDelegate>

@property (nonatomic, strong) SimplePing *simplePing;

@property (nonatomic, assign) NSUInteger pingCount;
@property (nonatomic, assign) BOOL simplePingInitialized;
@property (nonatomic, assign) BOOL pingingDesired;
@property (nonatomic, assign) BOOL pingingInProgress;

@property (nonatomic, strong) NSDate *pingStartTime;
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
        self.pingingInProgress = NO;
    }
    return self;
}

- (void)startPinging
{
    self.pingingDesired = YES;
    if (self.simplePingInitialized) [self startPingSequence];
}

- (void)startPingSequence
{
    if (!self.pingingInProgress) {
        self.pingingInProgress = YES;
        self.pingCount = 0;
        self.pingStartTime = nil;
        self.totalTime = 0.0;
        [self sendPing];
    }
}

- (void)stopPinging
{
    self.pingingDesired = NO;
    self.pingingInProgress = NO;
}

- (void)sendPing
{
    [self.simplePing sendPingWithData:nil];
}

- (void)pingSequenceFinished
{
    double averageTime = self.totalTime / (double)self.pingCount;
    id delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(pinger:didUpdateWithTime:)]) {
        [delegate pinger:self didUpdateWithTime:averageTime];
    }
    [self stopPinging];
}

#pragma mark SimplePingDelegate methods

- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address
{
    self.simplePingInitialized = YES;
    if (self.pingingDesired) [self startPingSequence];
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error
{
    id delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(pinger:didEncounterError:)]) {
        [delegate pinger:self didEncounterError:error];
    }
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet
{
    self.pingStartTime = [NSDate date];
    self.pingCount++;

    NSLog(@"#%u sent; count %d", (unsigned int) OSSwapBigToHostInt16(((const ICMPHeader *) [packet bytes])->sequenceNumber), self.pingCount );
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet error:(NSError *)error
{
    [self stopPinging];

    id delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(pinger:didEncounterError:)]) {
        [delegate pinger:self didEncounterError:error];
    }
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet
{
    self.totalTime += [[NSDate date] timeIntervalSinceDate:self.pingStartTime];

    NSLog(@"#%u received, count %d", (unsigned int) OSSwapBigToHostInt16([SimplePing icmpInPacket:packet]->sequenceNumber), self.pingCount );

    if (self.pingingDesired && self.pingCount < kBVMPingerNumPings) {
        [self sendPing];
    }
    else if (self.pingCount == kBVMPingerNumPings) {
        [self pingSequenceFinished];
    }
}

@end
