import"../chunks/DsnmJJEf.js";import{i as f}from"../chunks/BsfT3vlS.js";import{p as m,o as u,f as c,s as p,a as l,b as d,c as v,m as h,g as n,d as g,h as b}from"../chunks/B39YqE9V.js";import{b as y}from"../chunks/DcX3g68H.js";import{d as w,r as A}from"../chunks/BkrORxOG.js";import{f as _}from"../chunks/D3HRRpJw.js";const B=`/*\r
Available uniforms under the \`params\` object:\r
struct Parameters {\r
  resolution: vec2u,\r
  time: f32,\r
  deltaTime: f32,\r
  frame: u32,\r
  frameRate: f32,\r
}\r
\r
And for Fragment:\r
struct Fragment {\r
  @builtin(position) position: vec4f,\r
  @location(0) uv: vec2f,\r
}\r
*/\r
\r
@fragment\r
fn main(fragment: Fragment) -> @location(0) vec4f {\r
  // equivalent to fragment.uv with a flipped v component\r
  var uv: vec2f = fragment.position.xy / vec2f(params.resolution);\r
\r
  uv.y = 1.0 - uv.y;\r
\r
  return vec4f(uv, (1.0 - cos(params.time)) / 2, 1.0);\r
}\r
`;var F=c('<main><h1>Creating new shader...</h1></main>  <a style="display: none;"></a>',1);function C(t,i){m(i,!1);let r=g();u(async()=>{const a=await w.projects.add({name:"Untitled",code:B,thumbnail:await _("default_thumbnail.png"),channels:[new ArrayBuffer,new ArrayBuffer,new ArrayBuffer,new ArrayBuffer]});o(A("/shaders")+`#id=${a}`)});function o(a){h(r,n(r).href=a),setTimeout(()=>{n(r).click()},1)}f();var e=F(),s=p(l(e),2);y(s,a=>b(r,a),()=>n(r)),d(t,e),v()}export{C as component};
