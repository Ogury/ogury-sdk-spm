//
//  OGAAdQualityUniformColorRectAlgorythm.m
//  OguryAds
//
//  Created by Jerome TONNELIER on 26/08/2025.
//  Copyright © 2025 Ogury Ltd. All rights reserved.
//

#import "OGAAdQualityUniformColorRectAlgorythm.h"
#import "OGALog.h"
#import "OGAAdLogMessage.h"

@interface OGAAdQualityUniformColorRectAlgorythm()
@property(nonatomic, strong) OGALog *log;
@end

@implementation OGAAdQualityUniformColorRectAlgorythm
@synthesize algo, startDelay, threshold, rectSize, duration;

- (instancetype)initWithSize:(CGSize)size threshold:(NSNumber*)threshold startDelay:(NSNumber*)delay {
    return [self initWithSize:size threshold:threshold startDelay:startDelay log:OGALog.shared];
}

- (instancetype)initWithSize:(CGSize)size threshold:(NSNumber*)threshold startDelay:(NSNumber*)delay log:(OGALog *)log {
    if (self = [super init]) {
        self.algo = OguryAdQualityAlgorythmUniformColorRect;
        self.startDelay = startDelay;
        self.threshold = threshold;
        self.rectSize = size;
        self.log = log;
    }
    return self;
}

- (void)logMessage:(NSString *)message adConfiguration:(OGAAdConfiguration *)adConfiguration result:(OGAAdQualityResult * _Nullable)result {
    NSMutableArray<OguryLogTag *> * tags = [@[] mutableCopy];
    [tags addObject:[OguryLogTag tagWithKey:OguryAdQualityAlgorythmKey value:self.algo]];
    if (result != nil) {
        [tags addObject:[OguryLogTag tagWithKey:@"result" value:@(result.sucess)]];
        [tags addObject:[OguryLogTag tagWithKey:@"duration" value:result.duration]];
    }
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                         adConfiguration:adConfiguration
                                                 logType:OguryLogTypeInternal
                                                 message:message
                                                    tags:tags]];
}

- (void)performAdQualityCheckOn:(UIView *)view adConfiguration:(OGAAdConfiguration *)adConfiguration completion:(AdQualityAlgorythmCompletionBlock)completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.startDelay.intValue * MSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self logMessage:@"🐳 Start computing" adConfiguration:adConfiguration result:nil];
        NSDate *start = [NSDate date];
        CGRect targetRect = CGRectMake((view.bounds.size.width / 2) - self.rectSize.width / 2,
                                       (view.bounds.size.height / 2) - self.rectSize.height / 2,
                                       self.rectSize.width,
                                       self.rectSize.height);
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithBounds:targetRect];
        UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
            [view.layer renderInContext:rendererContext.CGContext];
        }];
        BOOL imageHasUniformColor = [self imageIsUniformColor:image];
        OGAAdQualityResult *result = [[OGAAdQualityResult alloc] init];
        result.sucess = !imageHasUniformColor;
        result.duration = @([[NSDate date] timeIntervalSinceDate:start]);
        [self logMessage:@"🐳 End computing" adConfiguration:adConfiguration result:result];
        completion(result);
    });
}

- (BOOL)imageIsUniformColor:(UIImage *)image {
    if (!image.CGImage) { return NO; }
    
    CGImageRef cgImage = image.CGImage;
    const size_t width  = CGImageGetWidth(cgImage);
    const size_t height = CGImageGetHeight(cgImage);
    const size_t bytesPerPixel = 4;
    const size_t bitsPerComponent = 8;
    const size_t bytesPerRow = width * bytesPerPixel;
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    if (!cs) { return NO; }
    
    unsigned char *rawData = (unsigned char *)calloc(height * width * bytesPerPixel, sizeof(unsigned char));
    CGContextRef ctx = CGBitmapContextCreate(rawData,
                                             width,
                                             height,
                                             bitsPerComponent,
                                             bytesPerRow,
                                             cs,
                                             kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    if (!ctx) {
        free(rawData);
        CGColorSpaceRelease(cs);
        return NO;
    }
    
    CGContextDrawImage(ctx, CGRectMake(0, 0, width, height), cgImage);
    
    NSUInteger pixelCount = width * height;
    NSUInteger randomIndex = arc4random_uniform((u_int32_t)pixelCount);
    size_t offset = randomIndex * bytesPerPixel;
    unsigned char r0 = rawData[offset];
    unsigned char g0 = rawData[offset + 1];
    unsigned char b0 = rawData[offset + 2];
    unsigned char a0 = rawData[offset + 3];
    
    BOOL uniform = YES;
    for (size_t y = 0; y < height && uniform; y++) {
        for (size_t x = 0; x < width; x++) {
            size_t offset = (y * bytesPerRow) + (x * bytesPerPixel);
            unsigned char r = rawData[offset];
            unsigned char g = rawData[offset + 1];
            unsigned char b = rawData[offset + 2];
            unsigned char a = rawData[offset + 3];
            int deviance = abs(r - r0) + abs(b - b0) + abs(g - g0) + abs(a - a0);
            if (deviance > self.threshold.intValue) {
                uniform = NO;
                break;
            }
        }
    }
    
    // Cleanup
    CGContextRelease(ctx);
    CGColorSpaceRelease(cs);
    free(rawData);
    
    return uniform;
}

@end
