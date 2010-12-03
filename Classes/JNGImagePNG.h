//
//  JNGImagePNG.h
//  jng-image
//
//  Created by Andrew on 2/12/10.
//  Copyright 2010 2moro mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JNGImageChunk.h"

#define PNGImageSignature {0x89,0x50,0x4e,0x47,0x0d,0x0a,0x1a,0x0a}
#define JNGImageSignature {0x8b,0x4a,0x4e,0x47,0x0d,0x0a,0x1a,0x0a}

// color type (1 byte)
typedef enum {
	JNGImagePNGColorTypeGrayscale      = 0,
	JNGImagePNGColorTypeRGB            = 2,
	JNGImagePNGColorTypePalette        = 3,
	JNGImagePNGColorTypeGrayscaleAlpha = 4,
	JNGImagePNGColorTypeRGBAlpha       = 6
} JNGImagePNGColorType;

@interface JNGImagePNG : NSObject {
	NSMutableArray *chunks;

	unsigned int width, height, bitDepth, compressionMethod, filterMethod, interlaceMethod;
	JNGImagePNGColorType colorType;
}

@property (nonatomic, retain) NSMutableArray *chunks;
@property (nonatomic, assign) JNGImagePNGColorType colorType;
@property (nonatomic, assign) unsigned int width, height, bitDepth, compressionMethod, filterMethod, interlaceMethod;

- (void)addChunk:(JNGImageChunk *)chunk;
- (NSData *)data;

@end
