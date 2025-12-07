// https://www.shadertoy.com/view/tlVGDt
// Licensed under https://creativecommons.org/licenses/by-nc-sa/3.0/
// This is a WGSL port

const REPEAT: f32 = 5.0;

fn swizzleAssignVec3fxy(vector3: ptr<function, vec3f>, swizzle: vec2f) {
  vector3.x = swizzle.x;
  vector3.y = swizzle.y;
}

fn swizzleAssignVec3fyz(vector3: ptr<function, vec3f>, swizzle: vec2f) {
  vector3.y = swizzle.x;
  vector3.z = swizzle.y;
}

fn moduloVec3f(x: vec3f, y: vec3f) -> vec3f {
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

fn sdBox(p: vec3f, b: vec3f) -> f32 {
  let q: vec3f = abs(p) - b;
  return length(max(q, vec3f(0.0))) + min(max(q.x, max(q.y, q.z)), 0.0);
}

fn box(pos: vec3f, scale: f32) -> f32 {
  let base: f32 = sdBox(pos * scale, vec3f(0.4, 0.4, 0.1)) / 1.5;

  return -base;
}

fn boxSet(_pos: vec3f, gTime: f32) -> f32 {
  let posOrigin: vec3f = _pos;
  var pos: vec3f = posOrigin;
  
  pos.y += sin(gTime * 0.4) * 2.5;
  swizzleAssignVec3fxy(&pos, pos.xy * rot(0.8));

  let box1: f32 = box(pos, 2.0 - abs(sin(gTime * 0.4)) * 1.5);
  pos = posOrigin;
  pos.y -= sin(gTime * 0.4) * 2.5;
  swizzleAssignVec3fxy(&pos, pos.xy * rot(0.8));

  let box2: f32 = box(pos, 2.0 - abs(sin(gTime * 0.4)) * 1.5);
  pos = posOrigin;
  pos.x += sin(gTime * 0.4) * 2.5;
  swizzleAssignVec3fxy(&pos, pos.xy * rot(0.8));

  let box3: f32 = box(pos, 2.0 - abs(sin(gTime * 0.4)) * 1.5);
  pos = posOrigin;
  pos.x -= sin(gTime * 0.4) * 2.5;
  swizzleAssignVec3fxy(&pos, pos.xy * rot(0.8));

  let box4: f32 = box(pos, 2.0 - abs(sin(gTime * 0.4)) * 1.5);
  pos = posOrigin;
  swizzleAssignVec3fxy(&pos, pos.xy * rot(0.8));

  let box5: f32 = box(pos, 0.5) * 6.0;
  pos = posOrigin;

  let box6: f32 = box(pos, 0.5) * 6.0;

  return max(max(max(max(max(box1, box2), box3), box4), box5), box6);
}

fn map(pos: vec3f, gTime: f32) -> f32 {
  return boxSet(pos, gTime);
}

@fragment
fn main(fragment: Fragment) -> @location(0) vec4f {
  let p: vec2f = (fragment.position.xy * 2.0 - vec2f(params.resolution.xy)) / f32(min(params.resolution.x, params.resolution.y));
  let ro: vec3f = vec3f(0.0, -0.2, params.time * 4.0);
  var ray: vec3f = normalize(vec3f(p, 1.5));

  swizzleAssignVec3fxy(&ray, ray.xy * rot(sin(params.time * 0.3) * 5.0));
  swizzleAssignVec3fyz(&ray, ray.yz * rot(sin(params.time * 0.5) * 0.2));

  var t: f32 = 0.1;
  var ac: f32 = 0.0;

  for(var i: u32 = 0; i < 99; i++){
    let pos: vec3f = moduloVec3f(ro + ray * t - 2.0, vec3f(4.0)) - 2.0;
    let gTime: f32 = params.time - f32(i) * 0.01;
    let d: f32 = max(abs(map(pos, params.time)), 0.01);

    ac += exp(-d * 23.0);
    t += d * 0.55;
  }

  let col: vec3f = vec3f(ac * 0.02) + vec3f(0.0, 0.2 * abs(sin(params.time)), 0.5 + sin(params.time) * 0.2);

  return vec4f(col, 1.0 - t * (0.02 + 0.02 * sin(params.time)));
}
