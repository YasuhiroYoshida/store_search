//
//  Search.swift
//  StoreSearch
//
//  Created by Yasuhiro on 11/25/2015.
//  Copyright © 2015 yasuhiroyoshida. All rights reserved.
//

import Foundation
import UIKit

typealias SearchComplete = (Bool) -> Void

class Search {

  enum Category: Int {
    case All = 0
    case Music = 1
    case Software = 2
    case Ebooks = 3

    var entityName: String {
      switch self {
      case .All:
        return ""
      case .Music:
        return "musicTrack"
      case .Software:
        return "software"
      case .Ebooks:
        return "ebook"
      }
    }
  }

  enum State {
    case NotSearchedYet
    case Loading
    case NoResults
    case Results([SearchResult])
  }

  private(set) var state: State = .NotSearchedYet
//  var searchResults = [SearchResult]()
//  var hasSearched = false
//  var isLoading = false

  private var dataTask: NSURLSessionDataTask? = nil

  func performSearchForText(text: String, category: Category, completion: SearchComplete) {

    if !text.isEmpty {
      dataTask?.cancel()
      UIApplication.sharedApplication().networkActivityIndicatorVisible = true

      state = .Loading

      let url = urlWithSeachText(text, category: category)

      let session = NSURLSession.sharedSession()

      dataTask = session.dataTaskWithURL(url, completionHandler: { data, response, error in

        self.state = .NotSearchedYet
        var success = false
        if let error = error where error.code == -999 {
          return
        }

        if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200,
          let data = data, dictionary = self.parseJSON(data) {

            var searchResults = self.parseDictionary(dictionary)
            if searchResults.isEmpty {
              self.state = .NoResults
            } else {
              searchResults.sortInPlace(<)
              self.state = .Results(searchResults)
            }
            success = true

        }

        dispatch_async(dispatch_get_main_queue()) {
          UIApplication.sharedApplication().networkActivityIndicatorVisible = false
          completion(success)
        }
      })

      dataTask?.resume()
    }
  }

  private func urlWithSeachText(searchText: String, category: Category) -> NSURL {

    let entityName = category.entityName

    let locale = NSLocale.autoupdatingCurrentLocale()
    let language = locale.localeIdentifier
    let countryCode = locale.objectForKey(NSLocaleCountryCode) as! String

    let escapedSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!

    let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200&entity=%@&lang=%@&country=%@", escapedSearchText, entityName, language, countryCode)

    let url = NSURL(string: urlString)
    print("URL: \(url!)")
    return url!
  }

  private func parseJSON(data: NSData) -> [String: AnyObject]? {

    do {
      return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
    } catch {
      print("JSON parse error: \(error)")
      return nil
    }
  }

  private func parseDictionary(dictionary: [String: AnyObject]) -> [SearchResult] {

    guard let array = dictionary["results"] as? [AnyObject] else {
      print("Expected 'results' array")
      return []
    }

    var searchResults = [SearchResult]()

    for resultDict in array {
      if let resultDict = resultDict as? [String: AnyObject] {

        var searchResult: SearchResult?

        if let wrapperType = resultDict["wrapperType"] as? String {
          switch wrapperType {
          case "track":
            searchResult = parseTrack(resultDict)
          case "audiobook":
            searchResult = parseAudioBook(resultDict)
          case "software":
            searchResult = parseSoftware(resultDict)
          default:
            break
          }
        } else if let kind = resultDict["kind"] as? String
          where kind == "ebook" {
            searchResult = parseEBook(resultDict)
        }

        if let result = searchResult {
          searchResults.append(result)
        }
      }
    }

    return searchResults
  }

  private func parseTrack(dictionary: [String: AnyObject]) -> SearchResult {

    let searchResult = SearchResult()
    searchResult.name = dictionary["trackName"] as! String
    searchResult.artistName = dictionary["artistName"] as! String
    searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
    searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
    searchResult.storeURL = dictionary["trackViewUrl"] as! String
    searchResult.kind = dictionary["kind"] as! String
    searchResult.currency = dictionary["currency"] as! String

    if let price = dictionary["trackPrice"] as? Double {
      searchResult.price = price
    }

    if let genre = dictionary["genre"] as? String {
      searchResult.genre = genre
    }

    return searchResult
  }

  private func parseAudioBook(dictionary: [String: AnyObject]) -> SearchResult {

    let searchResult = SearchResult()
    searchResult.name = dictionary["collectionName"] as! String
    searchResult.artistName = dictionary["artistName"] as! String
    searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
    searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
    searchResult.storeURL = dictionary["collectionViewUrl"] as! String
    searchResult.kind = "audiobook"
    searchResult.currency = dictionary["currency"] as! String

    if let price = dictionary["collectionPrice"] as? Double {
      searchResult.price = price
    }
    if let genre = dictionary["primaryGenreName"] as? String {
      searchResult.genre = genre
    }

    return searchResult
  }

  private func parseSoftware(dictionary: [String: AnyObject]) -> SearchResult {

    let searchResult = SearchResult()
    searchResult.name = dictionary["trackName"] as! String
    searchResult.artistName = dictionary["artistName"] as! String
    searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
    searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
    searchResult.storeURL = dictionary["trackViewUrl"] as! String
    searchResult.kind = dictionary["kind"] as! String
    searchResult.currency = dictionary["currency"] as! String

    if let price = dictionary["price"] as? Double {
      searchResult.price = price
    }
    if let genre = dictionary["primaryGenreName"] as? String {
      searchResult.genre = genre
    }

    return searchResult
  }

  private func parseEBook(dictionary: [String: AnyObject]) -> SearchResult {
    let searchResult = SearchResult()
    searchResult.name = dictionary["trackName"] as! String
    searchResult.artistName = dictionary["artistName"] as! String
    searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
    searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
    searchResult.storeURL = dictionary["trackViewUrl"] as! String
    searchResult.kind = dictionary["kind"] as! String
    searchResult.currency = dictionary["currency"] as! String

    if let price = dictionary["price"] as? Double {
      searchResult.price = price
    }
    if let genres: AnyObject = dictionary["genres"] {
      searchResult.genre = (genres as! [String]).joinWithSeparator(", ")
    }
    
    return searchResult
  }
}
