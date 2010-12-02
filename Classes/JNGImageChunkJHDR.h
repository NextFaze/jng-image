//
//  JNGImageChunkJHDR.h
//  jng-image
//
//  Created by Andrew on 2/12/10.
//  Copyright 2010 2moro mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	JNGImageColorTypeGray       = 8,
	JNGImageColorTypeColor      = 10,
	JNGImageColorTypeGrayAlpha  = 12,
	JNGImageColorTypeColorAlpha = 14
} JNGImageColorType;

@interface JNGImageChunkJHDR : NSObject {
	JNGImageColorType colorType;
	unsigned int width, height;
	unsigned char imageSampleDepth, imageCompressionMethod, imageInterlaceMethod;
	unsigned char alphaSampleDepth, alphaCompressionMethod, alphaFilterMethod, alphaInterlaceMethod;
}

- (id)initWithData:(NSData *)data;

@property (nonatomic, assign) JNGImageColorType colorType;
@property (nonatomic, assign) unsigned int width, height;
@property (nonatomic, assign) unsigned char imageSampleDepth, imageCompressionMethod, imageInterlaceMethod;
@property (nonatomic, assign) unsigned char alphaSampleDepth, alphaCompressionMethod, alphaFilterMethod, alphaInterlaceMethod;

@end
