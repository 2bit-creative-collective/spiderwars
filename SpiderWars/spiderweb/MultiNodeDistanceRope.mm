//
//  MultiNodeDistanceRope.m
//  SpiderWars
//
//  Created by Simone Vicentini on 01/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MultiNodeDistanceRope.h"

@implementation MultiNodeDistanceRope



+(id) createWebWithAnchorAt:(const b2Vec2&)anchorPoint andAnchoredBody:(b2Body *)body inWorld:(b2World *) world
{
    return [[[self alloc] initWithAnchorAt:anchorPoint andAnchoredBody:body inWorld:world] autorelease];
}



-(id) initWithAnchorAt:(const b2Vec2&)anchorPoint andAnchoredBody:(b2Body *)body inWorld:(b2World *) myWorld
{
    
    self = [super init];
    if (self) 
    {
        self->anchors = [[NSMutableArray array] retain];
        self->bodies = [[NSMutableArray array] retain];
        self->world = myWorld;
        
        b2Vec2 bodyPosition = body->GetPosition();
        
        b2Body* webAnchor = [self createAnchorAt:anchorPoint];
        b2Body* staticAnchor = webAnchor;
        [self->bodies addObject:[NSValue valueWithPointer:webAnchor]];
        
        
        b2Vec2 dist = [self midpointBetweenBody:anchorPoint andBody:bodyPosition];
        
        b2Vec2 originalDist = anchorPoint - bodyPosition;
        
        while (dist.Length() > 0.8f)
        {
            dist = [self midpointBetweenBody:anchorPoint andBody:(anchorPoint - dist)];
        }

        
        b2Vec2 nd = originalDist - dist;

        while (b2Dot(originalDist, nd) >= 0.0f)
        {
            b2Vec2* aa = new b2Vec2(bodyPosition + nd);
            
            [self->anchors addObject:[NSValue valueWithPointer:aa]];
            nd -= dist;

        }
        
        float mass = body->GetMass() / [self->anchors count]; 
            
        
        b2Body* midWebAnchor;
        
        for (NSValue* v in self->anchors)
        {
            b2Vec2 aa = *(b2Vec2 *)[v pointerValue];
        
            
            midWebAnchor = [self createAnchorAt:aa ofType:b2_dynamicBody remainingMass:mass];
        
            [self->bodies addObject:[NSValue valueWithPointer:midWebAnchor]];
            
            //midWebAnchor->SetLinearDamping(0.1f);
        
            
            b2DistanceJointDef *jd = new b2DistanceJointDef();
            jd->Initialize(webAnchor, midWebAnchor, webAnchor->GetWorldCenter(), 
                       midWebAnchor->GetWorldCenter());
//            jd->frequencyHz = 30.0f;
//            jd->dampingRatio = 1.0f;
        
            world->CreateJoint(jd);
            webAnchor = midWebAnchor;
        }
        
        
        b2DistanceJointDef *jd = new b2DistanceJointDef();
        jd->Initialize(midWebAnchor, body, midWebAnchor->GetWorldCenter(), 
                       body->GetWorldCenter());
//        jd->frequencyHz = 30.0f;
//        jd->dampingRatio = 1.0f;
        
        world->CreateJoint(jd);
        b2RopeJointDef *d = new b2RopeJointDef();
        d->bodyA = staticAnchor;
        d->bodyB = body;
        d->localAnchorA = staticAnchor->GetLocalCenter();
        d->localAnchorB = body->GetLocalCenter();
        d->maxLength = originalDist.Length() + dist.Length();

        
        world->CreateJoint(d);
                
    }
     
    return self;
}



-(b2Vec2) midpointBetweenBody:(b2Vec2)bodyA andBody:(b2Vec2)bodyB
{
    
    b2Vec2 hh = bodyA - bodyB;
    
    hh *= .5f;

    return hh;

}


-(b2Body *) createAnchorAt: (const b2Vec2&) anchorPoint
{
    return [self createAnchorAt:anchorPoint ofType:b2_staticBody remainingMass:1];
}

-(b2Body *) createAnchorAt: (const b2Vec2&) anchorPoint ofType:(b2BodyType) type remainingMass:(float) mass
{
    b2Body *anchor;
    b2BodyDef spiderAnchorDef;
    
    spiderAnchorDef.type = type;
	spiderAnchorDef.position = anchorPoint;
    
    
    anchor =  world->CreateBody(&spiderAnchorDef);
    
    // Define another box shape for our dynamic body.
	b2CircleShape circleAnchor;
    circleAnchor.m_p = b2Vec2(0,0);
    circleAnchor.m_radius = 0.1f;
    
    float area = M_PI * circleAnchor.m_radius * circleAnchor.m_radius;
    
    
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef1;
	fixtureDef1.shape = &circleAnchor;	
	fixtureDef1.density = mass / area;
	fixtureDef1.friction = 0.0f;
    fixtureDef1.filter.groupIndex = -8;
	anchor->CreateFixture(&fixtureDef1);
    
    
	return anchor;
    
}

-(void) dealloc
{

    for (NSValue *v in self->anchors)
    {
        delete (b2Vec2*)[v pointerValue];
    }
    for (NSValue *v in self->bodies)
        world->DestroyBody((b2Body*)[v pointerValue]);
 
    self->anchors = Nil;
    [super dealloc];
}


@end
