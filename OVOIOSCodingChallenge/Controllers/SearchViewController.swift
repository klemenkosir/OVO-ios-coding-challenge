//
//  SearchViewController.swift
//  OVOIOSCodingChallenge
//
//  Created by Klemen Košir on 30/05/2019.
//  Copyright © 2019 Our Very Own Pty Ltd. All rights reserved.
//

import UIKit

protocol SearchDelegate: class {
    func searchEnded()
    func searchViewDidChange(_ searchString: String?)
}

class SearchViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet private weak var widthConstraint: NSLayoutConstraint!
    private var visibleWidthConstraint: NSLayoutConstraint!
    
    weak var delegate: SearchDelegate?
    
    static func viewController() -> SearchViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "searchViewController") as! SearchViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
     
        visibleWidthConstraint = self.view.widthAnchor.constraint(equalToConstant: 60.0)
        visibleWidthConstraint.isActive = true
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
    }
    
    @IBAction func searchButtonHandler(_ sender: Any) {
        textField.text = nil
        textField.becomeFirstResponder()
        widthConstraint.constant = self.view.superview!.frame.width
        UIViewPropertyAnimator(duration: 0.35, dampingRatio: 0.85) {
            self.visibleWidthConstraint.constant = self.view.superview!.frame.width
            self.view.superview!.layoutIfNeeded()
        }.startAnimation()
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    @IBAction func closeButtonHandler(_ sender: Any) {
        textField.resignFirstResponder()
        UIViewPropertyAnimator(duration: 0.3, dampingRatio: 0.85) {
            self.visibleWidthConstraint.constant = 60.0
            self.view.superview!.layoutIfNeeded()
            }.startAnimation()
        delegate?.searchEnded()
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        delegate?.searchViewDidChange(textField.text)
    }
    
}
