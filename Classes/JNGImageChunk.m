//
//  JNGImageChunk.m
//  jng-image
//
//  Created by Andrew Williams on 26/11/10.
//  Copyright 2010 2moro mobile. All rights reserved.
//

#import "JNGImageChunk.h"
#import "zlib.h"

@implementation JNGImageChunk

@synthesize name, data, crc, afterJSEP;

- (id)init {
	if(self = [super init]) {
		name = nil;
		data = nil;
		crc = 0;
		afterJSEP = NO;
	}
	return self;
}

- (void)dealloc {
	[data release];
	[name release];
	[super dealloc];
}

#pragma mark -

// calculate crc.
// this should match value of the crc property.
// crc includes the chunk type code and chunk data fields, but does not include the length field
- (unsigned long)calculateCrc {
	NSMutableData *dat = [NSMutableData data];
	[dat appendBytes:[name UTF8String] length:4];
	[dat appendData:data];
	
	return crc32(0, [dat bytes], [dat length]);	
}

@end
