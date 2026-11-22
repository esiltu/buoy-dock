import Foundation

/// Tells whether the active Space is a full-screen app. Uses SkyLight (read-only, loaded at runtime);
/// if it's ever unavailable, Buoy simply treats every Space as a desktop.
enum Spaces {
    private typealias MainConnection = @convention(c) () -> Int32
    private typealias ActiveSpace = @convention(c) (Int32) -> UInt64
    private typealias SpaceType = @convention(c) (Int32, UInt64) -> Int32

    private static let fullScreenType: Int32 = 4

    private static let functions: (MainConnection, ActiveSpace, SpaceType)? = {
        guard let handle = dlopen("/System/Library/PrivateFrameworks/SkyLight.framework/SkyLight", RTLD_LAZY),
              let main = dlsym(handle, "SLSMainConnectionID") ?? dlsym(handle, "CGSMainConnectionID"),
              let active = dlsym(handle, "SLSGetActiveSpace") ?? dlsym(handle, "CGSGetActiveSpace"),
              let type = dlsym(handle, "SLSSpaceGetType") ?? dlsym(handle, "CGSSpaceGetType")
        else { return nil }
        return (
            unsafeBitCast(main, to: MainConnection.self),
            unsafeBitCast(active, to: ActiveSpace.self),
            unsafeBitCast(type, to: SpaceType.self)
        )
    }()

    static var isFullScreenActive: Bool {
        guard let (main, active, type) = functions else { return false }
        let connection = main()
        return type(connection, active(connection)) == fullScreenType
    }
}
