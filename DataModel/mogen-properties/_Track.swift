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

	public struct Attributes {
		static let csvAvailableMarkets = "csvAvailableMarkets"
		static let discNumber = "discNumber"
		static let durationMilliseconds = "durationMilliseconds"
		static let imageLink = "imageLink"
		static let isExplicit = "isExplicit"
		static let name = "name"
		static let popularity = "popularity"
		static let previewLink = "previewLink"
		static let spotifyURI = "spotifyURI"
		static let trackId = "trackId"
	}

	public struct Relationships {
		static let album = "album"
		static let artist = "artist"
	}

    // MARK: - Properties

    @NSManaged public var csvAvailableMarkets: String?

    @NSManaged public var discNumber: Int16 // Optional scalars not supported

    @NSManaged public var durationMilliseconds: Int64 // Optional scalars not supported

    @NSManaged public var imageLink: String?

    @NSManaged public var isExplicit: Bool

    @NSManaged public var name: String!

    @NSManaged public var popularity: Int16 // Optional scalars not supported

    @NSManaged public var previewLink: String?

    @NSManaged public var spotifyURI: String?

    @NSManaged public var trackId: String!

    // MARK: - Relationships

    @NSManaged public var album: Album?

    @NSManaged public var artist: Artist?

}
