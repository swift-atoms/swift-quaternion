import Numeric
import Quaternion
import Testing

enum `Quaternion Tests` {}

extension `Quaternion Tests` {
    /// The rotation by `angle` about the axis (x, y, z), normalised.
    static func turn(_ angle: Double, _ x: Double, _ y: Double, _ z: Double) -> Quaternion<Double> {
        let length = (x * x + y * y + z * z).squareRoot()
        let sine = Double.sin(angle / 2) / length
        return Quaternion(w: Double.cos(angle / 2), x: x * sine, y: y * sine, z: z * sine)
    }

    /// Whether two quaternions agree part by part to within `tolerance`.
    static func near(_ a: Quaternion<Double>, _ b: Quaternion<Double>, _ tolerance: Double = 1e-12) -> Bool {
        abs(a.w - b.w) <= tolerance && abs(a.x - b.x) <= tolerance && abs(a.y - b.y) <= tolerance
            && abs(a.z - b.z) <= tolerance
    }

    /// Whether two unit quaternions are the same rotation to within `tolerance`.
    static func same(_ a: Quaternion<Double>, _ b: Quaternion<Double>, _ tolerance: Double = 1e-12) -> Bool {
        near(a, b, tolerance) || near(a, -b, tolerance)
    }

    static let samples: [Quaternion<Double>] = [
        .identity,
        turn(0.3, 1, 0, 0),
        turn(2.1, 0, 1, 0),
        turn(-1.2, 0, 0, 1),
        turn(1.7, 1, 2, 3),
        turn(3.0, -2, 0.5, 1),
        turn(Double.pi, 0, 1, 1),
    ]
}

extension `Quaternion Tests` {
    @Suite
    struct `Hamilton product` {
        @Test
        func `The units multiply as Hamilton wrote them`() {
            let i = Quaternion<Double>(w: 0, x: 1, y: 0, z: 0)
            let j = Quaternion<Double>(w: 0, x: 0, y: 1, z: 0)
            let k = Quaternion<Double>(w: 0, x: 0, y: 0, z: 1)
            let minus = -Quaternion<Double>.identity
            #expect(i.multiplied(by: i) == minus)
            #expect(j.multiplied(by: j) == minus)
            #expect(k.multiplied(by: k) == minus)
            #expect(i.multiplied(by: j) == k)
            #expect(j.multiplied(by: i) == -k)
            #expect(i.multiplied(by: j).multiplied(by: k) == minus)
        }

        @Test
        func `The identity is neutral and the product is associative`() {
            let a = Quaternion<Double>(w: 1, x: 2, y: 3, z: 4)
            let b = Quaternion<Double>(w: -2, x: 0, y: 5, z: 1)
            let c = Quaternion<Double>(w: 3, x: -1, y: 2, z: -2)
            #expect(a.multiplied(by: .identity) == a)
            #expect(Quaternion.identity.multiplied(by: a) == a)
            #expect(a.multiplied(by: b).multiplied(by: c) == a.multiplied(by: b.multiplied(by: c)))
        }

        @Test
        func `The inverse undoes the product on both sides`() {
            let a = Quaternion<Double>(w: 1, x: 2, y: 3, z: 4)
            #expect(`Quaternion Tests`.near(a.multiplied(by: a.inverse), .identity))
            #expect(`Quaternion Tests`.near(a.inverse.multiplied(by: a), .identity))
            #expect(a.norm == 30.0.squareRoot())
            #expect(abs(a.normalized.norm - 1) <= 1e-15)
            `Quaternion Tests`.samples.forEach { rotation in
                #expect(`Quaternion Tests`.near(rotation.inverse, rotation.conjugate))
            }
        }
    }
}

extension `Quaternion Tests` {
    @Suite
    struct `Spherical interpolation` {
        private let shares: [Double] = [0, 0.1, 0.25, 0.5, 0.75, 0.9, 1]

        @Test
        func `The ends are the two rotations`() {
            `Quaternion Tests`.samples.forEach { start in
                `Quaternion Tests`.samples.forEach { end in
                    #expect(`Quaternion Tests`.same(start.interpolated(to: end, at: 0), start))
                    #expect(`Quaternion Tests`.same(start.interpolated(to: end, at: 1), end))
                }
            }
        }

        @Test
        func `Every rotation on the way is rigid`() {
            `Quaternion Tests`.samples.forEach { start in
                `Quaternion Tests`.samples.forEach { end in
                    shares.forEach { share in
                        #expect(abs(start.interpolated(to: end, at: share).norm - 1) <= 1e-12)
                    }
                }
            }
        }

        @Test
        func `The angular speed is even and the arc the shorter one`() {
            `Quaternion Tests`.samples.forEach { start in
                `Quaternion Tests`.samples.forEach { end in
                    let total = start.conjugate.multiplied(by: end).angle
                    #expect(total <= Double.pi + 1e-12)
                    zip(shares, shares.dropFirst()).forEach { earlier, later in
                        let a = start.interpolated(to: end, at: earlier)
                        let b = start.interpolated(to: end, at: later)
                        let step = a.conjugate.multiplied(by: b).angle
                        #expect(abs(step - total * (later - earlier)) <= 1e-9)
                    }
                }
            }
        }

        @Test
        func `The way to the other sign of a rotation is the shorter one`() {
            let start = `Quaternion Tests`.turn(0.4, 0, 0, 1)
            let end = -`Quaternion Tests`.turn(1.0, 0, 0, 1)
            let half = start.interpolated(to: end, at: 0.5)
            #expect(`Quaternion Tests`.same(half, `Quaternion Tests`.turn(0.7, 0, 0, 1)))
        }

        @Test
        func `A rotation and its antipode stay put`() {
            `Quaternion Tests`.samples.forEach { rotation in
                shares.forEach { share in
                    #expect(rotation.interpolated(to: -rotation, at: share) == rotation)
                    #expect(rotation.interpolated(to: rotation, at: share) == rotation)
                }
            }
        }

        @Test
        func `Rotations a half turn apart are joined at an even rate`() {
            let start = `Quaternion Tests`.turn(0.5, 1, 0, 0)
            let end = start.multiplied(by: `Quaternion Tests`.turn(Double.pi, 0, 1, 0))
            shares.forEach { share in
                let between = start.interpolated(to: end, at: share)
                #expect(abs(start.conjugate.multiplied(by: between).angle - Double.pi * share) <= 1e-9)
            }
            #expect(`Quaternion Tests`.same(start.interpolated(to: end, at: 1), end))
        }

        @Test
        func `The angle reads the rotation's angle the shorter way round`() {
            #expect(abs(`Quaternion Tests`.turn(1.25, 1, 2, 3).angle - 1.25) <= 1e-12)
            #expect(abs((-`Quaternion Tests`.turn(1.25, 1, 2, 3)).angle - 1.25) <= 1e-12)
            #expect(abs(`Quaternion Tests`.turn(2 * Double.pi - 1.25, 1, 2, 3).angle - 1.25) <= 1e-12)
            #expect(Quaternion<Double>.identity.angle == 0)
        }
    }
}
