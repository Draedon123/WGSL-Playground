/*
Available uniforms under the `params` object:
struct Parameters {
  resolution: vec2u,
  time: f32,
  deltaTime: f32,
  frame: u32,
  frameRate: f32,
}

And for Fragment:
struct Fragment {
  @builtin(position) position: vec4f,
  @location(0) uv: vec2f,
}
*/

@fragment
fn main(fragment: Fragment) -> @location(0) vec4f {
  // equivalent to fragment.uv with a flipped v component
  var uv: vec2f = fragment.position.xy / vec2f(params.resolution);

  uv.y = 1.0 - uv.y;

  return vec4f(uv, (1.0 - cos(params.time)) / 2, 1.0);
}
