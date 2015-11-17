//
//  ViewController.swift
//  StoreSearch
//
//  Created by Yasuhiro on 11/10/2015.
//  Copyright © 2015 yasuhiroyoshida. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

  struct TableViewCellIdentifiers {
    static let searchResultCell = "SearchResultCell"
    static let nothingFoundCell = "NothingFoundCell"
  }

  var searchResults = [SearchResult]()
  var hasSearched = false

  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)

    var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)

    cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)

    tableView.rowHeight = 80

    searchBar.becomeFirstResponder()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

extension SearchViewController: UISearchBarDelegate {

  func searchBarSearchButtonClicked(searchBar: UISearchBar) {

    hasSearched = true

    searchBar.resignFirstResponder()
    searchResults = [SearchResult]()

    if searchBar.text != "justin bieber" {
      for i in 0...2 {
        let searchResult = SearchResult()
        searchResult.name = String(format: "Fake Result %d for", i)
        searchResult.artistName = searchBar.text!
        searchResults.append(searchResult)
      }
    }
    tableView.reloadData()
  }

  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
    return .TopAttached
  }
}

extension SearchViewController: UITableViewDataSource {

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

    if hasSearched == false {
      return 0
    } else if searchResults.count == 0 {
      return 1
    } else {
      return searchResults.count
    }
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

    if searchResults.count == 0 {
      return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
      let searchResult = searchResults[indexPath.row]
      cell.nameLabel.text = searchResult.name
      cell.artistNameLabel.text = searchResult.artistName
      return cell
    }
  }
}

extension SearchViewController: UITableViewDelegate {

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }

  func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    if searchResults.count == 0 {
      return nil
    } else {
      return indexPath
    }
  }
}