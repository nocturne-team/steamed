package xyz.kkaii.steamed.net

// ViaFabric lets its client connect to a server of a different protocol instead of auto-pinging one, by reading a
// "._v<protocol>.viafabric" suffix it strips off the server address's host string (verified against its real
// decompiled source, ViaFabric 0.4.22+186-26.x: AddressParser/MixinServerAddress/MixinServerNameResolver). Steamed
// already knows the host's protocol from lobby data, so joining can hand it over directly instead of letting
// ViaFabric's own auto-detect ping use up the single-accept loopback bridge.
object ViaFabricIntegration {
    private const val CLASS_NAME = "com.viaversion.fabric.common.AddressParser"

    fun isInstalled(): Boolean = try {
        Class.forName(CLASS_NAME, false, ViaFabricIntegration::class.java.classLoader)
        true
    } catch (_: ClassNotFoundException) {
        false
    } catch (_: LinkageError) {
        true
    }

    // "<host>._v<protocol>.viafabric" is ViaFabric's suffix syntax: an underscore-prefixed "v" option carrying the raw
    // protocol number, terminated by its own hostname. It's stripped before the address is actually resolved, so this
    // works on a literal loopback IP, not just a real hostname.
    fun suffixedAddress(host: String, protocol: Int): String = "$host._v$protocol.viafabric"
}
