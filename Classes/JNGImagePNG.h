//
//  JNGImagePNG.h
//  jng-image
//
//  Created by Andrew on 2/12/10.
//  Copyright 2010 2moro mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JNGImageChunk.h"

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
