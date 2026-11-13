extension Quaternion where Scalar: SignedNumeric {

    /// The quaternion 1, which as a rotation turns nothing.
    @inlinable
    public static var identity: Self {
        Self(w: 1, x: 0, y: 0, z: 0)
    }

    /// The Hamilton product `self · other`.
    ///
    /// As rotations, the product turns by `other` first and then by `self`, as the product of
    /// their matrices does. It is associative and not commutative: `i · j = k` and `j · i = -k`.
    @inlinable
    public func multiplied(by other: Self) -> Self {
        Self(
            w: w * other.w - x * other.x - y * other.y - z * other.z,
            x: w * other.x + x * other.w + y * other.z - z * other.y,
            y: w * other.y - x * other.z + y * other.w + z * other.x,
            z: w * other.z + x * other.y - y * other.x + z * other.w
        )
    }

    /// The conjugate `w - xi - yj - zk`: for a unit quaternion, the inverse rotation.
    @inlinable
    public var conjugate: Self {
        Self(w: w, x: -x, y: -y, z: -z)
    }

    /// The quaternion with every part negated: as a rotation, the same rotation.
    @inlinable
    public static prefix func - (quaternion: Self) -> Self {
        Self(w: -quaternion.w, x: -quaternion.x, y: -quaternion.y, z: -quaternion.z)
    }

    /// The sum of the products of the parts: for unit quaternions, the cosine of half the
    /// angle between the rotations, up to sign.
    @inlinable
    public func dot(_ other: Self) -> Scalar {
        w * other.w + x * other.x + y * other.y + z * other.z
    }
}
