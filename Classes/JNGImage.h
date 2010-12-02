//
//  JNGImage.h
//  jng-image
//
//  Created by Andrew Williams on 26/11/10.
//  Copyright 2010 2moro mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JNGImageChunkJHDR.h"

@interface JNGImage : NSObject {
	UIImage *image;
	JNGImageChunkJHDR *header;
}

+ (JNGImage *)imageNamed:(NSString *)name;
+ (JNGImage *)imageWithContentsOfFile:(NSString *)filename;
+ (JNGImage *)imageWithData:(NSData *)data;

- (id)initWithData:(NSData *)data;

- (UIImage *)image;

@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) int imageSampleDepth, imageInterlaceMethod;
@property (nonatomic, readonly) int alphaSampleDepth, alphaCompressionMethod;

@end
