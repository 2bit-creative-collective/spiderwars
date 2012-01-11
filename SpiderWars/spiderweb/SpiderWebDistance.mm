//
//  SpiderWebDistance.m
//  SpiderWars
//
//  Created by Simone Vicentini on 29/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SpiderWebDistance.h"


@implementation SpiderWebDistance 


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
        
        self->webAnchor = [self createAnchorAt:anchorPoint];
        
//        b2RevoluteJointDef *rj = new b2RevoluteJointDef();
//        rj->Initialize(webAnchor, body, webAnchor->GetWorldCenter());
//        self->world->CreateJoint(rj);
        
        b2DistanceJointDef *jd = new b2DistanceJointDef();
        
        jd->Initialize(webAnchor, body, webAnchor->GetWorldCenter(), 
                           body->GetWorldPoint(b2Vec2(body->GetLocalCenter().x, body->GetLocalCenter().y + .5f)));
        jd->frequencyHz = 1.0f;
        jd->dampingRatio = 4.0f;
        
        self->world->CreateJoint(jd);
        
    }
    return self;
}

-(b2Body *) createAnchorAt: (const b2Vec2&) anchorPoint
{
    b2Body *anchor;
    b2BodyDef spiderAnchorDef;
    
    
	spiderAnchorDef.position = anchorPoint;
    
    
    anchor =  self->world->CreateBody(&spiderAnchorDef);
    
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
//    self->world->DestroyJoint(joint);
    self->world->DestroyBody(webAnchor);

    self->webAnchor = NULL;
    [super dealloc];
}

@end
