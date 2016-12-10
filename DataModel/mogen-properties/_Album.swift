// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Album.swift instead.

import CoreData

// MARK: - Class methods
extension Album: ManagedObjectType {

    public class var entityName: String {
        return "Album"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Album> {
        return NSFetchRequest<Album>(entityName: entityName)
    }

}

public extension Album {

	public struct Relationships {
		static let artist = "artist"
		static let tracks = "tracks"
	}

    // MARK: - Properties

    // MARK: - Relationships

    @NSManaged public var artist: Artist?

    @NSManaged public var tracks: Set<Track>?

}
