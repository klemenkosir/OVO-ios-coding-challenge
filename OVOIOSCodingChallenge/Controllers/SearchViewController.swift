//
//  SearchViewController.swift
//  OVOIOSCodingChallenge
//
//  Created by Klemen Košir on 30/05/2019.
//  Copyright © 2019 Our Very Own Pty Ltd. All rights reserved.
//

import UIKit

/// Delegate for SearchViewController
protocol SearchDelegate: class {
    /// Fuction is called when user taps the close button on the search bar.
    func searchEnded()
    
    /// Function is called everytime the search textfield is changed.
    ///
    /// - Parameter searchString: Current search string
    func searchViewDidChange(_ searchString: String?)
}

/// SearchViewController class handles an presents UI for the Search functionality.
/// Actions are handled through the delegate.
class SearchViewController: UIViewController {
    
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var widthConstraint: NSLayoutConstraint!
    
    private var visibleWidthConstraint: NSLayoutConstraint!
    
    /// Set your class to this delegate property to receive actions from search
    weak var delegate: SearchDelegate?
    
    static func viewController() -> SearchViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "searchViewController") as! SearchViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
     
        // Sets the initial visible width of the search bar
        visibleWidthConstraint = self.view.widthAnchor.constraint(equalToConstant: 60.0)
        visibleWidthConstraint.isActive = true
        
        // Adds target to the textField to notify us of every text change
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
    }
    
    /// Function is called when user taps on the search button
    @IBAction func searchButtonHandler(_ sender: Any) {
        textField.text = nil
        delegate?.searchViewDidChange(textField.text)
        widthConstraint.constant = self.view.superview!.frame.width
        UIViewPropertyAnimator(duration: 0.35, dampingRatio: 0.85) {
            self.visibleWidthConstraint.constant = self.view.superview!.frame.width
            self.view.superview!.layoutIfNeeded()
        }.startAnimation()
        // For better user experience we trigger selection haptic feedback
        UISelectionFeedbackGenerator().selectionChanged()
        //  Show keyboard on every search start
        textField.becomeFirstResponder()
    }
    
    
    // Function is called when user taps on the close button and end the search
    @IBAction func closeButtonHandler(_ sender: Any) {
        textField.resignFirstResponder()
        UIViewPropertyAnimator(duration: 0.3, dampingRatio: 0.85) {
            self.visibleWidthConstraint.constant = 60.0
            self.view.superview!.layoutIfNeeded()
            }.startAnimation()
        
        delegate?.searchEnded()
        // For better user experience we trigger selection haptic feedback
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

// MARK: - TextField Delegate
extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // on return we hide the keyboard
        textField.resignFirstResponder()
        return false
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        delegate?.searchViewDidChange(textField.text)
    }
    
}
