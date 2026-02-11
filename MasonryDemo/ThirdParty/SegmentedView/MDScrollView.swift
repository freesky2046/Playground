//
//  MDScrollView.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/11.
//

import Foundation
import UIKit

class MDScrollView: UIScrollView {
  
}

extension MDScrollView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let popGesture = UIViewController.current?.navigationController?.md_FullscreenPopGestureRecognizer,
           otherGestureRecognizer === popGesture, self.contentOffset.x <= 0 {
            return true
        }
        return false
    }
}
