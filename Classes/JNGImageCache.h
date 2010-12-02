//
//  JNGImageCache.h
//  jng-image
//
//  Created by Andrew on 26/11/10.
//  Copyright 2010 2moro mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JNGImage.h"

#define JNGImageCacheSize 100  // default cache size

@interface JNGImageCache : NSObject {
	NSMutableDictionary *cacheDict;     // image name -> JNGImage object
	NSMutableArray *cacheList;          // list of image names (most recently used last)
	int cacheSize;
}

@property (nonatomic, assign) int cacheSize;

- (void)setImage:(JNGImage *)jng forKey:(NSString *)name;
- (JNGImage *)imageForKey:(NSString *)name;
- (void)removeAllObjects;
- (int)count;

@end
