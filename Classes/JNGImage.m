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
    CGImageRef imageRef = img.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    // The bitsPerComponent and bitmapInfo values are hard-coded to prevent an "unsupported parameter combination" error
    CGContextRef offscreenContext = CGBitmapContextCreate(NULL,
                                                          width,
                                                          height,
                                                          8,
                                                          0,
                                                          CGImageGetColorSpace(imageRef),
                                                          kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    
    // Draw the image into the context and retrieve the new image, which will now have an alpha layer
    CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(offscreenContext);
    UIImage *imageWithAlpha = [UIImage imageWithCGImage:imageRefWithAlpha];
    
    // Clean up
    CGContextRelease(offscreenContext);
    CGImageRelease(imageRefWithAlpha);
    
    return imageWithAlpha;
}

// read JNG format
// sets self.image and self.header
- (void)readData:(NSData *)data {
	
	NSError *error = nil;
	JNGImageParser *parser = [[(JNGImageParser *)[JNGImageParser alloc] initWithData:data] autorelease];
	[parser parse:&error];
		
	// get alpha data
	NSArray *alphaIDAT = [parser chunksNamed:@"IDAT"];
	NSData *alphaData2 = [parser alphajpeg]; 
	NSData *jpegData1 = [parser jpeg1];  // jpeg2
	NSData *jpegData2 = [parser jpeg2];  // 12 bit
	BOOL hasAlpha = [alphaIDAT count] || alphaData2;

	header = [[parser header] retain];  // retain header information
	
	if(!(jpegData1 || jpegData2)) {
		// no jpeg data found - can't create an image
		return;
	}
	
	// use 12 bit (jpegData2) in preference (higher quality)
	// TODO: does UIImage recognise 12 bit jpeg?
	UIImage *img = [UIImage imageWithData:jpegData2 ? jpegData2 : jpegData1];

	// UIImage doesn't perform gamma correction etc on pngs, so this part is pointless
	/*
	// convert to PNG
	NSData *imgPng = UIImagePNGRepresentation(img);

	// parse image as png format
	JNGImagePNG *png = [[JNGImagePNG alloc] init];
	JNGImageParser *parser2 = [[[JNGImageParser alloc] initWithData:imgPng] autorelease];
	[parser2 parse:nil];

	// add all the chunks to png
	for(JNGImageChunk *chunk in parser2.chunks) {
		[png addChunk:chunk];
	}
	// now add ancillary chunks from the JNG to the png (gAMA, etc)
	for(JNGImageChunk *chunk in parser.chunks) {
		if([chunk isAncillary]) {
			[png addChunk:chunk];
		}
	}
	LOG(@"png: %@", png);

	// convert back to a UIImage
	img = [UIImage imageWithData:[png data]];
	[png release];
	 */
	
	if(hasAlpha) {
		// image contains alpha data.
		// apply alpha channel
		NSData *alphaData = nil;

		LOG(@"found alpha channel");
		img = [self imageWithAlpha:img];  // add alpha channel to image

		if([alphaIDAT count] > 0) {
			// convert alpha data (IDAT chunk) to png image
			JNGImagePNG *pngAlpha = [[JNGImagePNG alloc] init];
			pngAlpha.colorType = JNGImagePNGColorTypeGrayscale;
			pngAlpha.width = header.width;
			pngAlpha.height = header.height;
			pngAlpha.bitDepth = header.alphaSampleDepth;
			
			for(JNGImageChunk *chunk in alphaIDAT) {
				[pngAlpha addChunk:chunk];
			}
			alphaData = [pngAlpha data];
			[pngAlpha release];
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
