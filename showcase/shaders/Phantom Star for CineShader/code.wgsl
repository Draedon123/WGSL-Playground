// https://www.shadertoy.com/view/ttKGDt
// Licensed under https://creativecommons.org/licenses/by-nc-sa/3.0/
// This is a WGSL port

const pi: f32 = acos(-1.0);
const pi2: f32 = pi * 2.0;

fn modulo(x: f32, y: f32) -> f32 {
  return x - y * floor(x / y);
}

fn rot(a: f32) -> mat2x2f {
  let c: f32 = cos(a);
  let s: f32 = sin(a);

  return mat2x2f(
    vec2f( c, s),
    vec2f(-s, c),
  );
}

fn pmod(p: vec2f, r: f32) -> vec2f {
  var a: f32 = atan2(p.x, p.y) + pi / r;
  let n: f32 = pi2 / r;

  a = floor(a / n) * n;

  return p * rot(-a);
}

fn box(p: vec3f, b: vec3f) -> f32 {
  let d: vec3f = abs(p) - b;
  return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, vec3f(0.0)));
}

fn ifsBox(_p: vec3f) -> f32 {
  var p: vec3f = _p;

  for(var i: u32 = 0; i < 5; i++){
    p = abs(p) - 1.0;

    let xy: vec2f = p.xy * rot(params.time * 0.3);
    p.x = xy.x;
    p.y = xy.y;

    let xz: vec2f = p.xz * rot(params.time * 0.1);
    p.x = xz.x;
    p.z = xz.y;
  }

  let xz: vec2f = p.xz * rot(params.time);
  p.x = xz.x;
  p.z = xz.y;

  return box(p, vec3f(0.4, 0.8, 0.3));
}

fn map(p: vec3f, cPos: vec3f) -> f32 {
  var p1: vec3f = p;

  p1.x = modulo(p1.x - 5.0, 10.0) - 5.0;
  p1.y = modulo(p1.y - 5.0, 10.0) - 5.0;
  p1.z = modulo(p1.z, 16.0) - 8.0;
  
  let xy: vec2f = pmod(p1.xy, 5.0);
  p1.x = xy.x;
  p1.y = xy.y;

  return ifsBox(p1);
}

@fragment
fn main(fragment: Fragment) -> @location(0) vec4f {
  let p: vec2f = (fragment.position.xy * 2.0 - vec2f(params.resolution)) / f32(min(params.resolution.x, params.resolution.y));
  
  let cPos: vec3f = vec3f(0.0, 0.0, -3.0 * params.time);
  let cDir: vec3f = normalize(vec3f(0.0, 0.0, -1.0));
  let cUp: vec3f = vec3f(sin(params.time), 1.0, 0.0);
  let cSide: vec3f = cross(cDir, cUp);

  let ray: vec3f = normalize(cSide * p.x + cUp * p.y + cDir);

  var acc: f32 = 0.0;
  var acc2: f32 = 0.0;
  var t: f32 = 0.0;

  for(var i: u32 = 0; i < 99; i++){
    let pos: vec3f = cPos + ray * t;
    let dist: f32 = max(abs(map(pos, cPos)), 0.02);
    var a: f32 = exp(-dist * 3.0);

    if(modulo(length(pos) + 24.0 * params.time, 30.0) < 3.0){
      a *= 2.0;
      acc2 += a;
    }

    acc += a;
    t += dist * 0.5;
  }  

  let col: vec3f = vec3f(acc * 0.01, acc * 0.011 + acc2 * 0.002, acc * 0.012 + acc2 * 0.005);
  return vec4f(col, 1.0 - t * 0.03);
}