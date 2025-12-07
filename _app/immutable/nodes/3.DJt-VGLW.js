import"../chunks/DsnmJJEf.js";import{i as o}from"../chunks/BsfT3vlS.js";import{p as m,o as c,f as d,s as u,a as p,b as l,c as h,m as g,g as e,d as b,h as v}from"../chunks/B39YqE9V.js";import{b as w}from"../chunks/DcX3g68H.js";import{d as y,r as _}from"../chunks/CYjs1OJ3.js";import{f as B}from"../chunks/Cn626UnJ.js";const A=`@fragment\r
fn main(fragment: Fragment) -> @location(0) vec4f {\r
  return vec4f(fragment.uv, 0.0, 1.0);\r
}\r
`;var U=d('<main><h1>Creating new shader...</h1></main>  <a style="display: none;"></a>',1);function S(n,s){m(s,!1);let a=b();c(async()=>{const r=await y.projects.add({name:"Untitled",code:A,thumbnail:await B("default_thumbnail.png"),channels:[new ArrayBuffer,new ArrayBuffer,new ArrayBuffer,new ArrayBuffer]});i(_("/shaders")+`#id=${r}`)});function i(r){g(a,e(a).href=r),setTimeout(()=>{e(a).click()},1)}o();var t=U(),f=u(p(t),2);w(f,r=>v(a,r),()=>e(a)),l(n,t),h()}export{S as component};
