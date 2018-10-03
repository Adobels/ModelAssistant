//
//  ModelTests.swift
//  ModelTests
//
//  Created by Seyed Samad Gholamzadeh on 8/26/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import XCTest
@testable import ModelAssistant

class ModelTestsBasic: ModelTestsBasic0 {

	private let dispatchQueue = DispatchQueue(label: "com.ThreadSafePhoneBookTVC.ConcirrentGCD.DispatchQueue", attributes: DispatchQueue.Attributes.concurrent)

	func testIndexOfEntityWithId() {
		let entity = Member(data: ["id":1])!
		let indexPath = self.model.indexPathForEntity(withUniqueValue: entity.uniqueValue)
		XCTAssertNotNil(indexPath)
	}

	func testIndexOfEntity() {
		let entity = Member(data: ["id":1,"first_name":"Emma","last_name":"McGinty"])!
		let indexPath = self.model.indexPath(for: entity)
		XCTAssertNotNil(indexPath)

		let indexPathWithUniqueValue = self.model.indexPathForEntity(withUniqueValue: entity.uniqueValue)

		XCTAssertEqual(indexPath, indexPathWithUniqueValue)
	}

	func testModelAfterFetch() {
		var members = self.members!

		if let filter = self.filter {
			members = members.filter(filter)
		}

		if let sort = self.sortEntities {
			members = members.sorted(by: sort)
		}

		XCTAssert(self.model.section(at: 0)!.name == "")
//		XCTAssert(self.model.section(at: 0)!.entities == members)
	}

	func testCountOfEntities() {
		if let filter = self.filter {
			let members = self.members.filter(filter)
			XCTAssertEqual(self.model.numberOfWholeEntities, members.count)
		}
		else {
			XCTAssertEqual(self.model.numberOfWholeEntities, self.members.count)
		}
	}

	func testConcurrentChangedEntity() {

		let section = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))
		let row = Int(arc4random_uniform(UInt32(self.model.numberOfEntites(at: section))))

		let indexPath = IndexPath(row: row, section: section)

		let expectFirstUpdate = expectation(description: "update first name")
		let expectSecondUpdate = expectation(description: "update second name")
		self.dispatchQueue.async {
			self.model.update(at: indexPath, mutate:  { (contact) in
				contact.firstName = "Joooooojoooo"
			}, completion: {
				expectFirstUpdate.fulfill()
			})
		}


		self.dispatchQueue.async {
			self.model.update(at: indexPath, mutate:  { (contact) in
				contact.lastName = "Talaaaaaaaieeeee"
			}, completion: {
				expectSecondUpdate.fulfill()
			})
		}
		wait(for: [expectFirstUpdate, expectSecondUpdate], timeout: 5)

		let entity = self.model[indexPath]!
		XCTAssertEqual(entity.firstName, "Joooooojoooo")
		XCTAssertEqual(entity.lastName, "Talaaaaaaaieeeee")
	}

	func testConcurrentMovedEntity() {
		let section = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))
		let row = Int(arc4random_uniform(UInt32(self.model.numberOfEntites(at: section))))

		let indexPath = IndexPath(row: row, section: section)

		let newSection = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))
		let newRow = Int(arc4random_uniform(UInt32(self.model.numberOfEntites(at: newSection))))

		let newIndexPath = IndexPath(row: newRow, section: newSection)


		let expectFirstUpdate = expectation(description: "update first name")
		let expectSecondUpdate = expectation(description: "update second name")



		self.dispatchQueue.async {

			self.model.moveEntity(at: indexPath, to: newIndexPath, isUserDriven: true, completion: {
				expectFirstUpdate.fulfill()
			})

//			self.model.update(at: indexPath, mutate:  { (contact) in
//				contact.firstName = "Joooooojoooo"
//			}, completion: {
//				expectFirstUpdate.fulfill()
//			})
		}


		self.dispatchQueue.async {
			self.model.update(at: indexPath, mutate:  { (contact) in
				contact.firstName = "Joooooojoooo"
				contact.lastName = "Talaaaaaaaieeeee"
			}, completion: {
				expectSecondUpdate.fulfill()
			})
		}

		wait(for: [expectFirstUpdate, expectSecondUpdate], timeout: 5)

		let entity = self.model[newIndexPath]!
		XCTAssertEqual(entity.firstName, "Joooooojoooo")
		XCTAssertEqual(entity.lastName, "Talaaaaaaaieeeee")

	}


	func testConcurrentMovedandChangedEntity() {
		let section = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))
		let row = Int(arc4random_uniform(UInt32(self.model.numberOfEntites(at: section))))

		let indexPath = IndexPath(row: row, section: section)

		let newSection = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))
		let newRow = Int(arc4random_uniform(UInt32(self.model.numberOfEntites(at: newSection))))

		let newIndexPath = IndexPath(row: newRow, section: newSection)


		let expectFirstUpdate = expectation(description: "update first name")
		let expectSecondUpdate = expectation(description: "update second name")
		let expectMove = expectation(description: "moved entity")



		self.dispatchQueue.async {

			self.model.moveEntity(at: indexPath, to: newIndexPath, isUserDriven: true, completion: {
				expectMove.fulfill()
			})

		}

		self.dispatchQueue.async {
			self.model.update(at: indexPath, mutate:  { (contact) in
				contact.firstName = "Joooooojoooo"
			}, completion: {
				expectFirstUpdate.fulfill()
			})
		}

		self.dispatchQueue.async {
			self.model.update(at: indexPath, mutate:  { (contact) in
				contact.lastName = "Talaaaaaaaieeeee"
			}, completion: {
				expectSecondUpdate.fulfill()
			})
		}

		wait(for: [expectFirstUpdate, expectSecondUpdate, expectMove], timeout: 100)

		let entity = self.model[newIndexPath]!
		XCTAssertEqual(entity.firstName, "Joooooojoooo")
		XCTAssertEqual(entity.lastName, "Talaaaaaaaieeeee")

	}



	func testGetIndexPath() {
		let indexPath1 = self.model.indexPath(for: self.members.first!)
		XCTAssertNotNil(indexPath1)

		let id = 3
		let indexPath2 = self.model.indexPathForEntity(withUniqueValue: id)
		XCTAssertNotNil(indexPath2)

		let entity = self.model[indexPath2!]!
		XCTAssertEqual(entity.uniqueValue, id)
	}

	func testMemberEqualable() {
		let dic1 = ["id":232,"first_name":"Emma","last_name":"McGinty","email":"emcginty0@wp.com","gender":"Female","country":"China"] as [String : Any]
		let dic2 = ["id":233,"first_name":"Emilia","last_name":"McGinty","email":"emcginty0@wp.com","gender":"Female","country":"China"] as [String : Any]

		let member1 = Member(data: dic1)

		let member2 = Member(data: dic2)

		XCTAssertNotEqual(member1, member2)
	}

	func testSortAndReorder() {
		self.model.sortEntities = { $0.lastName < $1.lastName }

		self.delegateExpect = expectation(description: "Reorder")
		let sortExpectation = expectation(description: "Reorder")
		self.model.reorderEntities {
			let entities = self.model.section(at: 0)!.entities
			let allSatisfy = entities.allSatisfy({ (entity) -> Bool in

				let indexPath = self.model.indexPath(for: entity)
				XCTAssertNotNil(indexPath)
				let nextIndexPath = IndexPath(row: indexPath!.row + 1, section: indexPath!.section)
				if let nextEntity = self.model[nextIndexPath] {
					XCTAssert(entity.lastName < nextEntity.lastName)
					return entity.lastName < nextEntity.lastName
				}

				return true
			})

			XCTAssert(allSatisfy)
			sortExpectation.fulfill()
		}

		wait(for: [sortExpectation], timeout: 30)
		wait(for: [delegateExpect], timeout: 30)

	}

	func testSortSections() {
		self.delegateExpect = expectation(description: "sort all Sections")
		let sortExpection = expectation(description: "sort all Sections")
		self.model.sortSections(by: { $0.name < $1.name }) {

			for index in 0..<self.model.numberOfSections {
				let section = self.model.section(at: index)!
				let nextIndex = index + 1
				if let nextSectoin = self.model.section(at: nextIndex) {
					XCTAssert(section.name < nextSectoin.name )
				}

			}
			sortExpection.fulfill()
		}

		wait(for: [sortExpection], timeout: 10)
		wait(for: [delegateExpect], timeout: 10)

	}

	func testInsertSameEntities() {
		let beforeNumberOfEntities = self.model.numberOfWholeEntities
		let beforeNumberOfFetchedEntities = self.model.numberOfFetchedEntities


		self.delegateExpect = expectation(description: "insertExpect")
		self.model.insert(members) {

			//			expect.fulfill()
		}

		waitForExpectations(timeout: 5, handler: nil)
		let afterNumberOfEntities = self.model.numberOfWholeEntities
		let afterNumberOfFetchedEntities = self.model.numberOfFetchedEntities
		XCTAssertEqual(afterNumberOfEntities, beforeNumberOfEntities)
		XCTAssertEqual(afterNumberOfFetchedEntities, beforeNumberOfFetchedEntities)
	}

	func testInsertDifferentEntities() {
		let beforeNumberOfEntities = self.model.numberOfWholeEntities
		let beforeNumberOfFetchedEntities = self.model.numberOfFetchedEntities

		let localMembers = self.entities(forFileWithName: "MOCK_DATA_20")

		self.delegateExpect = expectation(description: "insertExpect")
		self.model.insert(localMembers) {

		}

		waitForExpectations(timeout: 15, handler: nil)
		let afterNumberOfEntities = self.model.numberOfWholeEntities
		let afterNumberOfFetchedEntities = self.model.numberOfFetchedEntities

		let difSet = Set(localMembers).subtracting(self.members)
//		let difSet = localMembers

		let difSetCount = difSet.count
		if let filter = self.filter {
			let filtered = difSet.filter(filter)
			XCTAssertEqual(afterNumberOfEntities, beforeNumberOfEntities + filtered.count)
			XCTAssertEqual(afterNumberOfFetchedEntities, beforeNumberOfFetchedEntities + difSetCount)
		}
		else {
			XCTAssertEqual(afterNumberOfEntities, beforeNumberOfEntities + difSet.count)
			XCTAssertEqual(afterNumberOfFetchedEntities, beforeNumberOfFetchedEntities + difSetCount)
		}
	}

	func testInsertAtFirst() {
		let dic = ["id":232,"first_name":"Jhon","last_name":"AppleSeed","email":"jhon@apple.com","gender":"male","country":"USA"] as [String : Any]
		let member = Member(data: dic)!

		let indexPath = IndexPath(row: 0, section: 0)
		self.delegateExpect =  expectation(description: "insert at First Expect")
		self.model.insert(member, at: indexPath, completion: nil)
		waitForExpectations(timeout: 20, handler: nil)
		let memberIndexPath = self.model.indexPath(for: member)

		XCTAssertEqual(memberIndexPath, indexPath)
	}

	func testInsertAtLast1() {
		let dic = ["id":232,"first_name":"Jhon","last_name":"AppleSeed","email":"jhon@apple.com","gender":"male","country":"USA"] as [String : Any]
		let member = Member(data: dic)!

		let lastSection = self.model.numberOfSections - 1
		let lastRow = self.model.numberOfEntites(at: lastSection)

		let indexPath = IndexPath(row: lastRow, section: lastSection)

		self.delegateExpect =  expectation(description: "insert at First Expect")
		self.model.insert(member, at: indexPath, completion: nil)
		waitForExpectations(timeout: 5, handler: nil)

		let memberIndexPath = self.model.indexPath(for: member)

		XCTAssertEqual(memberIndexPath, indexPath)

	}

	func testInsertAtIndexPath() {
		let dic = ["id":232,"first_name":"Jhon","last_name":"AppleSeed","email":"jhon@apple.com","gender":"male","country":"USA"] as [String : Any]
		let member = Member(data: dic)!

		let section = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))
		let row = Int(arc4random_uniform(UInt32(self.model.numberOfEntites(at: section))))

		let indexPath = IndexPath(row: row, section: section)
		self.delegateExpect =  expectation(description: "insert at indexPath Expect")
		self.model.insert(member, at: indexPath, completion: nil)
		waitForExpectations(timeout: 5, handler: nil)

		let memberIndexPath = self.model.indexPath(for: member)

		XCTAssertEqual(memberIndexPath, indexPath)
	}

	func testInsertAtLast2() {
		let dic = ["id":232,"first_name":"Jhon","last_name":"AppleSeed","email":"jhon@apple.com","gender":"male","country":"USA"] as [String : Any]
		let member = Member(data: dic)!

		let section = self.model.numberOfSections - 1
		let row = self.model.numberOfEntites(at: section)

		let indexPath = IndexPath(row: row, section: section)
		self.delegateExpect =  expectation(description: "insert at Last Expect")
		self.model.insert(member, at: indexPath, completion: nil)
		waitForExpectations(timeout: 5, handler: nil)

		let memberIndexPath = self.model.indexPath(for: member)

		XCTAssertEqual(memberIndexPath, indexPath)
	}

	func testInsertAtWrongIndexPath() {
//		let dic = ["id":232,"first_name":"Jhon","last_name":"AppleSeed","email":"jhon@apple.com","gender":"male","country":"USA"] as [String : Any]
//		let member = Member(data: dic)!
//
//		let section = self.model.numberOfSections - 1
//		let row = self.model.numberOfEntites(at: section) + 1
//
//		let indexPath = IndexPath(row: row, section: section)
//		self.delegateExpect =  expectation(description: "insert at wrong indexPath Expect")
//		self.model.insert(member, at: indexPath, completion: nil)
//		waitForExpectations(timeout: 5, handler: nil)
//
//		let memberIndexPath = self.model.indexPath(of: member)
//
//		if self.sort == nil {
//			XCTAssertEqual(memberIndexPath, indexPath)
//		}
	}

	func testMoveEntityFromFirstToLast() {
		let oldIndexPath = IndexPath(row: 0, section: 0)

		let entity = self.model.entity(at: oldIndexPath)

		let newSection = self.model.numberOfSections-1
		let newRow = newSection == 0 ? self.model.numberOfEntites(at: newSection)-1 : self.model.numberOfEntites(at: newSection)
		let newIndexPath = IndexPath(row: newRow, section: newSection)

		let expect = expectation(description: "moving from first IndexPath to the last indexPath")
		self.model.moveEntity(at: oldIndexPath, to: newIndexPath, isUserDriven: true) {
			let currentIndexPath = self.model.indexPath(for: entity!)
			let expectedSection = self.model.numberOfSections-1
			let expectedRow = self.model.numberOfEntites(at: expectedSection) - 1
			let expectedIndexPath = IndexPath(row: expectedRow, section: expectedSection)

			XCTAssertEqual(currentIndexPath, expectedIndexPath)
			XCTAssertEqual(newIndexPath, expectedIndexPath)

			expect.fulfill()
		}
		waitForExpectations(timeout: 5, handler: nil)
	}

	func testMoveEntityIsUserDriven() {
		let oldSection = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))
		let oldRow = Int(arc4random_uniform(UInt32(self.model.numberOfEntites(at: oldSection))))

		let oldIndexPath = IndexPath(row: oldRow, section: oldSection)

		let entity = self.model.entity(at: oldIndexPath)

		var newSection = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))
		if newSection == oldSection, self.model.numberOfEntites(at: newSection) == 1 {
			if self.model.numberOfSections > 1 {
				newSection += 1
			}
		}

		let newRow = Int(arc4random_uniform(UInt32(self.model.numberOfEntites(at: newSection))))

		let newIndexPath = IndexPath(row: newRow, section: newSection)

		let expect = expectation(description: "moving from first IndexPath to the User derived indexPath")
		self.model.moveEntity(at: oldIndexPath, to: newIndexPath, isUserDriven: true) {
			let currentIndexPath = self.model.indexPath(for: entity!)
			let expectedIndexPath = newIndexPath
			XCTAssertEqual(currentIndexPath, expectedIndexPath)

			expect.fulfill()
		}
		waitForExpectations(timeout: 5, handler: nil)

	}

	func testMoveEntityNotUserDriven() {
		let oldSection = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))
		let oldRow = Int(arc4random_uniform(UInt32(self.model.numberOfEntites(at: oldSection))))

		let oldIndexPath = IndexPath(row: oldRow, section: oldSection)

		let entity = self.model.entity(at: oldIndexPath)

		var newSection = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))
		if newSection == oldSection, self.model.numberOfEntites(at: newSection) == 1 {
			if self.model.numberOfSections > 1 {
				newSection += 1
			}
		}

		let newRow = Int(arc4random_uniform(UInt32(self.model.numberOfEntites(at: newSection))))

		let newIndexPath = IndexPath(row: newRow, section: newSection)

		self.delegateExpect =  expectation(description: "moving from first IndexPath to the user not derived indexPath")
		self.model.moveEntity(at: oldIndexPath, to: newIndexPath, isUserDriven: false, completion: nil)
		waitForExpectations(timeout: 5, handler: nil)
		let currentIndexPath = self.model.indexPath(for: entity!)
		let expectedIndexPath = newIndexPath
		XCTAssertEqual(currentIndexPath, expectedIndexPath)

	}

	func testUpdateIndexPath() {
		let section = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))
		let row = Int(arc4random_uniform(UInt32(self.model.numberOfEntites(at: section))))

		let indexPath = IndexPath(row: row, section: section)

		let oldEntity = self.model[indexPath]

		self.updateDelegateExpect = expectation(description: "update IndexPath ")

		self.model!.update(at: indexPath, mutate: { (entity) in
			entity.firstName = "Gholam"
			entity.lastName = "Shishlool"
		}, completion: nil)

		waitForExpectations(timeout: 5, handler: nil)

		let newEntity = self.model[indexPath]

		XCTAssertNotEqual(newEntity?.fullName, oldEntity?.fullName)
	}

	func testRemoveAtIndexPath() {
		let section = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))
		let row = Int(arc4random_uniform(UInt32(self.model.numberOfEntites(at: section))))

		let indexPath = IndexPath(row: row, section: section)

		self.delegateExpect = expectation(description: "remove IndexPath")

		var removedEntity: Member!
		self.model.remove(at: indexPath) { entity in
			removedEntity = entity
		}
		waitForExpectations(timeout: 5, handler: nil)

		if section < self.model.numberOfSections, row < self.model.numberOfEntites(at: section) {
			let entity = self.model.entity(at: indexPath)
			XCTAssertNotEqual(entity, removedEntity)
		}
	}

	func testRemoveAtIndexPathWithEmptySection() {
		let section = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))

		let oldSection = self.model[section]

		var numberOfEntities = self.model.numberOfEntites(at: section)
		let indexPath = IndexPath(row: 0, section: section)

		while numberOfEntities > 0 {
			self.delegateExpect = expectation(description: "remove IndexPath")
			self.model!.remove(at: indexPath) { entity in
			}
			waitForExpectations(timeout: 5, handler: nil)

			numberOfEntities -= 1
		}

		if self.model.numberOfSections > section {
			let currentSection = self.model[section]
			XCTAssertNotEqual(currentSection, oldSection)
		}

	}

	func testRemoveEntity() {
		let section = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))
		let row = Int(arc4random_uniform(UInt32(self.model.numberOfEntites(at: section))))

		let indexPath = IndexPath(row: row, section: section)

		let entity = self.model[indexPath]

		self.delegateExpect = expectation(description: "remove IndexPath")

		self.model.remove(entity!, completion: nil)

		waitForExpectations(timeout: 5, handler: nil)

		XCTAssertNil(self.model.indexPath(for: entity!))
	}

	func testRemoveSection() {
		let sectionIndex = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))

		let removedSection = self.model[sectionIndex]

		self.delegateExpect = expectation(description: "remove all entities at Section")

		self.model.removeSection(at: sectionIndex, completion: nil)

		waitForExpectations(timeout: 5, handler: nil)

		if sectionIndex < self.model.numberOfSections {
			let currentSection = self.model[sectionIndex]
			XCTAssertNotEqual(currentSection, removedSection)
		}
	}

	func testRemoveAll() {
		let expect = expectation(description: "wait for ending remove all")
		self.model.removeAll {
			XCTAssert(self.model.isEmpty)
			expect.fulfill()
		}

		waitForExpectations(timeout: 5, handler: nil)
	}


	func testFilterAtSection() {
		let sectionIndex = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))

		let entities = self.model.filteredEntities(atSection: sectionIndex, with: { $0.fullName.contains("g")})


		for entity in entities {
			XCTAssert(entity.fullName.contains("g"))
		}
	}

	func testAllEntitiesForExport() {
		var members = self.members!

		if filter != nil {
			members = self.members.filter(filter!)
		}

		let entities = self.model.getAllEntities(sortedBy: {$0.lastName < $1.lastName})
		XCTAssertEqual(entities.count, members.count)
	}

	func testIndexOfSection() {
		let sectionIndex = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))

		let section = self.model[sectionIndex]

		XCTAssertEqual(self.model.index(of: section!), sectionIndex)
	}



	//MARK: - Performance Checking

	func testPerformanceindexPathOfEntity() {
		// This is an example of a performance test case.
		self.measure {
			// Put the code you want to measure the time of here.
			let entity = Member(data: ["id":1,"first_name":"Emma","last_name":"McGinty"])!
			//			let indexPath = self.model.indexPath(of: entity)
			_ = self.model.indexPathForEntity(withUniqueValue: entity.uniqueValue)

		}
	}


}

