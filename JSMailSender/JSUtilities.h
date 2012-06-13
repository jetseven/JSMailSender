//
//  JSUtilities.h
//  JSSimpleSender
//
//  Created by Steve Brokaw on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

