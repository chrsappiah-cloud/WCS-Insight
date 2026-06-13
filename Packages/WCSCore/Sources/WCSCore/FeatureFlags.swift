import Foundation

public struct WCSFeatureFlags: Codable, Hashable, Sendable {
    public var memoryAtlasEnabled: Bool
    public var scholarSphereEnabled: Bool
    public var presencePlayEnabled: Bool
    public var visionOSSpatialPreviewEnabled: Bool
    public var cloudKitMirrorEnabled: Bool

    public init(
        memoryAtlasEnabled: Bool = true,
        scholarSphereEnabled: Bool = true,
        presencePlayEnabled: Bool = true,
        visionOSSpatialPreviewEnabled: Bool = false,
        cloudKitMirrorEnabled: Bool = true
    ) {
        self.memoryAtlasEnabled = memoryAtlasEnabled
        self.scholarSphereEnabled = scholarSphereEnabled
        self.presencePlayEnabled = presencePlayEnabled
        self.visionOSSpatialPreviewEnabled = visionOSSpatialPreviewEnabled
        self.cloudKitMirrorEnabled = cloudKitMirrorEnabled
    }
}
