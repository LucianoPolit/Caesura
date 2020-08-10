//
//  TimelineControlMiddleware.swift
//
//  Copyright (c) 2020 Luciano Polit <lucianopolit@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import UIKit
#if !COCOAPODS
import Caesura
#endif

public class TimelineControlMiddleware: DebugMiddleware {
    
    private var memory: Float = 0
    
    private lazy var backgroundView = UIView().then {
        $0.backgroundColor = .clear
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private lazy var slider = UISlider().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(
            self,
            action: #selector(actionValueChanged),
            for: .valueChanged
        )
    }
    private lazy var sliderContainer = UIView().then {
        $0.alpha = 0
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addSubview(slider)
        NSLayoutConstraint.activate(
            [
                NSLayoutConstraint(
                    item: slider,
                    attribute: .left,
                    relatedBy: .equal,
                    toItem: $0,
                    attribute: .left,
                    multiplier: 1,
                    constant: 40
                ),
                NSLayoutConstraint(
                    item: slider,
                    attribute: .top,
                    relatedBy: .equal,
                    toItem: $0,
                    attribute: .top,
                    multiplier: 1,
                    constant: 0
                ),
                NSLayoutConstraint(
                    item: slider,
                    attribute: .centerX,
                    relatedBy: .equal,
                    toItem: $0,
                    attribute: .centerX,
                    multiplier: 1,
                    constant: 0
                ),
                NSLayoutConstraint(
                    item: slider,
                    attribute: .centerY,
                    relatedBy: .equal,
                    toItem: $0,
                    attribute: .centerY,
                    multiplier: 1,
                    constant: 0
                )
            ]
        )
    }
    private var window: UIWindow? {
        didSet {
            guard let window = window else { return }
            
            let swipeUpGestureRecognizer = UISwipeGestureRecognizer(
                target: self,
                action: #selector(actionSwipe)
            )
            swipeUpGestureRecognizer.direction = .up
            window.addGestureRecognizer(swipeUpGestureRecognizer)
            
            let swipeDownGestureRecognizer = UISwipeGestureRecognizer(
                target: self,
                action: #selector(actionSwipe)
            )
            swipeDownGestureRecognizer.direction = .down
            window.addGestureRecognizer(swipeDownGestureRecognizer)
            
            let longPressGestureRecognizer = UILongPressGestureRecognizer(
                target: self,
                action: #selector(actionLongPress)
            )
            longPressGestureRecognizer.numberOfTouchesRequired = 2
            window.addGestureRecognizer(longPressGestureRecognizer)
            
            window.addSubview(backgroundView)
            NSLayoutConstraint.activate(
                [
                    NSLayoutConstraint(
                        item: backgroundView,
                        attribute: .left,
                        relatedBy: .equal,
                        toItem: window,
                        attribute: .left,
                        multiplier: 1,
                        constant: 0
                    ),
                    NSLayoutConstraint(
                        item: backgroundView,
                        attribute: .top,
                        relatedBy: .equal,
                        toItem: window,
                        attribute: .top,
                        multiplier: 1,
                        constant: 0
                    ),
                    NSLayoutConstraint(
                        item: backgroundView,
                        attribute: .centerX,
                        relatedBy: .equal,
                        toItem: window,
                        attribute: .centerX,
                        multiplier: 1,
                        constant: 0
                    ),
                    NSLayoutConstraint(
                        item: backgroundView,
                        attribute: .centerY,
                        relatedBy: .equal,
                        toItem: window,
                        attribute: .centerY,
                        multiplier: 1,
                        constant: 0
                    )
                ]
            )
            
            window.addSubview(sliderContainer)
            NSLayoutConstraint.activate(
                [
                    NSLayoutConstraint(
                        item: sliderContainer,
                        attribute: .left,
                        relatedBy: .equal,
                        toItem: window,
                        attribute: .left,
                        multiplier: 1,
                        constant: 0
                    ),
                    NSLayoutConstraint(
                        item: sliderContainer,
                        attribute: .bottom,
                        relatedBy: .equal,
                        toItem: window,
                        attribute: .bottom,
                        multiplier: 1,
                        constant: 0
                    ),
                    NSLayoutConstraint(
                        item: sliderContainer,
                        attribute: .centerX,
                        relatedBy: .equal,
                        toItem: window,
                        attribute: .centerX,
                        multiplier: 1,
                        constant: 0
                    ),
                    NSLayoutConstraint(
                        item: sliderContainer,
                        attribute: .height,
                        relatedBy: .equal,
                        toItem: nil,
                        attribute: .notAnAttribute,
                        multiplier: 1,
                        constant: {
                            let safeArea: UIEdgeInsets = {
                                if #available(iOS 11.0, *) {
                                    return window.safeAreaInsets
                                } else {
                                    return .zero
                                }
                            }()
                            return safeArea.bottom + sliderHeight
                        }()
                    )
                ]
            )
        }
    }
    
    public init() { }
    
    public func intercept(
        dispatch: @escaping DispatchFunction,
        state: @escaping () -> State?
    ) -> MiddlewareReturnType {
        return { next in
            return { action in
                self.handle(
                    action: action
                )
                next(action)
            }
        }
    }
    
}

private extension TimelineControlMiddleware {
    
    func handle(
        action: Action
    ) {
        if case NavigationCompletionAction.start(let window) = action {
            self.window = window
        }
        
        if let timelineAction = action as? TimelineCompletionAction {
            switch timelineAction {
            case .total(let total):
                slider.maximumValue = Float(total)
                slider.value = slider.maximumValue
            case .current(let current):
                let float = Float(current)
                if float != memory {
                    slider.value = float
                }
            default: return
            }
            memory = slider.value
        }
    }
    
}

private extension TimelineControlMiddleware {
    
    @IBAction func actionSwipe(
        _ gestureRecognizer: UISwipeGestureRecognizer
    ) {
        guard gestureRecognizer.state == .recognized else { return }
        isSliderHidden = gestureRecognizer.direction == .down
    }
    
    @IBAction func actionLongPress(
        _ gestureRecognizer: UILongPressGestureRecognizer
    ) {
        guard gestureRecognizer.state == .began else { return }
        isSliderHidden = !isSliderHidden
    }
    
    @IBAction func actionValueChanged() {
        let difference = Int(memory) - Int(slider.value)
        let action: TimelineAction = difference > 0 ? .back : .forward
        memory = floor(slider.value)

        Array(
            repeating: action,
            count: abs(difference)
        ).forEach(Manager.main.store.dispatch)
        
        window?.bringSubviewToFront(
            backgroundView
        )
        window?.bringSubviewToFront(
            sliderContainer
        )
    }
    
}

private extension TimelineControlMiddleware {
    
    private var sliderHeight: CGFloat {
        return 80
    }
    
    private var isSliderHidden: Bool {
        set {
            guard isSliderHidden != newValue else { return }
            backgroundView.isHidden = newValue
            
            let enableOrDisable = {
                var actions: [Action] = []
                
                let addOrRemove = newValue ?
                    ActionBlockerAction.removeFromWhitelist :
                    ActionBlockerAction.addToWhitelist
                    
                actions.append(
                    contentsOf: [
                        NavigationAction.self,
                        NavigationCompletionAction.self,
                        TimelineAction.self
                    ].map(addOrRemove)
                )
                
                actions.append(
                    contentsOf: [
                        newValue ? ActionBlockerAction.disable : ActionBlockerAction.enable,
                        newValue ? AnimationBlockerAction.disable : AnimationBlockerAction.enable
                    ] as [Action]
                )
                
                actions.forEach(Manager.main.store.dispatch)
            }
            
            if newValue {
                enableOrDisable()
            }
            
            window?.bringSubviewToFront(
                backgroundView
            )
            window?.bringSubviewToFront(
                sliderContainer
            )
            UIView.animate(
                withDuration: 0.2
            ) {
                self.sliderContainer.alpha = newValue ? 0 : 1
            }
            
            if !newValue {
                enableOrDisable()
            }
        }
        get {
            return sliderContainer.alpha == 0
        }
    }
    
}
