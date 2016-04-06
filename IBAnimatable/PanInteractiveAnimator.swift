//
//  Created by Jake Lin on 3/3/16.
//  Copyright © 2016 Jake Lin. All rights reserved.
//

import UIKit

// Pan interactive animator: pan gesture transition controller
public class PanInteractiveAnimator: InteractiveAnimator {
  
  override func createGestureRecognizer() -> UIGestureRecognizer {
    return UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
  }
  
  override func handleGesture(gestureRecognizer: UIGestureRecognizer) {
    guard let  gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer,
      superview = gestureRecognizer.view?.superview else {
      return
    }
    let translation = gestureRecognizer.translationInView(superview)
    let velocity = gestureRecognizer.velocityInView(superview)
    
    var progress: CGFloat
    let distance: CGFloat
    let speed: CGFloat
    switch interactiveGestureType {
    case .Pan(let direction):
      switch direction {
      case .Horizontal:
        distance = superview.frame.width
        progress = abs(translation.x / distance)
        speed = abs(velocity.x)
      case .Left:
        distance = superview.frame.width
        progress = translation.x / distance
        speed = velocity.x
      case .Right:
        distance = superview.frame.width
        progress = -(translation.x / distance)
        speed = -velocity.x
      case .Vertical:
        distance = superview.frame.height
        progress = abs(translation.y / distance)
        speed = abs(velocity.y)
      case .Top:
        distance = superview.frame.height
        progress = translation.y / distance
        speed = velocity.y
      case .Bottom:
        distance = superview.frame.height
        progress = -translation.y / distance
        speed = -velocity.y
      }
    default:
      return
    }
    
    progress = min(max(progress, 0), 0.99)
    switch gestureRecognizer.state {
    case .Began:
      interacting = true
      switch transitionType {
      case .NavigationTransition(.Pop):
        viewController?.navigationController?.popViewControllerAnimated(true)
      case .PresentationTransition(.Dismissal):
        viewController?.dismissViewControllerAnimated(true, completion: nil)
      default:
        break
      }
    case .Changed:
      updateInteractiveTransition(progress)
    case .Cancelled, .Ended:
      interacting = false
      // Finish the transition when pass the threathold
      if progress > 0.5 || speed > 1000 {
        finishInteractiveTransition()
      } else {
        cancelInteractiveTransition()
      }
    default:
      // Something happened. cancel the transition.
      cancelInteractiveTransition()
      break
    }
  }
  
}
