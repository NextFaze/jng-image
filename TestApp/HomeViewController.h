//
//  HomeViewController.h
//  jng-image
//
//  Created by Andrew on 26/11/10.
//  Copyright 2010 2moro mobile. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HomeViewController : UITableViewController {
	NSArray *images;  // array of TestImage objects

}

@property (nonatomic, retain) NSArray *images;


@end
