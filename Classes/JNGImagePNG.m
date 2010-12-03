//
//  JNGImagePNG.m
//  jng-image
//
//  Created by Andrew on 2/12/10.
//  Copyright 2010 2moro mobile. All rights reserved.
//

#import "JNGImagePNG.h"

#define PNGImageSignature {0x89,0x50,0x4e,0x47,0x0d,0x0a,0x1a,0x0a}

@implementation JNGImagePNG

@synthesize chunks, colorType;
@synthesize width, height, bitDepth, compressionMethod, filterMethod, interlaceMethod;

- (id)init {
	if(self = [super init]) {
		chunks = [[NSMutableArray alloc] init];
		colorType = JNGImagePNGColorTypeRGB;
		width = height = 0;
		bitDepth = 0;
		compressionMethod = filterMethod = interlaceMethod = 0;
	}
	return self;
}

- (void)dealloc {
	[chunks release];
	[super dealloc];
}

#pragma mark -

- (NSString *)description {
	NSMutableString *desc = [NSMutableString string];
	for(JNGImageChunk *chunk in chunks) {
		[desc appendFormat:@"%@(%d) ", chunk.name, chunk.data.length];
	}
	return desc;
}

- (JNGImageChunk *)chunkNamed:(NSString *)cname {
	for(JNGImageChunk *chunk in chunks) {
		if([chunk.name isEqualToString:cname])
			return chunk;
	}
	return nil;
}

- (void)addChunk:(JNGImageChunk *)chunk {
	if([chunk isAncillary]) {
		// assume only one of this ancillary chunk type is allowed.
		// should be true for our purposes, as the only ancillary chunks we need to copy from JNG are single.
		// remove any existing chunks of this type from the list
		JNGImageChunk *existing = [self chunkNamed:chunk.name];
		if(existing) [chunks removeObject:chunk];
	}
	// add chunk to list
	[chunks addObject:chunk];
}

// create an IHDR chunk for this image
- (JNGImageChunk *)ihdr {
	NSMutableData *ihdrData = [NSMutableData data];
	unsigned long widthNet  = NSSwapLong((unsigned long)width);
	unsigned long heightNet = NSSwapLong((unsigned long)height);
	unsigned char hdrdat[5];
	
	snprintf((char *)hdrdat, 5, "%c%c%c%c%c", bitDepth, colorType, compressionMethod, filterMethod, interlaceMethod);
	[ihdrData appendBytes:&widthNet length:4];
	[ihdrData appendBytes:&heightNet length:4];
	[ihdrData appendBytes:hdrdat length:5];
	
	JNGImageChunk *ihdr = [[JNGImageChunk alloc] init];
	ihdr.name = @"IHDR";
	ihdr.data = ihdrData;
	ihdr.crc = [ihdr calculateCrc];

	return [ihdr autorelease];
}

// return IEND chunk 
- (JNGImageChunk *)iend {
	JNGImageChunk *iend = [[JNGImageChunk alloc] init];
	iend.name = @"IEND";
	iend.data = nil;
	iend.crc = [iend calculateCrc];
	return [iend autorelease];
}

- (void)addChunk:(JNGImageChunk *)chunk toData:(NSMutableData *)data {
	NSData *cdat = [chunk data];
	unsigned long len = NSSwapLong((unsigned long)[cdat length]);
	unsigned long crc = NSSwapLong(chunk.crc);
	
	LOG(@"appending chunk: %@ to data", chunk.name);
	
	[data appendBytes:&len length:4];
	[data appendBytes:[chunk.name UTF8String] length:4];
	[data appendData:cdat];
	[data appendBytes:&crc length:4];
}

// return png image representation
- (NSData *)data {
	NSMutableData *data = [NSMutableData data];
	NSMutableArray *chunkList = [NSMutableArray arrayWithArray:chunks];
	unsigned char signature[8] = PNGImageSignature;
	
	[data appendBytes:signature length:8];
	
	// prepend header chunk
	JNGImageChunk *ihdr = [self chunkNamed:@"IHDR"];
	if(ihdr == nil) ihdr = [self ihdr];
	[self addChunk:ihdr toData:data];
	
	// append chunks
	// chunk ordering:
	//   IHDR, all ancillary chunks, PLTE, IDAT, IEND
	for(JNGImageChunk *chunk in chunkList) {
		if([chunk isAncillary])
			[self addChunk:chunk toData:data];
	}

	// add PLTE
	JNGImageChunk *plte = [self chunkNamed:@"PLTE"];
	if(plte) [self addChunk:plte toData:data];
	
	// add IDAT chunks
	for(JNGImageChunk *chunk in chunkList) {
		if([chunk.name isEqualToString:@"IDAT"]) {
			[self addChunk:chunk toData:data];
		}
	}
	
	// add IEND
	[self addChunk:[self iend] toData:data];
	
	return data;
}

@end
