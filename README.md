# swift-quaternion

Use this package when you need quaternions: the Hamilton product, the conjugate, the norm and the inverse, and above all unit quaternions as rotations of space that compose without drift into shear and that interpolate at an even angular rate. Start from `Quaternion<Scalar>`. To turn a rotation into its 3 × 3 matrix and back, enable the `Quaternion` trait of swift-matrix: `Matrix<3, 3, Scalar>(quaternion)` and `Quaternion(matrix)`. For a rotation recorded as steps in coordinate planes, use swift-rotation.

A unit quaternion `cos(θ/2) + sin(θ/2)(n.x i + n.y j + n.z k)` is the rotation by θ about the unit axis n. `q` and `-q` are the same rotation.

## Laws

- `multiplied(by:)` is the Hamilton product: `i · i = j · j = k · k = i · j · k = -1`. It is associative, not commutative, and `identity` is neutral on both sides. As rotations, `a.multiplied(by: b)` turns by `b` first and then by `a`, as the product of their matrices does.
- `conjugate` negates the imaginary parts; for a unit quaternion it is the inverse rotation. `inverse` is the conjugate over the squared norm, so `q · q.inverse` and `q.inverse · q` are 1 up to rounding. `normalized` divides by `norm`; zero has no direction and gives NaN parts.
- Equality and hashing compare the four parts exactly: `q` and `-q` are different quaternions though the same rotation.
- `angle` is the angle a unit quaternion turns by, from 0 to π, the same for `q` and `-q`.
- `a.interpolated(to: b, at: share)` is spherical linear interpolation along the shorter arc: `a` followed by `share` of the relative rotation `a.conjugate · b`, taken with a non-negative real part. For unit quaternions:
  - a share of 0 gives `a` and a share of 1 gives `b`, up to rounding and sign;
  - every result is a unit quaternion up to rounding, so every rotation on the way is rigid;
  - the angle between the results at two shares is the difference of the shares times the angle from `a` to `b`, which is at most π: the angular rate is even;
  - `b` and `-b` give the same results, and `a` to `a` or to `-a` gives `a` at every share;
  - rotations exactly a half turn apart have two equally short arcs; the one about the relative rotation's axis as computed is taken.
- Nothing renormalises: results that are composed again and again drift from unit length by rounding. Call `normalized` where that matters.
