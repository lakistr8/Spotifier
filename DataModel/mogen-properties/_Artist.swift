// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Artist.swift instead.

import CoreData

// MARK: - Class methods
extension Artist: ManagedObjectType {

    public class var entityName: String {
        return "Artist"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Artist> {
        return NSFetchRequest<Artist>(entityName: entityName)
    }

}

public extension Artist {

	public struct Attributes {
		static let artistId = "artistId"
		static let followersCount = "followersCount"
		static let genre = "genre"
		static let imageURL = "imageURL"
		static let name = "name"
		static let popularity = "popularity"
		static let spotifyURL = "spotifyURL"
	}

	public struct Relationships {
		static let albums = "albums"
		static let tracks = "tracks"
	}

    // MARK: - Properties

    @NSManaged public var artistId: String?

    @NSManaged public var followersCount: Int64 // Optional scalars not supported

    @NSManaged public var genre: String?

    @NSManaged public var imageURL: String?

    @NSManaged public var name: String?

    @NSManaged public var popularity: Int64 // Optional scalars not supported

    @NSManaged public var spotifyURL: String?

    // MARK: - Relationships

    @NSManaged public var albums: Set<Album>?

    @NSManaged public var tracks: Set<Track>?

}
