//
//  OGAAdQualityUniformColorRectAlgorithm.m
//  OguryAds
//
//  Created by Jerome TONNELIER on 26/08/2025.
//  Copyright © 2025 Ogury Ltd. All rights reserved.
//

#import "OGAAdQualityUniformColorRectAlgorithm.h"
#import "OGALog.h"
#import "OGAAdLogMessage.h"
#import "OGAMonitoringDispatcher.h"
#import "OGAAdQualityConstants.h"
#import "OguryBannerAdSize.h"

@interface OGAAdQualityUniformColorRectAlgorithm ()
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) NSNumber *devianceMax;
@property(nonatomic, strong) NSString *uniformHexColor;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@end

@implementation UIView (Snapshot)

/// Added this helper method for Unit tests mainly.
/// In a real world scenario, we use [self draw...] which renders both videos and images neatly.
/// But in a test scenario (using an UIImageView passed along the method), then it fails because the image is not added to the main view, hence not rendered.
/// In that case, we must use layer drawing in order to get an image from the view
- (UIImage *)snapshot {
    UIImage *snapshot = nil;
    // 1. Try UIKit rendering (best for complex hierarchies, video, blurs)
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    BOOL success = [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // 2. If UIKit failed or returned nil/empty, fallback to CALayer rendering
    if (!success || !snapshot) {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        snapshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return snapshot;
}
@end

@implementation OGAAdQualityUniformColorRectAlgorithm
@synthesize algo, startDelay, threshold, rectSize, duration, uniformHexColor, allowedFormats;

- (instancetype)initWithSize:(CGSize)size
                   threshold:(NSNumber *)threshold
                  startDelay:(NSNumber *)delay
              allowedFormats:(NSArray<NSString *> *)allowedFormats {
    return [self initWithSize:size
                    threshold:threshold
                   startDelay:delay
               allowedFormats:allowedFormats
         monitoringDispatcher:[OGAMonitoringDispatcher shared]
                          log:OGALog.shared];
}

- (instancetype)initWithSize:(CGSize)size
                   threshold:(NSNumber *)threshold
                  startDelay:(NSNumber *)delay
              allowedFormats:(NSArray<NSString *> *)allowedFormats
        monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher
                         log:(OGALog *)log {
    if (self = [super init]) {
        self.algo = OguryAdQualityAlgorithmUniformColorRect;
        self.startDelay = delay;
        self.threshold = threshold;
        self.devianceMax = @0;
        self.rectSize = size;
        self.log = log;
        self.allowedFormats = allowedFormats;
        self.monitoringDispatcher = monitoringDispatcher;
        self.uniformHexColor = @"#";
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    NSString *algo = [coder decodeObjectForKey:@"name"];
    if (![algo isEqualToString:OguryAdQualityAlgorithmUniformColorRect]) {
        return nil;
    }
    NSDictionary *params = [coder decodeObjectForKey:@"params"];
    NSNumber *startDelay = params[@"start_after_ms"];
    NSNumber *threshold = params[@"threshold"];
    NSNumber *width = params[@"width"];
    NSNumber *height = params[@"height"];
    NSArray<NSString *> *formats = [coder decodeObjectForKey:@"format"];
    if (params == nil || startDelay == nil || threshold == nil || width == nil || height == nil || formats == nil) {
        return nil;
    }
    return [self initWithSize:CGSizeMake(width.doubleValue, height.doubleValue)
                    threshold:threshold
                   startDelay:startDelay
               allowedFormats:formats];
}

// OGAJSONModel
+ (OGAJSONKeyMapper *)keyMapper {
    return [[OGAJSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"algo" : @"name",
        @"startDelay" : @"params.start_after_ms",
        @"threshold" : @"params.threshold",
        @"allowedFormats" : @"format",
    }];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err {
    self = [self initWithSize:CGSizeMake([dict[@"params"][@"width"] floatValue], [dict[@"params"][@"height"] floatValue])
                    threshold:dict[@"params"][@"threshold"]
                   startDelay:dict[@"params"][@"start_after_ms"]
               allowedFormats:dict[@"format"]];
    return self;
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return true;
}

- (BOOL)computationEnabledFor:(OGAAdConfiguration *)adConfiguration {
    NSString *adType = [adConfiguration getAdTypeString];
    if ([adType isEqualToString:OGAAdConfigurationAdTypeInterstitial] || [adType isEqualToString:OGAAdConfigurationAdTypeRewarded] || [adType isEqualToString:OGAAdConfigurationAdTypeThumbnailAd]) {
        return [self.allowedFormats containsObject:adType];
    } else if ([adType isEqualToString:OGAAdConfigurationAdTypeStandardBanners]) {
        if ([self.allowedFormats containsObject:@"standard_banners_320x50"]) {
            return CGSizeEqualToSize(adConfiguration.size, [OguryBannerAdSize.small_banner_320x50 getSize]);
        } else if ([self.allowedFormats containsObject:@"standard_banners_300x250"]) {
            return CGSizeEqualToSize(adConfiguration.size, [OguryBannerAdSize.mrec_300x250 getSize]);
        }
    }
    return NO;
}

- (void)logMessage:(NSString *)message adConfiguration:(OGAAdConfiguration *)adConfiguration result:(OGAAdQualityResult *_Nullable)result {
    NSMutableArray<OguryLogTag *> *tags = [@[] mutableCopy];
    [tags addObject:[OguryLogTag tagWithKey:OguryAdQualityAlgorithmKey value:self.algo]];
    if (result != nil) {
        [tags addObject:[OguryLogTag tagWithKey:@"blank ad" value:result.success ? @"No" : @"Yes"]];
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

- (void)performAdQualityCheckOn:(UIView *)view adConfiguration:(OGAAdConfiguration *)adConfiguration completion:(AdQualityAlgorithmCompletionBlock)completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.startDelay.intValue * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self logMessage:@"Start computing" adConfiguration:adConfiguration result:nil];
        NSDate *start = [NSDate date];
        CGRect targetRect = CGRectMake((view.bounds.size.width / 2) - self.rectSize.width / 2,
                                       (view.bounds.size.height / 2) - self.rectSize.height / 2,
                                       self.rectSize.width,
                                       self.rectSize.height);
        // get image on main thread
        UIImage *image = [view snapshot];
        // perform computation on background thread
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            BOOL imageHasUniformColor = [self imageIsUniformColor:image rect:targetRect];
            OGAAdQualityResult *result = [[OGAAdQualityResult alloc] init];
            result.success = !imageHasUniformColor;
            result.algo = self.algo;
            result.duration = @(@([[NSDate date] timeIntervalSinceDate:start] * 1000).intValue);
            result.devianceMax = self.devianceMax;
            [self logMessage:@"End computing" adConfiguration:adConfiguration result:result];
            [self sendMonitoringEventFor:result adConfiguration:adConfiguration];
            completion(result);
        });
    });
}

- (void)sendMonitoringEventFor:(OGAAdQualityResult *)result adConfiguration:(OGAAdConfiguration *)adConfiguration {
    OGAMutableOrderedDictionary *dict = [OGAMutableOrderedDictionary new];
    dict[OguryAdQualityMonitoringKeyAlgo] = self.algo;
    dict[OguryAdQualityMonitoringKeyBlankAd] = result.success ? @(NO) : @(YES);
    dict[OguryAdQualityMonitoringKeyColor] = self.uniformHexColor;
    dict[OguryAdQualityMonitoringKeyParams] = [NSString stringWithFormat:@"%0.0fx%0.0f;%@;%@",
                                               rectSize.width,
                                               rectSize.height,
                                               self.startDelay,
                                               self.threshold];
    dict[OguryAdQualityMonitoringKeyDeviance] = result.devianceMax;
    dict[OguryAdQualityMonitoringKeyDuration] = result.duration;
    [self.monitoringDispatcher sendAdQualityEvent:OGAShowEventAdQualityBlankAd
                                  adConfiguration:adConfiguration
                                          details:dict];
}

- (BOOL)imageIsUniformColor:(UIImage *)image rect:(CGRect)rect {
    if (!image.CGImage) {
        return NO;
    }
    
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
    if (!cgImage) {
        return NO;
    }
    
    const size_t width = CGImageGetWidth(cgImage);
    const size_t height = CGImageGetHeight(cgImage);
    const size_t bytesPerPixel = 4;
    const size_t bitsPerComponent = 8;
    const size_t bytesPerRow = width * bytesPerPixel;
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    if (!cs) {
        CGImageRelease(cgImage);
        return NO;
    }
    
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
        CGImageRelease(cgImage);
        return NO;
    }
    
    CGContextDrawImage(ctx, CGRectMake(0, 0, width, height), cgImage);
    
    NSUInteger pixelCount = width * height;
    NSUInteger randomIndex = arc4random_uniform((u_int32_t)pixelCount);
    size_t offset = randomIndex * bytesPerPixel;
    unsigned char r0 = rawData[offset];
    unsigned char g0 = rawData[offset + 1];
    unsigned char b0 = rawData[offset + 2];
    uniformHexColor = [NSString stringWithFormat:@"#%02X%02X%02X", r0, g0, b0];
    
    BOOL uniform = YES;
    for (size_t y = 0; y < height && uniform; y++) {
        for (size_t x = 0; x < width; x++) {
            size_t offset = (y * bytesPerRow) + (x * bytesPerPixel);
            unsigned char r = rawData[offset];
            unsigned char g = rawData[offset + 1];
            unsigned char b = rawData[offset + 2];
            int deviance = abs(r - r0) + abs(b - b0) + abs(g - g0);
            if (deviance > self.devianceMax.intValue) {
                self.devianceMax = @(deviance);
            }
            if (deviance > self.threshold.intValue) {
                uniform = NO;
                break;
            }
        }
    }
    
    // Cleanup
    CGContextRelease(ctx);
    CGColorSpaceRelease(cs);
    CGImageRelease(cgImage);
    free(rawData);
    
    return uniform;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[OGAAdQualityUniformColorRectAlgorithm class]] == NO) {
        return NO;
    }
    OGAAdQualityUniformColorRectAlgorithm *algo = (OGAAdQualityUniformColorRectAlgorithm *)object;
    return CGSizeEqualToSize(self.rectSize, algo.rectSize) &&
    self.threshold.intValue == algo.threshold.intValue &&
    self.startDelay.intValue == algo.startDelay.intValue &&
    [self.allowedFormats isEqual:algo.allowedFormats];
}

@end
