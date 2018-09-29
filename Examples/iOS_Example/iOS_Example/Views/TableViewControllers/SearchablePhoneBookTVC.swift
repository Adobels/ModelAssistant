//
//  SearchableTableViewController.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/8/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

/*
Abstract:
	In this file you see, how we use model assistant to implement a search controller.
*/

import UIKit
import ModelAssistant

class SearchablePhoneBookTVC: SimplePhoneBookTVC {
	
	var searchResults: [Contact] = []
	
	var isSearching: Bool = false
	
	var searchController: UISearchController!

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Searchable Phone Book"
		
	}
	
	override func configureModelAssistant(sectionKey: String?) {
		self.configureSearchController()
		super.configureModelAssistant(sectionKey: "firstName")
		self.assistant.delegate = self
		self.assistant.sortEntities = { $0.firstName < $1.firstName }
		self.assistant.sortSections = { $0.name < $1.name }
		
	}
	
	func configureSearchController() {
		self.searchController = UISearchController(searchResultsController: nil)
		self.searchController.searchResultsUpdater = self
		
		searchController.delegate = self
		searchController.dimsBackgroundDuringPresentation = false // default is YES
		searchController.searchBar.delegate = self    // so we can monitor text changes + others
		
		definesPresentationContext = true
		
		navigationController?.navigationBar.prefersLargeTitles = true
		
		navigationItem.searchController = searchController
		
		// We want the search bar visible all the time.
		navigationItem.hidesSearchBarWhenScrolling = false
	}
	
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return self.isSearching ? 1 : super.numberOfSections(in: tableView)
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return self.isSearching ? self.searchResults.count : super.tableView(tableView, numberOfRowsInSection: section)
	}
	
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let section = self.assistant[section]
		return isSearching ? nil : section?.name
	}
	
	override func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
		
		let entity = self.isSearching ? self.searchResults[indexPath.row] : self.assistant[indexPath]
		// Configure the cell...
		cell.textLabel?.text =  entity?.fullName
		
		// Only load cached images; defer new downloads until scrolling ends
		if entity?.image == nil
		{
			if (self.tableView.isDragging == false && self.tableView.isDecelerating == false)
			{
				self.startIconDownload(entity!)
			}
			
			// if a download is deferred or in progress, return a placeholder image
			cell.imageView?.image = UIImage(named: "Placeholder")
		}
		else
		{
			cell.imageView?.image = entity?.image
		}
		cell.imageView?.contentMode = .center
		
	}
	
	// called by our ImageDownloader when an icon is ready to be displayed
	override func downloaded<T>(_ image: UIImage?, forEntity entity: T) {

		if isSearching {
			if let index = self.searchResults.index(of: entity as! Contact) {
				self.searchResults[index].image = image
				let indexPath = IndexPath(row: index, section: 0)
				if let cell = self.tableView.cellForRow(at: indexPath) {
					self.configure(cell, at: indexPath)
				}
			}
		}
		
		super.downloaded(image, forEntity: entity)
	}

}

extension SearchablePhoneBookTVC: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
	
	func updateSearchResults(for searchController: UISearchController) {
		if let text = searchController.searchBar.text {
			if text.isEmpty {
				self.searchResults = self.assistant.getAllEntities(sortedBy: nil)
			}
			else {
				self.searchResults = self.assistant.filteredEntities(with: { $0.fullName.contains(text) })
			}
			self.tableView.reloadData()
		}
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		self.isSearching = false
	}
	
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		self.isSearching = true
	}
	
}

