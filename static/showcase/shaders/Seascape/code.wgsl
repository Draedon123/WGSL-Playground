// https://www.shadertoy.com/view/Ms2SD1
// Licensed under https://creativecommons.org/licenses/by-nc-sa/3.0/
// This is a WGSL port

const NUM_STEPS: u32 = 32;
const PI: f32 = 3.1415926535;
const EPSILON: f32 = 1e-3;
const AA: bool = false;

const ITER_GEOMETRY: u32 = 3;
const ITER_FRAGMENT: u32 = 5;
const SEA_HEIGHT: f32 = 0.6;
const SEA_CHOPPY: f32 = 4.0;
const SEA_SPEED: f32 = 0.8;
const SEA_FREQ: f32 = 0.16;
const SEA_BASE: vec3f = vec3f(0.0, 0.09, 0.18);
const SEA_WATER_COLOUR: vec3f = vec3f(0.8, 0.9, 0.6) * 0.6;
const octave_m: mat2x2f = mat2x2f(
  vec2f( 1.6, 1.2),
  vec2f(-1.2, 1.6),
);

fn EPSILON_NRM() -> f32 {
  return 0.1 / f32(params.resolution.x);
}

fn SEA_TIME() -> f32 {
  return 1.0 + params.time * SEA_SPEED;
}

fn fromEuler(ang: vec3f) -> mat3x3f {
  let a1: vec2f = vec2f(sin(ang.x), cos(ang.x));
  let a2: vec2f = vec2f(sin(ang.y), cos(ang.y));
  let a3: vec2f = vec2f(sin(ang.z), cos(ang.z));

  return mat3x3f(
    vec3f(a1.y * a3.y + a1.x * a2.x * a3.x, a1.y * a2.x * a3.x + a3.y * a1.x, -a2.y * a3.x),
    vec3f(-a2.y * a1.x, a1.y * a2.y, a2.x),
    vec3f(a3.y * a1.x * a2.x + a1.y * a3.x, a1.x * a3.x-a1.y * a3.y * a2.x, a2.y * a3.y),
  );
}

fn hash(p: vec2f) -> f32 {
  return fract(sin(dot(p, vec2f(127.1, 311.7)) * 43758.545312));
}

fn noise(p: vec2f) -> f32 {
  let i: vec2f = floor(p);
  let f: vec2f = fract(p);
  let u: vec2f = f * f * (3.0 - 2.0 * f);

  return -1.0 + 2.0 * 
    mix(
      mix(
        hash(i + vec2f(0.0, 0.0)),
        hash(i + vec2f(1.0, 0.0)),
        u.x,
      ),
      mix(
        hash(i + vec2f(0.0, 1.0)),
        hash(i + vec2f(1.0, 1.0)),
        u.x,
      ),
      u.y,
    );
}

fn diffuse(n: vec3f, l: vec3f, p: f32) -> f32 {
  return pow(dot(n, l) * 0.4 + 0.6, p);
}

fn specular(n: vec3f, l: vec3f, e: vec3f, s: f32) -> f32 {
  return pow(max(dot(reflect(e, n), l), 0.0), s) * (s + 8.0) / (PI * 8.0);
}

fn getSkyColour(_e: vec3f) -> vec3f {
  let e: vec3f = vec3f(_e.x, 0.8 * (0.2 + max(_e.y, 0.0) * 0.8), _e.z);
  return vec3f(pow(1.0 - e.y, 2.0), 1.0 - e.y, 0.6 + (1.0 - e.y) * 0.4) * 1.1;
}

fn seaOctave(_uv: vec2f, choppy: f32) -> f32 {
  let uv: vec2f = _uv + noise(_uv);
  let swv: vec2f = abs(cos(uv));
  var wv: vec2f = 1.0 - abs(sin(uv));

  wv = mix(wv, swv, wv);

  return pow(1.0 - pow(wv.x * wv.y, 0.65), choppy);
}

fn map(p: vec3f) -> f32 {
  var freq: f32 = SEA_FREQ;
  var amp: f32 = SEA_HEIGHT;
  var choppy: f32 = SEA_CHOPPY;

  var uv: vec2f = p.xz;
  uv.x *= 0.75;

  var d: f32 = 0.0;
  var h: f32 = 0.0;

  for(var i: u32 = 0; i < ITER_GEOMETRY; i++){
    d  = seaOctave((uv + SEA_TIME()) * freq, choppy);
    d += seaOctave((uv - SEA_TIME()) * freq, choppy);

    h += d * amp;
    uv *= octave_m;
    freq *= 1.9;
    amp *= 0.22;

    choppy = mix(choppy, 1.0, 0.2);
  }

  return p.y - h;
}

fn mapDetailed(p: vec3f) -> f32 {
  var freq: f32 = SEA_FREQ;
  var amp: f32 = SEA_HEIGHT;
  var choppy: f32 = SEA_CHOPPY;

  var uv: vec2f = p.xz;
  uv.x *= 0.75;

  var d: f32 = 0.0;
  var h: f32 = 0.0;

  for(var i: u32 = 0; i < ITER_FRAGMENT; i++){
    d  = seaOctave((uv + SEA_TIME()) * freq, choppy);
    d += seaOctave((uv - SEA_TIME()) * freq, choppy);

    h += d * amp;
    uv *= octave_m;
    freq *= 1.9;
    amp *= 0.22;

    choppy = mix(choppy, 1.0, 0.2);
  }

  return p.y - h;

}

fn getSeaColour(p: vec3f, n: vec3f, l: vec3f, eye: vec3f, dist: vec3f) -> vec3f {
  var fresnel: f32 = clamp(1.0 - dot(n, -eye), 0.0, 1.0);
  fresnel = min(fresnel * fresnel * fresnel, 0.5);

  let reflected: vec3f = getSkyColour(reflect(eye, n));
  let refracted: vec3f = SEA_BASE + diffuse(n, l, 80.0) * SEA_WATER_COLOUR * 0.12;
  var colour: vec3f = mix(refracted, reflected, fresnel);

  let atten: f32 = max(1.0 - dot(dist, dist) * 0.001, 0.0);

  colour += SEA_WATER_COLOUR * (p.y - SEA_HEIGHT) * 0.18 * atten;
  colour += specular(n, l, eye, 600.0 * inverseSqrt(dot(dist, dist)));

  return colour;
}

fn getNormal(p: vec3f, eps: f32) -> vec3f {
  var n: vec3f = vec3f(0.0);

  n.y = mapDetailed(p);
  n.x = mapDetailed(vec3f(p.x + eps, p.yz)) - n.y;
  n.z = mapDetailed(vec3f(p.xy, p.z + eps)) - n.y;
  n.y = eps;

  return normalize(n);
}

fn heightMapTracing(ori: vec3f, dir: vec3f, p: ptr<function, vec3f>) -> f32 {
  var tm: f32 = 0.0;
  var tx: f32 = 1000.0;
  var hx: f32 = map(ori + dir * tx);

  if(hx > 0.0){
    *p = ori + dir * tx;
    return tx;
  }

  var hm: f32 = map(ori);

  for(var i: u32 = 0; i < NUM_STEPS; i++){
    let tmid: f32 = mix(tm, tx, hm / (hm - hx));
    *p = ori + dir * tmid;
    let hmid: f32 = map(*p);

    if(hmid < 0.0){
      tx = tmid;
      hx = hmid;
    } else {
      tm = tmid;
      hm = hmid;
    }

    if(abs(hmid) < EPSILON){
      break;
    }
  }

  return mix(tm, tx, hm / (hm - hx));
}

fn getPixel(coord: vec2f, time: f32) -> vec3f {
  var uv: vec2f = coord / vec2f(params.resolution);
  uv = uv * 2.0 - 1.0;
  uv.x *= f32(params.resolution.x) / f32(params.resolution.y);

  let ang: vec3f = vec3f(sin(time * 3.0) * 0.1, sin(time) * 0.2 + 0.3, time);
  let ori: vec3f = vec3f(0.0, 3.5, time * 5.0);
  var dir: vec3f = normalize(vec3f(uv.xy, -2.0));

  dir.z += length(uv) * 0.14;
  dir = normalize(dir) * fromEuler(ang);

  var p: vec3f = vec3f(0.0);
  heightMapTracing(ori, dir, &p);

  let dist: vec3f = p - ori;
  let n: vec3f = getNormal(p, dot(dist, dist) * EPSILON_NRM());
  let light: vec3f = normalize(vec3f(0.0, 1.0, 0.8));

  return mix(
    getSkyColour(dir),
    getSeaColour(p, n, light, dir, dist),
    pow(smoothstep(0.0, -0.02, dir.y), 0.2),
  );
}

@fragment
fn main(fragment: Fragment) -> @location(0) vec4f {
  let time: f32 = params.time * 0.3;
  let fragmentPosition: vec2f = vec2f(fragment.position.x, f32(params.resolution.y) - fragment.position.y);

  var colour: vec3f = vec3f(0.0);
  if(AA){
    for(var i: f32 = -1; i <= 1; i += 1){
      for(var j: f32 = -1; j <= 1; j += 1){
        let uv: vec2f = fragmentPosition.xy + vec2f(i, j) / 3.0;
        colour += getPixel(uv, time);
      }
    }

    colour /= 9.0;
  } else {
    colour = getPixel(fragmentPosition.xy, time);
  }

  return vec4f(pow(colour, vec3f(0.65)), 1.0);
}
