extension Quaternion where Scalar: FloatingPoint {

    /// The Euclidean length of the four parts.
    @inlinable
    public var norm: Scalar {
        dot(self).squareRoot()
    }

    /// The quaternion divided by its norm: a unit quaternion, the same rotation. Zero stays
    /// undefined: its parts become NaN.
    @inlinable
    public var normalized: Self {
        let length = norm
        return Self(w: w / length, x: x / length, y: y / length, z: z / length)
    }

    /// The multiplicative inverse: the conjugate divided by the squared norm, so that
    /// `q · q.inverse` and `q.inverse · q` are 1 up to rounding. For a unit quaternion it is the
    /// inverse rotation.
    @inlinable
    public var inverse: Self {
        let square = dot(self)
        return Self(w: w / square, x: -x / square, y: -y / square, z: -z / square)
    }
}
