//
//  OCAnnotation.m
//  openClusterMapView
//
//  Created by Botond Kis on 14.07.11.
//

#import "OCAnnotation.h"

@implementation OCAnnotation
@synthesize coordinate;
@synthesize title          = _title;
@synthesize subtitle       = _subtitle;
@synthesize mapView        = _mapView;
@synthesize annotationView = _annotationView;
@synthesize content        = _content;


// Memory
- (id)init
{
    self = [super init];
    if (self) {
        _groupTag = title = subtitle = [NSString stringWithFormat:@""];
        coordinate = CLLocationCoordinate2DMake(0.0, 0.0);
        annotationsInCluster = [[NSMutableArray alloc] init];
    }
    
    return self;
}

/** Init with a coordinate and nil the rest. */
-(id) initWithContent:(Content*) content
{
    //NSLog(@"init111111");
    self = [super init];
    if (self!=nil){
        self.content = content;
        self.coordinate = content.coordinate;
        self.mapView = nil;
        self.annotationView = nil;
    }
    return self;
}

- (id)initWithAnnotation:(id <MKAnnotation>) annotation{
    
    self = [super init];
    if (self) {
        coordinate = [annotation coordinate];
        annotationsInCluster = [[NSMutableArray alloc] init];
        [annotationsInCluster addObject:annotation];
        
        title = annotation.title;
        subtitle = annotation.title;
        _groupTag = [NSString stringWithFormat:@""];
    }
    
    return self;
}

- (MKAnnotationView*)annotationViewInMap:(MKMapView*) aMapView;
{
    if (self.annotationView) {
        self.annotationView.annotation = self;
    } else {
        static NSString *viewId = @"AnnotationView";
        self.annotationView = (AnnotationView*)[aMapView dequeueReusableAnnotationViewWithIdentifier:viewId];
        if (self.annotationView==nil){
            self.annotationView = [[AnnotationView alloc] initWithAnnotation:self reuseIdentifier:viewId];
        }
    }
    return self.annotationView;
}


//
// List of annotations in the cluster
// read only
- (NSArray *)annotationsInCluster{
    return annotationsInCluster;
}


//
// manipulate cluster
- (void)addAnnotation:(id < MKAnnotation >)annotation{
    
    //calculate new cluster coordinate
    float annotationCount = (float)[annotationsInCluster count];
    coordinate.latitude = (coordinate.latitude * annotationCount + annotation.coordinate.latitude) / (annotationCount + 1);
    coordinate.longitude = (coordinate.longitude * annotationCount + annotation.coordinate.longitude) / (annotationCount + 1);
    
    // Add annotation to the cluster
    [annotationsInCluster addObject:annotation];
}

- (void)addAnnotations:(NSArray *)annotations{
    for (id<MKAnnotation> annotation in annotations) {
        [self addAnnotation: annotation];
    }
}

- (void)removeAnnotation:(id < MKAnnotation >)annotation{
    
    //calculate new cluster coordinate
    float annotationCount = (float)[annotationsInCluster count];
    coordinate.latitude = (coordinate.latitude * annotationCount - annotation.coordinate.latitude) / (annotationCount - 1);
    coordinate.longitude = (coordinate.longitude * annotationCount - annotation.coordinate.longitude) / (annotationCount - 1);
    
    // Remove annotation from cluster
    [annotationsInCluster removeObject:annotation];
    
}

- (void)removeAnnotations:(NSArray *)annotations{
    for (id<MKAnnotation> annotation in annotations) {
        [self removeAnnotation: annotation];
    }
}

//
// protocoll implementation
- (NSString *)title{
    return title;
}

- (void)setTitle:(NSString *)text{
    title = text;
}

- (NSString *)subtitle{
    return subtitle;
}

- (void)setSubtitle:(NSString *)text{
    subtitle = text;
}

- (NSString *)groupTag{
    return _groupTag;
}

- (void)setGroupTag:(NSString *)tag{
    _groupTag = tag;
}

- (CLLocationCoordinate2D)coordinate{
    return coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)coord{
    coordinate = coord;
    
    // not sure why or when this happens...
    // Add self to the map, and set self as the annotation for the referenced view.
    [self.mapView addAnnotation:self];
    if (_annotationView) {
        [_annotationView setAnnotation:self];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"coordinate=%f,%f", self.coordinate.latitude, self.coordinate.longitude];
}

@end
