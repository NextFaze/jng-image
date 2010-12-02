//
//  JNGImage.m
//  jng-image
//
//  Created by Andrew Williams on 26/11/10.
//  Copyright 2010 2moro mobile. All rights reserved.
//

#import "JNGImage.h"
#import "JNGImageParser.h"
#import "JNGImageChunk.h"
#import "JNGImageCache.h"
#import "JNGImagePNG.h"

@interface JNGImage (Private)
- (id)initWithData:(NSData *)data;
- (void)readData:(NSData *)data;
@end

@implementation JNGImage

@synthesize image;

#pragma mark Class methods

static JNGImageCache *cache = nil;

+ (void)initialize {
	cache = [[JNGImageCache alloc] init];
}

+ (JNGImage *)imageNamed:(NSString *)name {
	JNGImage *jng = [cache imageForKey:name];
	if(jng) {
		LOG(@"returning cached image %@", name);
		return jng;
	}
	
	// not cached, load image	
	NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
	NSString *path = [NSString stringWithFormat:@"%@/%@", resourcePath, name];
	jng = [self imageWithContentsOfFile:path];
	[cache setImage:jng forKey:name];
	
	return jng;
}

+ (JNGImage *)imageWithContentsOfFile:(NSString *)filename {
	return [self imageWithData:[NSData dataWithContentsOfFile:filename]];
}

+ (JNGImage *)imageWithData:(NSData *)data {
	return [[(JNGImage *)[JNGImage alloc] initWithData:data] autorelease];
}

#pragma mark Public instance methods

- (id)init {
	if(self = [super init]) {
		image = nil;
		header = nil;
	}
	return self;
}

- (id)initWithData:(NSData *)data {	
	if(data == nil) return nil;   // invalid data

	if(self = [self init]) {
		[self readData:data];
		if(image == nil) {
			[self release];
			return nil;    // could not read image
		}
	}
	return self;
}

- (void)dealloc {
	[image release];
	[header release];
	[super dealloc];
}

#pragma mark Private

// Returns a copy of the given image, adding an alpha channel
- (UIImage *)imageWithAlpha:(UIImage *)img {
	if(img == nil) return nil;
	
    CGImageRef imageRef = img.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
	size_t bytesPerPixel = 4;
    size_t bitsPerComponent = 8;
	size_t bytesPerRow = width * bytesPerPixel;
	size_t imageSize;
	
	// round up bytesPerRow to nearest multiple of 16
	if(bytesPerRow % 16)
		bytesPerRow += 16 - bytesPerRow % 16;
	
	imageSize = bytesPerRow * height;
	
	LOG(@"bytesPerRow: %d, imageSize: %d", bytesPerRow, imageSize);
	
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB(); //CGImageGetColorSpace(imageRef);
	
	void *data = calloc(imageSize, 1);
	if(data == nil) {
		LOG(@"memory allocation error");
		return nil;
	}
	
    CGContextRef offscreenContext = CGBitmapContextCreate(data,
                                                          width,
                                                          height,
                                                          bitsPerComponent,
                                                          bytesPerRow,
                                                          colorspace,
                                                          kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast);
    
    // Draw the image into the context and retrieve the new image, which will now have an alpha layer
    CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(offscreenContext);
    UIImage *imageWithAlpha = [UIImage imageWithCGImage:imageRefWithAlpha];
    
    // Clean up
	CGColorSpaceRelease(colorspace);
    CGContextRelease(offscreenContext);
    CGImageRelease(imageRefWithAlpha);
    free(data);
	
    return imageWithAlpha;
}

// read jng2moro format
// sets self.image and self.header
- (void)readData:(NSData *)data {
	
	NSError *error = nil;
	JNGImageParser *parser = [(JNGImageParser *)[JNGImageParser alloc] initWithData:data];
	[parser parse:&error];
		
	// get alpha data
	NSArray *alphaIDAT = [parser chunksNamed:@"IDAT"];
	NSData *alphaData2 = [parser alphajpeg]; 
	NSData *jpegData1 = [parser jpeg1];  // jpeg2
	NSData *jpegData2 = [parser jpeg2];  // 12 bit
	BOOL hasAlpha = [alphaIDAT count] || alphaData2;

	header = [[parser header] retain];  // retain header information
	
	[parser release];

	if(!(jpegData1 || jpegData2)) {
		// no jpeg data found - can't create an image
		return;
	}
	
	// use 12 bit (jpegData2) in preference (higher quality)
	UIImage *img = [UIImage imageWithData:jpegData2 ? jpegData2 : jpegData1];

	if(hasAlpha) {
		// image contains alpha data.
		// apply alpha channel
		NSData *alphaData = nil;

		LOG(@"found alpha channel");
		img = [self imageWithAlpha:img];  // add alpha channel to image

		if([alphaIDAT count] > 0) {
			// convert alpha data (IDAT chunk) to png image
			JNGImagePNG *png = [[JNGImagePNG alloc] init];
			png.colorType = JNGImagePNGColorTypeGrayscale;
			png.width = header.width;
			png.height = header.height;
			png.bitDepth = header.alphaSampleDepth;
			
			for(JNGImageChunk *chunk in alphaIDAT) {
				[png addChunk:chunk];
			}
			alphaData = [png data];
			[png release];
		}
		else {
			// else alpha data is jpeg format
			LOG(@"JDAA alpha data");
			alphaData = alphaData2;
		}
		
		if(alphaData) {
			// combine image with alpha mask image
			UIImage *alpha = [UIImage imageWithData:alphaData];
			CGImageRef masked = CGImageCreateWithMask([img CGImage], [alpha CGImage]);
			img = [UIImage imageWithCGImage:masked];
			CGImageRelease(masked);
		}
	}
	
	image = [img retain];
}

#pragma mark readers

- (int)imageSampleDepth {
	return header.imageSampleDepth;
}
- (int)imageInterlaceMethod {
	return header.imageInterlaceMethod;
}
- (int)alphaSampleDepth {
	return header.alphaSampleDepth;
}
- (int)alphaCompressionMethod {
	return header.alphaCompressionMethod;
}

@end
