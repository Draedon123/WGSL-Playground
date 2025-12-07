// https://www.shadertoy.com/view/XsXXDn
// Licensed under https://creativecommons.org/licenses/by-nc-sa/3.0/
// This is a WGSL port

fn moduloVec2f(x: vec2f, y: vec2f) -> vec2f {
  return x - y * floor(x / y);
}

@fragment
fn main(fragment: Fragment) -> @location(0) vec4f {
  var c: vec3f = vec3f(0.0);
  var l: f32 = 0.0;
  var z: f32 = params.time;

  for(var i: u32 = 0; i < 3; i++){
    var uv: vec2f = fragment.uv;
    var p: vec2f = uv;

    p -= 0.5;
    p.x *= f32(params.resolution.x) / f32(params.resolution.y);
    z += 0.07;
    l = length(p);
    uv += p / l * (sin(z) + 1.0) * abs(sin(l * 9.0 - z - z));

    c[i] = 0.01 / length(moduloVec2f(uv, vec2f(1.0)) - 0.5);
  }

  return vec4f(c / l, params.time);
}
