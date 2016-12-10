// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Track.swift instead.

import CoreData

// MARK: - Class methods
extension Track: ManagedObjectType {

    public class var entityName: String {
        return "Track"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Track> {
        return NSFetchRequest<Track>(entityName: entityName)
    }

}

public extension Track {

	public struct Relationships {
		static let album = "album"
		static let artist = "artist"
	}

    // MARK: - Properties

    // MARK: - Relationships

    @NSManaged public var album: Album?

    @NSManaged public var artist: Artist?

}
