//
//  JNGImageChunkJHDR.m
//  jng-image
//
//  Created by Andrew on 2/12/10.
//  Copyright 2010 2moro mobile. All rights reserved.
//

#import "JNGImageChunkJHDR.h"

@interface JNGImageChunkJHDR (Private)
- (void)parseData:(NSData *)data;
@end


@implementation JNGImageChunkJHDR

@synthesize width, height, colorType;
@synthesize imageSampleDepth, imageCompressionMethod, imageInterlaceMethod;
@synthesize alphaSampleDepth, alphaCompressionMethod, alphaFilterMethod, alphaInterlaceMethod;

- (id)init {
	if(self = [super init]) {
		width = height = 0;
		colorType = JNGImageColorTypeGray;
	}
	return self;
}

- (id)initWithData:(NSData *)data {
	if(self = [self init]) {
		[self parseData:data];
	}
	return self;
}

#pragma mark -

- (void)parseData:(NSData *)data {
	unsigned const char *bytes = [data bytes];
	
	if([data length] != 16) {
		// invalid header data length
		LOG(@"invalid JHDR data (length %d)", [data length]);
		return;
	}
	
	width = NSSwapLong(*(unsigned long *)bytes);
	height = NSSwapLong(*(unsigned long *)(bytes + 4));
	
	colorType              = bytes[8];
	imageSampleDepth       = bytes[9];
	imageCompressionMethod = bytes[10];
	imageInterlaceMethod   = bytes[11];
	alphaSampleDepth       = bytes[12];
	alphaCompressionMethod = bytes[13];
	alphaFilterMethod      = bytes[14];
	alphaInterlaceMethod   = bytes[15];
	
	LOG(@"size: (%d,%d) colorType:%d alphaSampleDepth:%d alphaCompressionMethod:%d", width, height, colorType, alphaSampleDepth, alphaCompressionMethod);
}

@end
