//
//  SpiderWebRope.m
//  SpiderWars
//
//  Created by Simone Vicentini on 29/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SpiderWebRope.h"

@implementation SpiderWebRope


+(id) rope
{
    return [[[self alloc] init] autorelease];
}


-(void) InitialiseWithAnchorAt:(const b2Vec2&)anchorPoint andAnchoredBody:(const b2Body&)body inWorld:(b2World *) world
{
    
}

@end
