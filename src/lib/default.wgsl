@fragment
fn main(fragment: Fragment) -> @location(0) vec4f {
  return vec4f(fragment.uv, 0.0, 1.0);
}
