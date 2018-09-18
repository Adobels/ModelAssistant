//
//  CoreDataModel.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/13/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation
import CoreData

/*
var fetchRequest: NSFetchRequest<Entity> {
return fetchedResultsController.fetchRequest
}

var fetchBatchSize: Int {
get {
return fetchRequest.fetchBatchSize
}

set {
fetchRequest.fetchBatchSize = newValue
}
}

private var fetchedResultsController: NSFetchedResultsController<Entity>!

private var context: NSManagedObjectContext!

init(context: NSManagedObjectContext, sortDescriptors: [NSSortDescriptor],  predicate: NSPredicate?, sectionKey: String?, cacheName: String?) {
super.init()

// Set up the fetched results controller if needed.
// Create the fetch request for the entity.
let fetchRequest = NSFetchRequest<Entity>(entityName: "\(Entity.self)")


fetchRequest.sortDescriptors = sortDescriptors

// Edit the section name key path and cache name if appropriate.
// nil for section name key path means "no sections".
let controller = NSFetchedResultsController<Entity>(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionKey, cacheName: cacheName)

//		self.fetchedResultsController.delegate = self


self.fetchedResultsController = controller

}


var sectionKey: String? {
return self.fetchedResultsController.sectionNameKeyPath
}

var sortEntities: [NSSortDescriptor]?

var sortSections: (NSSortDescriptor)?

*/

/*
typealias SortEntities = [NSSortDescriptor]

typealias SortSections = NSSortDescriptor

typealias Section = NSFetchedResultsSectionInfo

*/

public class CoreDataModel<Entity: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate, ModelProtocol {

	
	public struct MoveInfo {
		public let movingEntity: Entity
		public let oldIndexPath: IndexPath
		public let newIndexPath: IndexPath
	}
	
	private var changeIsUserDriven: Bool = false
	
	public var updateMovingEntity: ((MoveInfo) -> Void)?
	
	
	private var fetchRequest: NSFetchRequest<Entity> {
		return controller.fetchRequest
	}

	public var fetchBatchSize: Int {
		get {
			return fetchRequest.fetchBatchSize
		}

		set {
			fetchRequest.fetchBatchSize = newValue
		}
	}
//
	private var controller: NSFetchedResultsController<Entity>!

	private var context: NSManagedObjectContext

	public init(context: NSManagedObjectContext, sortDescriptors: [NSSortDescriptor],  predicate: NSPredicate?, sectionKey: String?, cacheName: String?) {
		self.context = context
		super.init()

		// Set up the fetched results controller if needed.
		// Create the fetch request for the entity.
		let fetchRequest = NSFetchRequest<Entity>(entityName: "\(Entity.self)")


		fetchRequest.sortDescriptors = sortDescriptors

		// Edit the section name key path and cache name if appropriate.
		// nil for section name key path means "no sections".
		let controller = NSFetchedResultsController<Entity>(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionKey, cacheName: cacheName)

		self.controller = controller

		self.controller.delegate = self


	}


	public var sectionKey: String? {
		return self.controller.sectionNameKeyPath
	}

	public var sortEntities: [NSSortDescriptor]?

	public var sortSections: (NSSortDescriptor)?

	public var filter: NSPredicate?

//	var filter: ((Entity) -> Bool)?

	public var delegate: ModelDelegate?

	public var isEmpty: Bool {
		return self.controller.sections == nil
	}

	public var numberOfSections: Int {
		return self.controller.sections?.count ?? 0
	}

	public var numberOfWholeEntities: Int {
		return self.controller.fetchedObjects?.count ?? 0
	}

	public func numberOfEntites(at sectionIndex: Int) -> Int {
		return self.controller.sections?[sectionIndex].numberOfObjects ?? 0
	}

	public func index(of section: NSFetchedResultsSectionInfo) -> Int? {

		return self.controller.sections?.index(where: { (sec) -> Bool in
			return sec.indexTitle == section.indexTitle && sec.name == section.name && sec.numberOfObjects == section.numberOfObjects
		})
	}

	public func indexPath(of entity: Entity) -> IndexPath? {
		return self.controller.indexPath(forObject: entity)
	}
	
	public func insert(_ newEntity: Entity, at indexPath: IndexPath, completion: (() -> ())?) {
		self.context.insert(newEntity)
		if let oldIndexPath = self.controller.indexPath(forObject: newEntity) {
			self.moveEntity(at: oldIndexPath, to: indexPath, isUserDriven: false, completion: completion)
		}
	}

	public func fetch(_ entities: [Entity], completion: (() -> ())?) {
		self.context.insert(entities)
		
		do {
			try self.context.save()
			try self.controller.performFetch()
			completion?()

		} catch {

			print("\(type(of: self.controller)) performFetch() gots error: ", error)
		}
	}

	public func insert(_ newEntities: [Entity], completion: (() -> ())?) {
		self.context.insert(newEntities)
	}

	public func moveEntity(at indexPath: IndexPath, to newIndexPath: IndexPath, isUserDriven: Bool, completion: (() -> ())?) {
		let entity = self.controller.object(at: indexPath)
		let moveInfo = MoveInfo(movingEntity: entity, oldIndexPath: indexPath, newIndexPath: newIndexPath)
		if self.updateMovingEntity != nil {
			self.changeIsUserDriven = isUserDriven
			self.updateMovingEntity!(moveInfo)
		}
	}

	public func update(at indexPath: IndexPath, mutate: @escaping (inout Entity) -> Void, completion: (() -> Void)?) {
		var entity = self.controller.object(at: indexPath)
		mutate(&entity)
	}

	public func update(_ entity: Entity, mutate: @escaping (inout Entity) -> Void, completion: (() -> Void)?) {
		var entity = entity
		mutate(&entity)
		completion?()
	}

	public func remove(at indexPath: IndexPath, completion: ((Entity) -> ())?) {
		let entity = self.controller.object(at: indexPath)
		self.context.delete(entity)
	}

	public func remove(_ entity: Entity, completion: ((Entity) -> ())?) {
		self.context.delete(entity)
	}

//	public func removeAllEntities(atSection sectionIndex: Int, completion: (() -> ())?) {
//		if let entities = self.controller.sections?[sectionIndex].objects as? [Entity] {
//			for entity in entities {
//				self.context.delete(entity)
//			}
//		}
//	}

	public func removeSection(at sectionIndex: Int, completion: ((NSFetchedResultsSectionInfo) -> ())?) {
		if let entities = self.controller.sections?[sectionIndex].objects as? [Entity] {
			for entity in entities {
				self.context.delete(entity)
			}
		}

	}

	public func removeAll(completion: (() -> ())?) {
		//Fill this later
	}

	public func sortEntities(atSection sectionIndex: Int, by sort: [NSSortDescriptor], completion: (() -> Void)?) {
		//Fill this later
	}

	public func reorder(completion: (() -> Void)?) {
		//Fill this later
	}

	public func sortSections(by sort: NSSortDescriptor, completion: (() -> Void)?) {
		//Fill this later
	}

	public func filteredEntities(atSection sectionIndex: Int, with filter: NSPredicate) -> [Entity] {
		//Fill this later
		return []
	}

	public func filteredEntities(with filter: NSPredicate) -> [Entity] {
		//Fill this later
		return []
	}

	public func section(at sectionIndex: Int) -> NSFetchedResultsSectionInfo? {
		return self.controller.sections?[sectionIndex]
	}

	public func entity(at indexPath: IndexPath) -> Entity? {
		return self.controller.object(at: indexPath)
	}
	
	public func getAllEntities(sortedBy sort: [NSSortDescriptor]?) -> [Entity] {
		return []
	}

	//DelegateMethods
	
	public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		self.delegate?.modelWillChangeContent()
	}
	
	public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		changeIsUserDriven = false
		self.delegate?.modelDidChangeContent()
	}

	
	public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
		return nil
	}
	
	public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
		
		self.delegate?.model(didChange: sectionInfo, atSectionIndex: sectionIndex, for: ModelChangeType(type: type), newSectionIndex: sectionIndex)
	}
	
	public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		if !changeIsUserDriven {
			self.delegate?.model(didChange: [anObject as! NSManagedObject], at: indexPath != nil ? [indexPath!] : nil, for: ModelChangeType(type: type), newIndexPaths: newIndexPath != nil ? [newIndexPath!] : nil)
		}
	}
	

}

extension NSManagedObjectContext {

	func insert(_ objects: [NSManagedObject]) {
		for object in objects {
			self.insert(object)
		}
	}
}

extension ModelChangeType {
	
	init(type: NSFetchedResultsChangeType) {
		switch type {
		case .insert:
			self = .insert
			
		case .delete:
			self = .delete

		case .move:
			self = .move

		case .update:
			self = .update
		}
	}
	
}

