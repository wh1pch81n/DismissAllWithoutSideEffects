//
//  ViewController.swift
//  Presentation
//
//  Created by Derrick Ho on 12/3/16.
//  Copyright © 2016 Derrick Ho. All rights reserved.
//

import UIKit

func numVC(currentVC: UIViewController, _ total: Int = 0) -> Int {
	guard let p = currentVC.presentingViewController else { return total }
	return numVC(currentVC: p, total + 1)
}

func rootVC(currentVC: UIViewController) -> UIViewController {
	guard let p = currentVC.presentingViewController else { return currentVC }
	return rootVC(currentVC: p)
}

func topVC(currentVC: UIViewController) -> UIViewController {
	guard let p = currentVC.presentedViewController else { return currentVC }
	return topVC(currentVC: p)
}

class ViewController: UIViewController {
	@IBOutlet weak var level: UILabel!

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		level.text = String(numVC(currentVC: self))
	}
	
	@IBAction func tappedAdd1(_ sender: Any) {
		let vc = storyboard!.instantiateViewController(withIdentifier: "ViewController")
		present(vc, animated: true, completion: nil)
	}
	
	// Goes to the root view controller and dismisses the presented view controller. All view controllers on top of that are dismissed imediately before dismissing in an animated fashion
	@IBAction func dismissAll(_ sender: Any) {
		rootVC(currentVC: self).dismiss(animated: true)
	}
	
	// As described in the above comment, you may not want that behavior and instead want the top most view controller to dismiss with animation whil all the ones in between remain invisible.
	// Solution: you must move the view from the top view controller to the view controller of the presented view controller of the root.  But there is a cavet, if the top view has elements that connect to toplayout guide or bottom layout guide, then the views will shift.  the fix is to ensure that all view elements in the view don't use the top or bottom layout guide.
	@IBAction func dismissAllSpecial(_ sender: Any) {
//		let root = rootVC(currentVC: self)
//		
//		if let root1 = root.presentedViewController,
//			root1 != self
//		{
//			let v = view!
//			self.view = UIView()
//			//v.backgroundColor = UIColor.red.withAlphaComponent(0.6)
//			//root1.view.addSubview(v)
//			root1.view = v
//		}
//		
//		root.dismiss(animated: true)
		
		let root = rootVC(currentVC: self)
		
		if let root1 = root.presentedViewController,
			root1 != self
		{
			root1.transitioningDelegate = root as? UIViewControllerTransitioningDelegate
			(root1 as! ViewController).lastTopVC = self
		}
		
		root.dismiss(animated: true)
	}
	
	var lastTopVC: UIViewController?
}

extension ViewController: UIViewControllerTransitioningDelegate {
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return DismissAnimator()
	}
}

class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.5
	}
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let fromVC = transitionContext.viewController(forKey: .from)!
		let top = (fromVC as! ViewController).lastTopVC!
		let fromView = top.view!
		top.view = UIView()
		let toView = transitionContext.view(forKey: .to)!
		let containerView = transitionContext.containerView
		containerView.subviews.forEach({ $0.removeFromSuperview() })
		
		containerView.addSubview(toView)
		containerView.addSubview(fromView)
		
		UIView.animate(withDuration: transitionDuration(using: transitionContext)
			, animations: {
				fromView.frame.offsetBy(dx: 0, dy: fromView.frame.height)
		}, completion: { _ in
			transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
		})

	}
}

