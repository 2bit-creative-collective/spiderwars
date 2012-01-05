//
//  MultiNodeDistanceRope.h
//  SpiderWars
//
//  Created by Simone Vicentini on 01/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "SpiderWeb.h"
#include "Box2D.h"

@interface MultiNodeDistanceRope : NSObject <SpiderWeb>
{
    @private
    b2World* world;
    NSMutableArray* anchors;
    NSMutableArray* bodies;
}

+(id) createWebWithAnchorAt:(const b2Vec2&)anchorPoint andAnchoredBody:(b2Body *)body inWorld:(b2World *) world;

-(id) initWithAnchorAt:(const b2Vec2&)anchorPoint andAnchoredBody:(b2Body *)body inWorld:(b2World *) myWorld;

@property (nonatomic) b2Joint *joint;

-(b2Body *) createAnchorAt: (const b2Vec2&) anchorPoint;

-(b2Body *) createAnchorAt: (const b2Vec2&) anchorPoint ofType:(b2BodyType) type;

-(b2Vec2) midpointBetweenBody:(b2Vec2)bodyA andBody:(b2Vec2)bodyB;






@end
