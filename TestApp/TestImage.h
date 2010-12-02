//
//  TestImage.h
//  jng-image
//
//  Created by Andrew on 2/12/10.
//  Copyright 2010 2moro mobile. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TestImage : NSObject {
	NSString *name;
}

@property (nonatomic, copy) NSString *name;

+ (NSArray *)images;

@end
