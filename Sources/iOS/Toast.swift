//
//  Toast.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 02/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

/// An instance of a toast operation to be presented to the user
class ToastOperation: Operation {
    
    /// The view that will be displayed when the toast operation has begun
    let toastView: ToastView
    
    @objc private var _finished: Bool = false 
    
    override var isFinished: Bool {
        return _finished
    }
    
    override var isAsynchronous: Bool {
        return false
    }
    
    init(toastView: ToastView) {
        self.toastView = toastView
        super.init()
    }
    
    override func main() {
        
        guard !Thread.current.isMainThread else {
            toastView.show { [weak self] in
                guard let self = self else { return }
                self._finished = true
            }
            return
        }
            
        let finishSemaphore = DispatchSemaphore(value: 0)
        
        OperationQueue.main.addOperation { [weak self] in
            guard let self = self else { return }
            self.toastView.show {
                finishSemaphore.signal()
            }
        }
        
        finishSemaphore.wait()
        _finished = true
    }
    
    open override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        if ["isReady", "isFinished", "isExecuting"].contains(key) {
            return [#keyPath(_finished)]
        }
        
        return super.keyPathsForValuesAffectingValue(forKey: key)
    }
}
