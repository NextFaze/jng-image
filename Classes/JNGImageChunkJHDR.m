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

	sscanf((char *)(bytes + 8), "%c%c%c%c%c%c%c%c",
		  (char *)&colorType, &imageSampleDepth, &imageCompressionMethod, &imageInterlaceMethod,
		  &alphaSampleDepth, &alphaCompressionMethod, &alphaFilterMethod, &alphaInterlaceMethod);
	
	LOG(@"size: (%d,%d) colorType:%d alphaSampleDepth:%d", width, height, colorType, alphaSampleDepth);
}

@end
