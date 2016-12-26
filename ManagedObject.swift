//
//  ManagedObject.swift
//  Radiant Tap Essentials
//
//  Copyright © 2016 Aleksandar Vacić, Radiant Tap
//  MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation
import CoreData


public class ManagedObject: NSManagedObject {
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    required public init?(managedObjectContext moc: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: "ManagedObject", in: moc) else { return nil }
        super.init(entity: entity, insertInto: moc)
    }
}

public protocol ManagedObjectType: NSFetchRequestResult {
    static var entityName: String { get }
    static func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription?
}

public extension ManagedObjectType {
    
    /// Fetches a set of values for the given property.
    ///
    /// - Parameters:
    ///   - property: `String` representing the property name
    ///   - context: `NSManagedObjectContext` in which to perform the fetch
    ///   - predicate: (optional) `NSPredicate` condition to apply to the fetch
    /// - Returns: a `Set` of values with appropriate type
    public static func fetch<T:Hashable>(property: String, context: NSManagedObjectContext, predicate: NSPredicate? = nil) -> Set<T> {
        guard let entity = Self.entity(managedObjectContext: context) else { return [] }
        
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: Self.entityName)
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.returnsDistinctResults = true
        fetchRequest.propertiesToFetch = [entity.attributesByName[property] as Any]
        
        guard let results = try? context.fetch(fetchRequest) else { return [] }
        
        let arr = results.map( { $0[property] as! T } )
        return Set<T>(arr)
    }
    
    public static func fetch(withContext context: NSManagedObjectContext, predicate: NSPredicate? = nil) -> [Self] {
        return fetch(withContext: context, predicate: predicate, sortedWith: nil)
    }
    
    /// Fetches objects of given type, **including** any pending changes in the context
    ///
    /// - Parameters:
    ///   - context: `NSManagedObjectContext` in which to perform the fetch
    ///   - predicate: (optional) `NSPredicate` condition to apply to the fetch
    ///   - sortDescriptors: (optional) array of `NSSortDescriptio`s to apply to the fetched results
    /// - Returns: an Array of Entity objects of appropriate type
    public static func fetch(withContext context: NSManagedObjectContext, predicate: NSPredicate? = nil, sortedWith sortDescriptors: [NSSortDescriptor]? = nil) -> [Self] {
        
        let fr = fetchRequest(withContext: context, predicate: predicate, sortedWith: sortDescriptors)
        guard let results = try? context.fetch(fr) else { return [] }
        return results
    }
    
    /// Creates `NSFetchRequest` for the type of the current object
    ///
    /// - Parameters:
    ///   - context: `NSManagedObjectContext` in which to perform the fetch
    ///   - predicate: (optional) `NSPredicate` condition to apply to the fetch
    ///   - sortDescriptors: (optional) array of `NSSortDescriptio`s to apply
    /// - Returns: Instance of `NSFetchRequest` with appropriate type
    public static func fetchRequest(withContext context: NSManagedObjectContext,
                                    predicate: NSPredicate? = nil,
                                    sortedWith sortDescriptors: [NSSortDescriptor]? = nil
        ) -> NSFetchRequest<Self> {
        
        let fetchRequest = NSFetchRequest<Self>(entityName: entityName)
        fetchRequest.includesPendingChanges = true
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        return fetchRequest
    }
    
    /// Creates Fetched Results Controller for the current object’s type.
    ///	If you supply the `sectionNameKeyPath`, make sure that same keypath is set as first in the `sortDescriptors`
    ///
    /// - Parameters:
    ///   - context: `NSManagedObjectContext` in which to perform the fetch
    ///   - sectionNameKeyPath:	`String` representing the keypath to create the sections
    ///   - predicate: (optional) `NSPredicate` condition to apply to the fetch
    ///   - sortDescriptors: (optional) array of `NSSortDescriptio`s to apply
    /// - Returns: Instance of `NSFetchedResultsController` with appropriate type
    public static func fetchedResultsController(withContext context: NSManagedObjectContext,
                                                sectionNameKeyPath: String? = nil,
                                                predicate: NSPredicate? = nil,
                                                sortedWith sortDescriptors: [NSSortDescriptor]? = nil
        ) -> NSFetchedResultsController<Self> {
        
        let fr = fetchRequest(withContext: context, predicate: predicate, sortedWith: sortDescriptors)
        let frc: NSFetchedResultsController<Self> = NSFetchedResultsController(fetchRequest: fr,
                                                                               managedObjectContext: context,
                                                                               sectionNameKeyPath: sectionNameKeyPath,
                                                                               cacheName: nil)
        return frc
    }
}


protocol JSONProcessing: ManagedObjectType {
    init?(json: JSON, in context: NSManagedObjectContext)
    func update(with json: JSON) throws
}

extension JSONProcessing where Self: NSObject {
    
    static func processJSON(items: [JSON], in moc: NSManagedObjectContext, idProperty objectIDProperty: String) -> [Self] {
        var arr = [Self]()
        
        //	extract IDs from JSON
        let jsonIDs = items.flatMap({ item in return item["id"] as? String })
        let setIDs = Set(jsonIDs)
        
        //	pick-up (possibly) existing objects in Core Data, with those IDs
        let predicate = NSPredicate(format: "%K IN %@",
                                    objectIDProperty,
                                    jsonIDs)
        //	fetch IDs only for existing objects that are sent in this JSON payload
        let existingIDs: Set<String> = fetch(property: objectIDProperty,
                                             context: moc,
                                             predicate: predicate)
        
        //	IDs for new objects to create:
        let inserted = setIDs.subtracting(existingIDs)
        //	IDs for existing objects to update them:
        let updated = setIDs.intersection(existingIDs)
        //	IDs for objects to (maybe) delete:
        let deleted = existingIDs.subtracting(setIDs)
        
        //	insert all new objects
        for id in inserted {
            //	find JSON for current ID
            let filteredItems = items.filter({ item in
                guard let jsonID = item["id"] as? String else { return false }
                return jsonID == id
            })
            //	there should be only one JSON item
            guard let item = filteredItems.first else { continue }
            //	create managed object using that JSON item
            if let mobject = Self.init(json: item, in: moc) {
                arr.append(mobject)
            }
        }
        
        if updated.count > 0 {
            //	fetch all existing objects, using just one call
            //	this predicate means: `FETCH Object WHERE objectId IN updated`
            let predicate = NSPredicate(format: "%K IN %@",
                                        objectIDProperty,
                                        updated)
            let mobjects = fetch(withContext: moc, predicate: predicate)
            
            for id in updated {
                //	find JSON for current `id`
                let filteredItems = items.filter({ item in
                    guard let jsonID = item["id"] as? String else { return false }
                    return jsonID == id
                })
                //	there should be only one JSON item for each `id` in `updated`
                guard let item = filteredItems.first else { continue }
                //	similarly, there should be only one object in Core Data for any given `id`
                guard let mobject = mobjects.filter({ mo in
                    guard let moId = mo.value(forKey: objectIDProperty) as? String else { fatalError("Failed to convert object's id property to String") }
                    return moId == id
                }).first else { continue }
                
                do {
                    try mobject.update(with: item)
                    arr.append(mobject)
                } catch (let coredataError) {
                    print(coredataError)
                }
            }
        }
        
        if deleted.count > 0 {
            //	TBD.
        }
        
        return arr
    }
}
