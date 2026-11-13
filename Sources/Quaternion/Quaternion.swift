/// A quaternion `w + xi + yj + zk`: a real part and three imaginary parts.
///
/// A unit quaternion is a rotation of space: the rotation by angle θ about the unit axis n is
/// `cos(θ/2) + sin(θ/2)(n.x i + n.y j + n.z k)`, and `q` and `-q` are the same rotation.
public struct Quaternion<Scalar> {
    /// The real part.
    public var w: Scalar

    /// The coefficient of i.
    public var x: Scalar

    /// The coefficient of j.
    public var y: Scalar

    /// The coefficient of k.
    public var z: Scalar

    /// The quaternion `w + xi + yj + zk`.
    @inlinable
    public init(w: Scalar, x: Scalar, y: Scalar, z: Scalar) {
        self.w = w
        self.x = x
        self.y = y
        self.z = z
    }
}

extension Quaternion: Sendable where Scalar: Sendable {}

extension Quaternion: Equatable where Scalar: Equatable {}

extension Quaternion: Hashable where Scalar: Hashable {}
