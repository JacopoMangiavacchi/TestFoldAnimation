//
//  ViewController.h
//  TestTendina
//
//  Created by Jacopo Mangiavacchi on 07/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoldView.h"


@interface ViewController : UIViewController {
    
    BOOL showMenu;
    
}

@property (weak, nonatomic) IBOutlet FoldView *foldView;


- (IBAction)buttonTap2:(id)sender;

@end
