//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Yasuhiro on 11/22/2015.
//  Copyright © 2015 yasuhiroyoshida. All rights reserved.
//

import UIKit
import MessageUI

class DetailViewController: UIViewController {

  enum AnimationStyle {
    case Slide
    case Fade
  }

  var searchResult: SearchResult! {
    didSet {
      if isViewLoaded() {
        updateUI()
        popupView.hidden = false
      }
    }
  }
  var downloadTask: NSURLSessionDownloadTask?
  var dismissAnimationStyle = AnimationStyle.Fade
  var isPopup = false

  @IBOutlet weak var popupView: UIView!
  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var kindLabel: UILabel!
  @IBOutlet weak var genreLabel: UILabel!
  @IBOutlet weak var priceButton: UIButton!

  @IBAction func close() {
    dismissAnimationStyle = .Slide
    dismissViewControllerAnimated(true, completion: nil)
  }
  @IBAction func openInStore(){
    if let url = NSURL(string: searchResult.storeURL) {
      UIApplication.sharedApplication().openURL(url)
    }
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    modalPresentationStyle = .Custom
    transitioningDelegate = self
  }

  deinit {
    print("deinit \(self)")
    downloadTask?.cancel()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
    popupView.layer.cornerRadius = 10

    if isPopup {
      let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("close"))
      gestureRecognizer.cancelsTouchesInView = false
      gestureRecognizer.delegate = self
      view.addGestureRecognizer(gestureRecognizer)
      view.backgroundColor = UIColor.clearColor()
    } else {
      view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
      popupView.hidden = true
      if let displayName = NSBundle.mainBundle().localizedInfoDictionary?["CFBundleDisplayName"] as? String {
        title = displayName
      }
    }

    if searchResult != nil {
      updateUI()
    }

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowMenu" {
      let controller = segue.destinationViewController as! MenuViewController
      controller.delegate = self
    }
  }


  func updateUI() {

    nameLabel.text = searchResult.name
    if searchResult.artistName.isEmpty {
      artistNameLabel.text = NSLocalizedString("Unknown", comment: "Localized artistNameLabel: Unknown")
    } else {
      artistNameLabel.text = searchResult.artistName
    }
    kindLabel.text = searchResult.kindForDisplay()
    genreLabel.text = searchResult.genre

    let formatter = NSNumberFormatter()
    formatter.numberStyle = .CurrencyStyle
    formatter.currencyCode = searchResult.currency

    let priceText: String
    if searchResult.price == 0 {
      priceText = "Free"
    } else if let text = formatter.stringFromNumber(searchResult.price) {
      priceText = text
    } else {
      priceText = ""
    }
    priceButton.setTitle(priceText, forState: .Normal)

    if let url = NSURL(string: searchResult.artworkURL100) {
      downloadTask = artworkImageView.loadImageWithURL(url)
    }
  }

  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      // Get the new view controller using segue.destinationViewController.
      // Pass the selected object to the new view controller.
  }
  */
}

extension DetailViewController: UIViewControllerTransitioningDelegate {

  func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
    return DimmingPresentaionController(presentedViewController: presented, presentingViewController: presenting)
  }

  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return BounceAnimationController()
  }

  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

    switch dismissAnimationStyle {
    case .Slide:
      return SlideOutAnimationController()
    case .Fade:
      return FadeOutAnimationController()
    }
  }
}

extension DetailViewController: UIGestureRecognizerDelegate {

  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
    return (touch.view === self.view)
  }
}

extension DetailViewController: MenuViewControllerDelegate {

  func menuViewControllerSendSupportEmail(_: MenuViewController) {

    dismissViewControllerAnimated(true) {
      if MFMailComposeViewController.canSendMail() {
        let controller = MFMailComposeViewController()
        controller.setSubject(NSLocalizedString("Support Request", comment: "Email subject"))
        controller.setToRecipients(["abcs@gmail.com"])
        self.presentViewController(controller, animated: true, completion: nil)
        controller.mailComposeDelegate = self
        controller.modalPresentationStyle = .FormSheet
      }
    }
  }
}

extension DetailViewController: MFMailComposeViewControllerDelegate {

  func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}
