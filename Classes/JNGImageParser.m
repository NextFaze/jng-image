//
//  JNGImageParser.m
//  jng-image
//
//  Created by Andrew Williams on 26/11/10.
//  Copyright 2010 2moro mobile. All rights reserved.
//

#import "JNGImageParser.h"
#import "JNGImageChunk.h"
#import "zlib.h"

#define JngImageSignature {0x8b,0x4a,0x4e,0x47,0x0d,0x0a,0x1a,0x0a}

@implementation JNGImageParser

@synthesize data, chunks;

- (id)init {
	if(self = [super init]) {
		self.data = nil;
		self.chunks = nil;
	}
	return self;
}

- (id)initWithData:(NSData *)d {
	if(self = [self init]) {
		self.data = d;
	}
	return self;
}

- (void)dealloc {
	[data release];
	[chunks release];
	
	[super dealloc];
}

#pragma mark -

// return concatenated chunk data
- (NSData *)chunkData:(NSString *)chunkName afterJSEP:(BOOL)afterJSEP {
	NSMutableData *dat = [NSMutableData data];
	for(JNGImageChunk *chunk in chunks) {
		if([chunk.name isEqualToString:chunkName] && chunk.afterJSEP == afterJSEP)
			[dat appendData:chunk.data];
	}
	return [dat length] == 0 ? nil : dat;
}

- (NSArray *)chunksNamed:(NSString *)name {
	NSMutableArray *list = [NSMutableArray array];
	for(JNGImageChunk *chunk in chunks) {
		if([chunk.name isEqualToString:name])
			[list addObject:chunk];
	}
	return list;
}

- (JNGImageChunkJHDR *)header {
	NSData *chunk = [self chunkData:@"JHDR" afterJSEP:NO];

	if(chunk == nil) return nil;
	JNGImageChunkJHDR *header = [[JNGImageChunkJHDR alloc] initWithData:chunk];
	return [header autorelease];
}

- (NSData *)chunkData:(NSString *)chunkName {
	return [self chunkData:chunkName afterJSEP:NO];
}

// return jpeg data (before JSEP)
- (NSData *)jpeg1 {
	return [self chunkData:@"JDAT" afterJSEP:NO];
}

// return jpeg data (after JSEP, 12 bit)
- (NSData *)jpeg2 {
	return [self chunkData:@"JDAT" afterJSEP:YES];
}

// return alpha channel data (as a PNG IDAT)
- (NSData *)alphapng {
	return [self chunkData:@"IDAT"];
}

// return alpha channel data (as a JPEG)
- (NSData *)alphajpeg {
	return [self chunkData:@"JDAA"];
}

// return true if signature is ok
- (BOOL)testSignature {
	unsigned char signature[8] = JngImageSignature;
	return ([data length] >= 8 && !memcmp([data bytes], signature, 8)) ? YES : NO;
}

// TODO: return error objects
- (void)parse:(NSError **)error {
	unsigned const char *bytes = [data bytes];
	unsigned const char *ptr = bytes;
	NSMutableArray *chunkList = [NSMutableArray array];
	
	LOG(@"parsing %d bytes", [data length]);
	
	// check signature
	if(![self testSignature]) {
		// invalid signature
		LOG(@"invalid signature");
		return;
	}
	
	if([data length] <= 8) {
		// not enough data
		LOG(@"data too small");
		return;
	}
	
	ptr += 8;  // skip past signature

	// read chunks
	while(ptr + 16 < bytes + [data length]) {  // (16 == minimum chunk length)
		// read chunk header
		unsigned long len = NSSwapLong(*(unsigned long *)ptr);
		NSString *name = [NSString stringWithFormat:@"%-4.4s", ptr + 4];
		NSData *dat = [NSData dataWithBytes:(ptr + 8) length:len];
		
		if(ptr + 8 + len + 4 > bytes + [data length]) {
			// invalid chunk length
			LOG(@"truncated data?");
			return;
		}

		ptr += 8 + len;
		unsigned long crc = NSSwapLong(*(unsigned long *)ptr);
		ptr += 4;
		
		LOG(@"chunk name: %@", name);
		LOG(@"chunk length: %ld", len);
				
		JNGImageChunk *chunk = [[JNGImageChunk alloc] init];
		chunk.name = name;
		chunk.crc = crc;
		chunk.data = dat;
		[chunkList addObject:chunk];

		// crc check
		unsigned long actualCrc = [chunk calculateCrc];
		[chunk release];

		if(actualCrc != crc) {
			LOG(@"%@: CRC error (expected %d, got %d)", name, crc, actualCrc);
			return;
		}
	}
	self.chunks = chunkList;
}

@end
