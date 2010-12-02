//
//  JNGImageCache.m
//  jng-image
//
//  Created by Andrew on 26/11/10.
//  Copyright 2010 2moro mobile. All rights reserved.
//

#import "JNGImageCache.h"

@implementation JNGImageCache

@synthesize cacheSize;

- (id)init {
	if(self = [super init]) {
		cacheDict = [[NSMutableDictionary alloc] init];
		cacheList = [[NSMutableArray alloc] init];
		cacheSize = JNGImageCacheSize;
		
		// empty cache on memory warnings
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		[center addObserver:self selector:@selector(memoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	}
	return self;
}

- (void)dealloc {
	[cacheDict release];
	[cacheList release];
	
	[super dealloc];
}

#pragma mark -

- (void)setImage:(JNGImage *)jng forKey:(NSString *)name {
	if(jng == nil || name == nil) return;
	
	@synchronized(self) {
		[cacheDict setValue:jng forKey:name];
		[cacheList removeObject:name];
		[cacheList addObject:name];
		
		// remove images from the cache until we are under the cacheSize.
		// removes least recently used images first
		while([cacheList count] > cacheSize) {
			NSString *oldname = [cacheList objectAtIndex:0];
			[cacheList removeObjectAtIndex:0];
			[cacheDict removeObjectForKey:oldname];
		}
	}
}

- (JNGImage *)imageForKey:(NSString *)name {
	JNGImage *jng = nil;
	
	if(name == nil) return nil;
	
	@synchronized(self) {
		jng = [cacheDict valueForKey:name];

		if(jng) {
			// update list so that recently accessed images are at the end
			[cacheList removeObject:name];
			[cacheList addObject:name];
		}
	}
	return jng;
}

// clear the cache
- (void)removeAllObjects {
	@synchronized(self) {
		[cacheDict removeAllObjects];
		[cacheList removeAllObjects];
	}
}

- (int)count {
	return [cacheList count];
}

- (void)memoryWarning {
	LOG(@"memory warning received, emptying cache");
	[self removeAllObjects];
}

@end
