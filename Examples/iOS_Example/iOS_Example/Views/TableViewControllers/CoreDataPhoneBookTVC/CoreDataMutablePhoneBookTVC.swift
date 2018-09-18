//
//  MYNewCoreDataMutateTVC.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/17/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import Model

class CoreDataMutablePhoneBookTVC: CoreDataBasicTVC {
	
	struct MoveInfo {
		public let movingEntity: ContactEntity
		public let oldIndexPath: IndexPath
		public let newIndexPath: IndexPath
	}
	
	private var changeIsUserDriven: Bool = false
	
	public var updateMovingEntity: ((MoveInfo) -> Void)!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Core Data Mutable Phone Book"

		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false
		
		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		// self.navigationItem.rightBarButtonItem = self.editButtonItem
		
		let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonAction(_:)))
		
		let saveButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveBarButtonAction(_:)))
		
		self.navigationItem.rightBarButtonItems = [saveButtonItem, addButtonItem, self.editButtonItem]
		
		
		self.updateMovingEntity = { movingInfo in
			
			let movingEntity = movingInfo.movingEntity
			let oldIndexPath = movingInfo.oldIndexPath
			let newIndexPath = movingInfo.newIndexPath
			
			print("displayOrder \(Int(movingEntity.displayOrder))")
			
			func orderEntities(forEntities entities: [ContactEntity]) {
				let count = entities.count
				for i in 0..<count {
					let entity = entities[i]
					entity.displayOrder = Int64(i)
				}
			}
			
			let oldSectionEntities = self.model[oldIndexPath.section]!.entities
			
			var newSectionEntities: [ContactEntity]
			
			if newIndexPath.section != oldIndexPath.section {
				orderEntities(forEntities: oldSectionEntities)
				newSectionEntities = self.model[newIndexPath.section]!.entities
			}
			else {
				newSectionEntities = oldSectionEntities
			}
			
			orderEntities(forEntities: newSectionEntities)
			
			print("displayOrder \(Int(movingEntity.displayOrder))")
			
		}
		
	}
	
	override func configureModel() {
		self.model = Model(sectionKey: "firstName")
		self.model.sortSections = { $0.name < $1.name }
		self.model.sortEntities = { (entity1, entity2) -> Bool in
			
			if entity1.displayOrder == entity2.displayOrder {
				return entity1.firstName < entity2.firstName
			}
			else {
				return entity1.displayOrder < entity2.displayOrder
			}

		}
		super.configureModel()
	}
	
	@objc func addBarButtonAction(_ sender: UIBarButtonItem) {
		self.contactDetailsAlertController(for: nil)
	}
	
	@objc func saveBarButtonAction(_ sender: UIBarButtonItem) {
		
		try? self.context.save()
	}
	
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let section = self.model[section]
		return section?.name
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let contact = self.model[indexPath]
		self.contactDetailsAlertController(for: contact)
	}
	
	override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let entity = self.model[sourceIndexPath]!
		self.model.moveEntity(at: sourceIndexPath, to: destinationIndexPath, isUserDriven: true, completion: {
			self.updateMovingEntity(MoveInfo(movingEntity: entity, oldIndexPath: sourceIndexPath, newIndexPath: destinationIndexPath))
		})
		
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			self.model.remove(at: indexPath) { (entity) in
				self.context.delete(entity)
			}
		}
	}
	
	
	func contactDetailsAlertController(for contact: ContactEntity?) {
		
		var firstNameTextField: UITextField!
		var lastNameTextField: UITextField!
		var phoneTextField: UITextField!
		
		let alertController = UIAlertController(title: "Add Contact", message: nil, preferredStyle: .alert)
		alertController.addTextField { (textField) in
			firstNameTextField = textField
			firstNameTextField.placeholder = "First Name"
			firstNameTextField.text = contact?.firstName
			
		}
		
		alertController.addTextField { (textField) in
			lastNameTextField = textField
			lastNameTextField.placeholder = "Last Name"
			lastNameTextField.text = contact?.lastName
		}
		
		alertController.addTextField { (textField) in
			phoneTextField = textField
			phoneTextField.placeholder = "Phone Number"
			phoneTextField.text = contact?.phone
			phoneTextField.keyboardType = .phonePad
		}
		
		let doneButtonTitle = contact == nil ? "Add" : "Update"
		alertController.addAction(UIAlertAction(title: doneButtonTitle, style: .default, handler: { (action) in
			if contact != nil {
				let indexPath = self.model.indexPath(of: contact!)!
				let firstName = firstNameTextField.text!
				let lastName = lastNameTextField.text!
				let phone = phoneTextField.text!
				
				self.model.update(at: indexPath, mutate: { (contact) in
					contact.firstName = firstName
					contact.lastName = lastName
					contact.phone = phone
				}, completion: {
					if let indexPath = self.tableView.indexPathForSelectedRow {
						self.tableView.deselectRow(at: indexPath, animated: true)
					}
				})
			}
			else {
				
				
				let contact = ContactEntity(context: self.context)
				contact.id = 0
				contact.firstName = firstNameTextField.text!
				contact.lastName = lastNameTextField.text!
				contact.phone = phoneTextField.text!
				
				
				
				self.model.insert([contact], completion: {
					self.context.insert(contact)
				})
			}
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
			
			if let indexPath = self.tableView.indexPathForSelectedRow {
				self.tableView.deselectRow(at: indexPath, animated: true)
			}
			
		}))
		
		self.present(alertController, animated: true, completion: nil)
		
	}
	
	
}
