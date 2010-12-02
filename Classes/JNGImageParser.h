//
//  JNGImageParser.h
//  jng-image
//
//  Created by Andrew Williams on 26/11/10.
//  Copyright 2010 2moro mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JNGImageChunkJHDR.h"

@interface JNGImageParser : NSObject {
	NSData *data;
	NSArray *chunks;  // parsed chunks
}

@property (nonatomic,retain) NSData *data;
@property (nonatomic,retain) NSArray *chunks;

- (id)initWithData:(NSData *)data;
- (void)parse:(NSError **)error;

- (JNGImageChunkJHDR *)header;
- (NSData *)jpeg1;
- (NSData *)jpeg2;
- (NSData *)alphapng;
- (NSData *)alphajpeg;

- (NSArray *)chunksNamed:(NSString *)name;

@end
