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
@property(nonatomic, strong) NSNumber *devianceMax;
@property(nonatomic, strong) NSString *uniformHexColor;
@end

@implementation OGAAdQualityUniformColorRectAlgorythm
@synthesize algo, startDelay, threshold, rectSize, duration, uniformHexColor;

- (instancetype)initWithSize:(CGSize)size threshold:(NSNumber*)threshold startDelay:(NSNumber*)delay {
    return [self initWithSize:size threshold:threshold startDelay:delay log:OGALog.shared];
}

- (instancetype)initWithSize:(CGSize)size threshold:(NSNumber*)threshold startDelay:(NSNumber*)delay log:(OGALog *)log {
    if (self = [super init]) {
        self.algo = OguryAdQualityAlgorythmUniformColorRect;
        self.startDelay = delay;
        self.threshold = threshold;
        self.devianceMax = threshold;
        self.rectSize = size;
        self.log = log;
    }
    return self;
}

- (void)logMessage:(NSString *)message adConfiguration:(OGAAdConfiguration *)adConfiguration result:(OGAAdQualityResult * _Nullable)result {
    NSMutableArray<OguryLogTag *> * tags = [@[] mutableCopy];
    [tags addObject:[OguryLogTag tagWithKey:OguryAdQualityAlgorythmKey value:self.algo]];
    if (result != nil) {
        [tags addObject:[OguryLogTag tagWithKey:@"blank ad" value:result.sucess ? @"No" : @"Yes"]];
        [tags addObject:[OguryLogTag tagWithKey:@"duration" value:result.duration]];
        [tags addObject:[OguryLogTag tagWithKey:@"deviance" value:result.devianceMax]];
        [tags addObject:[OguryLogTag tagWithKey:@"uniformColor" value:self.uniformHexColor]];
    }
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                         adConfiguration:adConfiguration
                                                 logType:OguryLogTypeInternal
                                                 message:message
                                                    tags:tags]];
}

- (void)performAdQualityCheckOn:(UIView *)view adConfiguration:(OGAAdConfiguration *)adConfiguration completion:(AdQualityAlgorythmCompletionBlock)completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.startDelay.intValue * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self logMessage:@"Start computing" adConfiguration:adConfiguration result:nil];
        NSDate *start = [NSDate date];
        CGRect targetRect = CGRectMake((view.bounds.size.width / 2) - self.rectSize.width / 2,
                                       (view.bounds.size.height / 2) - self.rectSize.height / 2,
                                       self.rectSize.width,
                                       self.rectSize.height);
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        BOOL imageHasUniformColor = [self imageIsUniformColor:image rect:targetRect];
        OGAAdQualityResult *result = [[OGAAdQualityResult alloc] init];
        result.sucess = !imageHasUniformColor;
        result.duration = @(@([[NSDate date] timeIntervalSinceDate:start] * 1000).intValue);
        result.devianceMax = self.devianceMax;
        [self logMessage:@"End computing" adConfiguration:adConfiguration result:result];
        completion(result);
    });
}

- (BOOL)imageIsUniformColor:(UIImage *)image rect:(CGRect)rect {
    if (!image.CGImage) { return NO; }
    
    // Convert rect from points → pixels
    CGFloat scale = image.scale > 0 ? image.scale : [UIScreen mainScreen].scale;
    CGRect rectInPixels = CGRectMake(rect.origin.x * scale,
                                     rect.origin.y * scale,
                                     rect.size.width * scale,
                                     rect.size.height * scale);
    
    // Intersect with image bounds
    size_t imgW = CGImageGetWidth(image.CGImage);
    size_t imgH = CGImageGetHeight(image.CGImage);
    CGRect imgBoundsPx = CGRectMake(0, 0, imgW, imgH);
    CGRect cropRect = CGRectIntersection(rectInPixels, imgBoundsPx);
    if (CGRectIsEmpty(cropRect)) {
        return NO;
    }
    
    CGImageRef cgImage = CGImageCreateWithImageInRect(image.CGImage, cropRect);
    if (!cgImage) { return NO; }
    
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
    uniformHexColor = [NSString stringWithFormat:@"#%02X%02X%02X", r0, g0, b0];
    
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
                self.devianceMax = @(deviance);
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
