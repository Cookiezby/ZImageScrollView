# ZImageScrollView

two kinds of way to init this view

1 init with images

```ObjectiveC
- (instancetype)initWithFrame:(CGRect)frame withImages:(NSArray*)images autoScroll:										
							(BOOL)autoScroll unlimited:(BOOL)unlimited;
```


2 init with imageURLs

```ObjectiveC
- (instancetype)initWithFrame:(CGRect)frame withImageURLs:(NSArray *)imageURLs autoScroll:
							   (BOOL)autoScroll unlimited:(BOOL)unlimited{
```


Paramater Explanation

    
* autoScroll: the ScrollView will show the image automatically
* unlimted: if the ScrollView moves in cycles


