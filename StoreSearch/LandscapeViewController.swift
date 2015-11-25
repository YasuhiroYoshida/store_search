//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by Yasuhiro on 11/24/2015.
//  Copyright © 2015 yasuhiroyoshida. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var pageControl: UIPageControl!

  @IBAction func pageChanged(sender: UIPageControl) {
    UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: {
      self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage), y: 0)
    }, completion: nil)
  }

  var search: Search!
  private var firstTime = true
  private var downloadTasks = [NSURLSessionDownloadTask]()

  deinit {
    print("deinit \(self)")
    for task in downloadTasks {
      task.cancel()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.removeConstraints(view.constraints)
    view.translatesAutoresizingMaskIntoConstraints = true

    pageControl.removeConstraints(pageControl.constraints)
    pageControl.translatesAutoresizingMaskIntoConstraints = true

    scrollView.removeConstraints(scrollView.constraints)
    scrollView.translatesAutoresizingMaskIntoConstraints = true

    scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)

    pageControl.numberOfPages = 0
    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    scrollView.frame = view.bounds
    pageControl.frame = CGRect(
      x: 0,
      y: view.frame.size.height - pageControl.frame.size.height,
      width: view.frame.size.width,
      height: pageControl.frame.size.height
    )

    if firstTime {
      firstTime = false

      switch search.state {
      case .NotSearchedYet:
        break
      case .Loading:
        showSpinner()
      case .NoResults:
        showNothingFoundLabel()
      case .Results(let list):
        tileButtons(list)
      }
    }
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    if segue.identifier == "ShowDetail" {
      if case .Results(let list) = search.state {
        let detailViewController = segue.destinationViewController as! DetailViewController
        let searchResult = list[sender!.tag - 2000]
        detailViewController.searchResult = searchResult
      }
    }
  }

  func searchResultsReceived() {
    hideSpinner()

    switch search.state {
    case .NotSearchedYet, .Loading:
      break
    case .NoResults:
      showNothingFoundLabel()
    case .Results(let list):
      return tileButtons(list)
    }
  }

  func buttonPressed(sender: UIButton) {
    performSegueWithIdentifier("ShowDetail", sender: sender)
  }

  private func tileButtons(searchResults: [SearchResult]) {
    // first, determine the grid specs depending of the dimensions of the device
    var columnsPerPage = 5
    var rowsPerPage = 3
    var itemWidth: CGFloat = 96
    var itemHeight: CGFloat = 88
    var marginX: CGFloat = 0
    var marginY: CGFloat = 20

    let scrollViewWidth = scrollView.bounds.size.width

    switch scrollViewWidth {
    case 568:
      columnsPerPage = 6
      itemWidth = 94
      marginX = 2
    case 667:
      columnsPerPage = 7
      itemWidth = 95
      itemHeight = 98
      marginX = 1
      marginY = 29
    case 736:
      columnsPerPage = 8
      rowsPerPage = 4
      itemWidth = 92
    default:
      break
    }

    let buttonWidth: CGFloat = 82
    let buttonHeight: CGFloat = 82
    let paddingHorz = (itemWidth - buttonWidth)/2
    let paddingVert = (itemHeight - buttonHeight)/2

    // second, populate the grid based on the spec
    var row = 0
    var column = 0
    var x = marginX

    for (index, searchResult) in searchResults.enumerate() {
      let button = UIButton(type: .Custom)
      button.setBackgroundImage(UIImage(named: "LandscapeButton"), forState: .Normal)
      downloadImageForSearchResult(searchResult, andPlaceOnButton: button)

      button.frame = CGRect(
        x: x + paddingHorz,
        y: marginY + CGFloat(row) * itemHeight + paddingVert,
        width: buttonWidth, height: buttonHeight)

      button.tag = 2000 + index
      button.addTarget(self, action: Selector("buttonPressed:"), forControlEvents: .TouchUpInside)

      scrollView.addSubview(button)

      ++row
      if row == rowsPerPage {
        row = 0; x += itemWidth; ++column

        if column == columnsPerPage {
          column = 0; x += marginX * 2 // fills left-over space, if any, to the right of the screen before starting filling a new page
        }
      }
    }

    // third, determine how many pages will be needed
    let buttonsPerPage = columnsPerPage * rowsPerPage
    let numPages = 1 + (searchResults.count - 1) / buttonsPerPage


    scrollView.contentSize = CGSize(width: CGFloat(numPages) * scrollViewWidth, height: scrollView.bounds.size.height)
    print("Number of pages: \(numPages)")

    pageControl.numberOfPages = numPages
    pageControl.currentPage = 0
  }

  private func downloadImageForSearchResult(searchResult: SearchResult, andPlaceOnButton button: UIButton) {

    if let url = NSURL(string: searchResult.artworkURL60) {
      let session = NSURLSession.sharedSession()
      let downloadTask = session.downloadTaskWithURL(url) {
        [weak button] url, response, error in

        if error == nil, let url = url, data = NSData(contentsOfURL: url), image = UIImage(data: data) {
          dispatch_async(dispatch_get_main_queue()) {
            if let button = button {
              button.setImage(image, forState: .Normal)
            }
          }
        }
      }
      downloadTask.resume()
      downloadTasks.append(downloadTask)
    }
  }

  private func showSpinner() {

    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    spinner.center = CGPoint(x: CGRectGetMidX(scrollView.bounds) + 0.5, y: CGRectGetMidY(scrollView.bounds) + 0.5)
    spinner.tag = 1000
    view.addSubview(spinner)
    spinner.startAnimating()
  }

  private func hideSpinner() {
    view.viewWithTag(1000)?.removeFromSuperview()
  }

  private func showNothingFoundLabel() {

    let label = UILabel(frame: CGRect.zero)
    label.text = "Nothing Found"
    label.textColor = UIColor.whiteColor()
    label.backgroundColor = UIColor.clearColor()
    label.sizeToFit()

    var rect = label.frame
    rect.size.width = ceil(rect.size.width / 2) * 2
    rect.size.height = ceil(rect.size.height / 2) * 2

    label.frame = rect
    label.center = CGPoint(x: CGRectGetMidX(scrollView.bounds), y: CGRectGetMidY(scrollView.bounds))

    view.addSubview(label)
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

extension LandscapeViewController: UIScrollViewDelegate {

  func  scrollViewDidScroll(scrollView: UIScrollView) {
    let width = scrollView.bounds.size.width
    let currentPage = Int((scrollView.contentOffset.x + width/2)/width)
    pageControl.currentPage = currentPage
  }

}
