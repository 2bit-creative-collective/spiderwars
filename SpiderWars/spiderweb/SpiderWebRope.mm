//
//  SpiderWebRope.m
//  SpiderWars
//
//  Created by Simone Vicentini on 29/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SpiderWebRope.h"

@implementation SpiderWebRope



+(id) createWebWithAnchorAt:(const b2Vec2&)anchorPoint andAnchoredBody:(b2Body *)body inWorld:(b2World *) world
{
    return [[[self alloc] initWithAnchorAt:anchorPoint andAnchoredBody:body inWorld:world] autorelease];
}


-(id) initWithAnchorAt:(const b2Vec2&)anchorPoint andAnchoredBody:(b2Body *)body inWorld:(b2World *) myWorld
{
    self = [super init];
    if (self) 
    {
        self->world = myWorld;
        
        webAnchor = [self createAnchorAt:anchorPoint];
        b2RopeJointDef *jd = new b2RopeJointDef();
        jd->bodyA = webAnchor;
        jd->bodyB = body;
        jd->localAnchorA = b2Vec2(0,0);
        jd->localAnchorB = b2Vec2(0,.5f);

        jd->maxLength= (body->GetPosition() - webAnchor->GetPosition()).Length(); //define max length of joint = current distance between bodies
        

        
    }
    return self;
}

-(b2Body *) createAnchorAt: (const b2Vec2&) anchorPoint
{
    b2Body *anchor;
    b2BodyDef spiderAnchorDef;
    
    
	spiderAnchorDef.position = anchorPoint;
    
    anchor =  world->CreateBody(&spiderAnchorDef);
    
    // Define another box shape for our dynamic body.
	b2CircleShape circleAnchor;
    circleAnchor.m_p = b2Vec2(0,0);
    circleAnchor.m_radius = 2.0f;
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef1;
	fixtureDef1.shape = &circleAnchor;	
	fixtureDef1.density = 1.0f;
	fixtureDef1.friction = 0.0f;
	anchor->CreateFixture(&fixtureDef1);
    return anchor;
    
}

-(void) dealloc
{
    world->DestroyBody(webAnchor);
    webAnchor = NULL;
    [super dealloc];
}

@end
