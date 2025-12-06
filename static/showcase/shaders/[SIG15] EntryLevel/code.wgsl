// https://www.shadertoy.com/view/llXXzf
// Licensed under https://creativecommons.org/licenses/by-nc-sa/3.0/
// Usage of Shadetoy's builtin images was removed
// This is a WGSL port

const PI: f32 = 3.1415926535;

fn xrot(t: f32) -> mat3x3f {
  let s: f32 = sin(t);
  let c: f32 = cos(t);

  return mat3x3f(
    vec3f(1.0, 0.0, 0.0),
    vec3f(0.0, c  , -s ),
    vec3f(0.0, s  , c  ),
  );
}

fn yrot(t: f32) -> mat3x3f {
  let s: f32 = sin(t);
  let c: f32 = cos(t);

  return mat3x3f(
    vec3f(c  , 0.0, -s ),
    vec3f(0.0, 1.0, 0.0),
    vec3f(s  , 0.0, c  ),
  );
}

fn zrot(t: f32) -> mat3x3f {
  let s: f32 = sin(t);
  let c: f32 = cos(t);

  return mat3x3f(
    vec3f(c  , -s , 0.0),
    vec3f(s  , c  , 0.0),
    vec3f(0.0, 0.0, 1.0),
  );
}

fn map(_p: vec3f) -> vec2f {
  let p: vec3f = vec3f(_p.x + sin(_p.z), _p.yz) * zrot(_p.z);
  var d: f32 = 1000.0;
  var q: vec3f = fract(p) * 2.0 - 1.0;
  var idx: u32 = 0;

  for(var i: u32 = 0; i < 3; i++){
    q = sign(q) * (1.0 - 1.0 / (1.0 + abs(q) * 0.8));

    var md: f32 = length(q) - 0.5;
    let ss: f32 = 0.5 + 0.5 * sin(p.z + md * f32(i) * 6.0);
    let cyl: f32 = length(p.xy) - 0.5 - ss;
    
    md = max(md, -cyl);

    if(md < d){
      d = md;
      idx = i;
    }
  }

  return vec2f(d, f32(idx));
}

fn normal(p: vec3f) -> vec3f {
  let o: vec3f = vec3f(0.1, 0.0, 0.0);

  return normalize(
    vec3f(
      map(p + o.xyy).x - map(p - o.xyy).x,
      map(p + o.yxy).x - map(p - o.yxy).x,
      map(p + o.yyx).x - map(p - o.yyx).x,
    )
  );
}

fn trace(o: vec3f, r: vec3f) -> f32 {
  var t: f32 = 0.0;

  for(var i: u32 = 0; i < 64; i++){
    let p: vec3f = o + r * t;
    let d: f32 = map(p).x;
    
    t += d * 0.3;
  }

  return t;
}

@fragment
fn main(fragment: Fragment) -> @location(0) vec4f {
  var uv: vec2f = fragment.uv * 2.0 - 1.0;
  uv.x *= f32(params.resolution.x) / f32(params.resolution.y);

  let r: vec3f = normalize(vec3f(uv, 1.0 - dot(uv, uv) * 0.33)) * zrot(params.time * 0.25) * yrot(-sin(params.time));
  let o: vec3f = vec3f(-sin(params.time), 0.0, params.time);

  let t: f32 = trace(o, r);
  let w: vec3f = o + r * t;
  let sn: vec3f = normal(w);
  let fd: vec2f = map(w);

  var diff: vec3f = vec3f(0.0);

  if (fd.y == 0.0) {
    diff = vec3f(1.0, 0.0, 0.0);
  } else if (fd.y == 1.0) {
    diff = vec3f(0.0, 1.0, 0.0);
  } else if (fd.y == 2.0) {
    diff = vec3f(0.0, 0.0, 1.0);
  } else {
    diff = vec3f(1.0, 1.0, 1.0);
  }

  diff = mix(diff, vec3f(1.0), abs(sn.y));
  diff = mix(vec3f(0.8, 0.0, 0.0), diff, abs(sn.y));

  let prod: f32 = max(dot(sn, -r), 0.0);
  diff *= prod;

  let fog: f32 = 1.0 / (1.0 + t * t * t * 0.1 + fd.x * 100.0);
  let fc: vec3f = diff * fog;

  return vec4f(sqrt(fc), 1.0);
}
