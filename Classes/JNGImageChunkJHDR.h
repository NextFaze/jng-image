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

typedef enum {
	JNGImageInterlaceMethodSequential  = 0,
	JNGImageInterlaceMethodProgressive = 8
} JNGImageInterlaceMethod;

typedef enum {
	JNGImageCompressionMethodIDAT = 0,
	JNGImageCompressionMethodJDAA = 8
} JNGImageCompressionMethod;

@interface JNGImageChunkJHDR : NSObject {
	JNGImageColorType colorType;
	JNGImageInterlaceMethod imageInterlaceMethod;
	JNGImageCompressionMethod imageCompressionMethod;
	
	unsigned int width, height;
	unsigned char imageSampleDepth;
	unsigned char alphaSampleDepth, alphaCompressionMethod, alphaFilterMethod, alphaInterlaceMethod;
}

- (id)initWithData:(NSData *)data;

@property (nonatomic, assign) JNGImageColorType colorType;
@property (nonatomic, assign) JNGImageInterlaceMethod imageInterlaceMethod;
@property (nonatomic, assign) JNGImageCompressionMethod imageCompressionMethod;
@property (nonatomic, assign) unsigned int width, height;
@property (nonatomic, assign) unsigned char imageSampleDepth;
@property (nonatomic, assign) unsigned char alphaSampleDepth, alphaCompressionMethod, alphaFilterMethod, alphaInterlaceMethod;

@end
