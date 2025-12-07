// https://www.shadertoy.com/view/MdX3zr
// Licensed under https://creativecommons.org/licenses/by-nc-sa/3.0/
// This is a WGSL port

fn noise(p: vec3f) -> f32 {
  let i: vec3f = floor(p);
  var a: vec4f = dot(i, vec3f(1.0, 57.0, 21.0)) + vec4f(0.0, 57.0, 21.0, 78.0);
  let f: vec3f = cos((p - i) * acos(-1.0)) * -0.5 + 0.5;

  a = mix(sin(cos(a) * a), sin(cos(1.0 + a) * (1.0 + a)), f.x);
  let xy: vec2f = mix(a.xz, a.yw, f.y);

  a.x = xy.x;
  a.y = xy.y;

  return mix(a.x, a.y, f.z);
}

fn sphere(p: vec3f, spr: vec4f) -> f32 {
  return length(spr.xyz - p) - spr.w;
}

fn flame(p: vec3f) -> f32 {
  let d: f32 = sphere(p * vec3f(1.0, 0.5, 1.0), vec4f(0.0, -1.0, 0.0, 1.0));
  return d + (noise(p + vec3f(0.0, params.time * 2.0, 0.0)) + noise(p * 3.0) * 0.5) * 0.25 * p.y;
}

fn scene(p: vec3f) -> f32 {
  return min(100.0 - length(p), abs(flame(p)));
}

fn raymarch(org: vec3f, dir: vec3f) -> vec4f {
  let eps: f32 = 0.02;
  var d: f32 = 0.0;
  var glow: f32 = 0.0;
  var p: vec3f = org;
  var glowed: bool = false;

  for(var i: u32 = 0; i < 64; i++){
    d = scene(p) + eps;
    p += d * dir;

    if(d > eps){
      if(flame(p) < 0.0){
        glowed = true;
      }

      if(glowed){
        glow = f32(i) / 64.0;
      }
    }
  }

  return vec4f(p, glow);
}

@fragment
fn main(fragment: Fragment) -> @location(0) vec4f {
  var v: vec2f = fragment.uv * 2.0 - 1.0;
  v.x *= f32(params.resolution.x) / f32(params.resolution.y);

  let org: vec3f = vec3f(0.0, -2.0, 4.0);
  let dir: vec3f = normalize(vec3f(v.x * 1.6, -v.y, -1.5));

  let p: vec4f = raymarch(org, dir);
  let glow: f32 = p.w;

  let col: vec4f = mix(vec4f(1.0, 0.5, 0.1, 1.0), vec4f(0.1, 0.5, 1.0, 1.0), p.y * 0.02 + 0.4);

  return mix(vec4f(0.0), col, pow(glow * 2.0, 4.0));
}
