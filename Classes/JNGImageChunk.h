//
//  JNGImageChunk.h
//  jng-image
//
//  Created by Andrew Williams on 26/11/10.
//  Copyright 2010 2moro mobile. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JNGImageChunk : NSObject {
	NSString *name;     // chunk type code
	unsigned long crc;
	NSData *data;
	BOOL afterJSEP;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, assign) unsigned long crc;
@property (nonatomic, assign) BOOL afterJSEP;

- (unsigned long)calculateCrc;

- (BOOL)isAncillary;
- (BOOL)isCritical;

@end
