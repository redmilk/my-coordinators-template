//
//  ViewController.swift
//  MyCoordinatorsTemplate
//
//  Created by Danyl Timofeyev on 28.12.2020.
//  Copyright © 2020 Danyl Timofeyev. All rights reserved.
//

import UIKit
import RxCocoa

fileprivate var scrollViewKey: UInt8 = 0

open class ViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
        
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        Logger.initialization(entity: self)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    deinit {
        Logger.deinitialization(entity: self)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        /// iOS default modal dismiss handling by dragging down VC
        /// for current coordinator end()
        
        /// if this controller is embedded in navigation controller
        if let nc = navigationController, nc.isBeingDismissed {
            handleDefaultModalDismissing()
        }
        /// if this controller is not embedded in navigation controller
        if isBeingDismissed {
            handleDefaultModalDismissing()
        }
    }
    
    /// override this for handling iOS default modal dismissing, by dragging
    func handleDefaultModalDismissing() { }
    /// override this for uitextfield return key pressing
    func onTextFieldShouldReturn(_ textField: UITextField) { }
    
    @objc func handleTap() {
        textFieldsArrayForFreeSpaceTapKeyboardHiding.forEach { $0.resignFirstResponder() }
        textViewArrayForFreeSpaceTapKeyboardHiding.forEach { $0.resignFirstResponder() }
    }
        
    /// for non reactive text source
    func addTextSourceFieldToConvenienceKeyboardHidingList(textFields: [UITextField] = [],
                                                                  textViews: [UITextView] = []
    ) {
        textFieldsArrayForFreeSpaceTapKeyboardHiding.append(contentsOf: textFields)
        textViewArrayForFreeSpaceTapKeyboardHiding.append(contentsOf: textViews)
        
        textFieldsArrayForFreeSpaceTapKeyboardHiding.forEach { $0.delegate = self }
        textViewArrayForFreeSpaceTapKeyboardHiding.forEach { $0.delegate = self }
    }
    
    // MARK: - Keyboard events
    func setupKeyboardNotifcationListenerForScrollView(_ scrollView: UIScrollView) {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        internalScrollView = scrollView
    }
    
    func removeKeyboardNotificationListeners() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    fileprivate var internalScrollView: UIScrollView! {
        get {
            return objc_getAssociatedObject(self, &scrollViewKey) as? UIScrollView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &scrollViewKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey]?.cgRectValue
        let keyboardFrameConvertedToViewFrame = view.convert(keyboardFrame!, from: nil)
        let options = UIView.AnimationOptions.beginFromCurrentState
        UIView.animate(withDuration: animationDuration, delay: 0, options:options, animations: { () -> Void in
            let insetHeight = (self.internalScrollView.frame.height + self.internalScrollView.frame.origin.y) - keyboardFrameConvertedToViewFrame.origin.y
            self.internalScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: insetHeight + 24.0, right: 0)
            self.internalScrollView.scrollIndicatorInsets  = UIEdgeInsets(top: 0, left: 0, bottom: insetHeight, right: 0)
        }) { (complete) -> Void in
            self.internalScrollView.isScrollEnabled = false
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let options = UIView.AnimationOptions.beginFromCurrentState
        UIView.animate(withDuration: animationDuration, delay: 0, options:options, animations: { () -> Void in
            self.internalScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.internalScrollView.scrollIndicatorInsets  = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }) { (complete) -> Void in
            self.internalScrollView.isScrollEnabled = true
        }
    }
    
    // MARK: - UITextFieldDelegate
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        onTextFieldShouldReturn(textField)
        return true
    }
    
    // MARK: - UITextViewDelegate
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
        
    /// convenience for non-rx text sources
    var textFieldsArrayForFreeSpaceTapKeyboardHiding: [UITextField] = []
    var textViewArrayForFreeSpaceTapKeyboardHiding: [UITextView] = []
}
