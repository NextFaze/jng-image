//
//  main.m
//  jng-image
//
//  Created by Andrew Williams on 18/11/10.
//  Copyright 2010 2moro mobile. All rights reserved.
//

#include <libgen.h>
#import "JNGImageParser.h"
#import "JNGImageChunkJHDR.h"
#import "JNGImageChunk.h"

char *colour_type_string(JNGImageColorType ctype) {
	switch (ctype) {
		case JNGImageColorTypeGray: return "Gray";
		case JNGImageColorTypeColor: return "Color";
		case JNGImageColorTypeGrayAlpha: return "Gray-alpha";
		case JNGImageColorTypeColorAlpha: return "Color-alpha";
		default:
			return "Unknown";
	}
}

void display_image_info(char *filename) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSString *fname = [NSString stringWithFormat:@"%s", filename];
	NSData *data = [NSData dataWithContentsOfFile:fname];
	JNGImageParser *parser = [[JNGImageParser alloc] initWithData:data];
	[parser parse:nil];

	JNGImageChunkJHDR *header = parser.header;

	printf("filename: %s\n", filename);
	printf("image size: (%d, %d)\n", header.width, header.height);
	printf("colour type: %s\n", colour_type_string(header.colorType));
	printf("image sample depth: %d\n", header.imageSampleDepth);
	printf("image interlace method: %s\n", header.imageSampleDepth == JNGImageInterlaceMethodSequential ? "Sequential" : "Progressive");
	if(header.colorType == JNGImageColorTypeGrayAlpha || header.colorType == JNGImageColorTypeColorAlpha) {
		printf("alpha sample depth: %d\n", header.alphaSampleDepth);
		printf("alpha compression method: %s\n", header.alphaCompressionMethod == JNGImageCompressionMethodIDAT ? "PNG IDAT" : "JNG JDAA");
	}
	for(JNGImageChunk *chunk in parser.chunks) {
		printf("  Chunk: %s  %d bytes\n", [chunk.name UTF8String], chunk.data.length);
	}
	printf("\n");
	
	[parser release];
	[pool release];	
}


int main(int argc, char *argv[]) {
	int i;
	
	if(argc <= 1) {
		printf("usage: %s image.jng [image.jng] ...\n", basename(argv[0]));
		exit(1);
	}
	
	for(i = 1; i < argc; i++) {
		display_image_info(argv[i]);
	}
	
	return 0;
}
