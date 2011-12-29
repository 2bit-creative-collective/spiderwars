//
//  SpiderWeb.h
//  SpiderWars
//
//  Created by Simone Vicentini on 29/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box2D.h"

@protocol SpiderWeb <NSObject>

-(void) InitialiseWithAnchorAt:(const b2Vec2&)anchorPoint andAnchoredBody:(const b2Body&)body inWorld:(b2World *) world;

@end
