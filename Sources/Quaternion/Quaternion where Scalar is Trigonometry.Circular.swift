extension Quaternion where Scalar: Trigonometry.Circular {

    /// The angle this unit quaternion turns by, in radians from 0 to π: the shorter way round,
    /// so `q` and `-q` have the same angle.
    @inlinable
    public var angle: Scalar {
        let sine = (x * x + y * y + z * z).squareRoot()
        return 2 * Scalar.atan2(sine, abs(w))
    }

    /// The rotation a share of the way from this rotation to another, along the shorter arc at
    /// an even angular rate: spherical linear interpolation of unit quaternions.
    ///
    /// It is this rotation followed by `share` of the angle of the relative rotation
    /// `self.conjugate · other`, about that rotation's own axis, taken as the representative
    /// with a non-negative real part, so the arc is never longer than a half turn. A share of 0
    /// gives this rotation, a share of 1 the other, up to rounding and sign. The same rotation
    /// with either sign gives this rotation at every share. Two rotations a half turn apart have
    /// two equally short arcs, and the one about the relative rotation's axis as given is taken.
    /// Shares outside 0 to 1 continue along the same great circle.
    @inlinable
    public func interpolated(to other: Self, at share: Scalar) -> Self {
        var relative = conjugate.multiplied(by: other)
        if relative.w < 0 { relative = -relative }
        let sine = (relative.x * relative.x + relative.y * relative.y + relative.z * relative.z).squareRoot()
        guard sine > 0, sine.isFinite else { return self }
        let half = Scalar.atan2(sine, relative.w) * share
        let scale = Scalar.sin(half) / sine
        return multiplied(
            by: Self(w: Scalar.cos(half), x: relative.x * scale, y: relative.y * scale, z: relative.z * scale)
        )
    }
}
