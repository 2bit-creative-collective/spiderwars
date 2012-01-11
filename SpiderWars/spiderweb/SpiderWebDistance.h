//
//  SpiderWebDistance.h
//  SpiderWars
//
//  Created by Simone Vicentini on 29/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "SpiderWeb.h"
#include "Box2D.h"

@interface SpiderWebDistance : NSObject <SpiderWeb>
{
    @private
    b2World *world;
    b2Body *webAnchor;
}



+(id) createWebWithAnchorAt:(const b2Vec2&)anchorPoint andAnchoredBody:(b2Body *)body inWorld:(b2World *) world;

-(id) initWithAnchorAt:(const b2Vec2&)anchorPoint andAnchoredBody:(b2Body *)body inWorld:(b2World *) world;

-(b2Body *) createAnchorAt: (const b2Vec2&) anchorPoint;

-(void) dealloc;

@end
