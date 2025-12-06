const __vite__mapDeps=(i,m=__vite__mapDeps,d=(m.f||(m.f=["../chunks/Bexqu5xa.js","../chunks/PPVm8Dsz.js"])))=>i.map(i=>d[i]);
import{_ as j}from"../chunks/PPVm8Dsz.js";import"../chunks/DsnmJJEf.js";import{p as U,o as B,D as R,E as C,a as k,b as A,aj as D,i as c,ak as V,af as W,H as E,I as F,F as y,al as z,B as T,am as I,ah as O,G as _}from"../chunks/BbEfYca8.js";import{s as S,r as N}from"../chunks/Dx8V9gCf.js";import{b as L,s as H,a as q}from"../chunks/Bt-CNOKb.js";import{l as K,d as Q}from"../chunks/DthPHJ-z.js";function Y(v){return new Worker(""+new URL("../workers/editor.worker-CdQrwHl8.js",import.meta.url).href,{name:v?.name})}const J=`struct Vertex {\r
  @builtin(vertex_index) index: u32,\r
}\r
\r
struct Fragment {\r
  @builtin(position) position: vec4f,\r
  @location(0) uv: vec2f,\r
}\r
\r
const VERTICES: array<vec2f, 3> = array(\r
  vec2f(-1.0,  3.0),\r
  vec2f(-1.0, -1.0),\r
  vec2f( 3.0, -1.0),\r
);\r
\r
@vertex\r
fn _vertexMain(vertex: Vertex) -> Fragment {\r
  var output: Fragment;\r
\r
  output.position = vec4f(VERTICES[vertex.index], 1.0, 1.0);\r
  output.uv = vec2f(output.position.xy * 0.5 + 0.5);\r
\r
  return output;\r
}\r
`;var X=R('<canvas class="svelte-18jl3mp"></canvas>');function Z(v,f){U(f,!0);const w=4,b="rgba8unorm";let m,n,o,e,s,d,u,l=null,i;async function x(a){if(o===void 0||e===void 0)return null;const t=e.createShaderModule({code:J+a});return(await t.getCompilationInfo()).messages.length>0?new Error("Invalid shader"):(l=e.createRenderPipeline({layout:u,vertex:{module:t,entryPoint:"_vertexMain"},fragment:{module:t,targets:[{format:b}]}}),g(),null)}function g(){if(o===void 0||e===void 0||l===null)return;const a=e.createCommandEncoder(),t=a.beginRenderPass({colorAttachments:[{loadOp:"clear",storeOp:"store",view:n.getCurrentTexture().createView()}]});t.setBindGroup(0,d),t.setPipeline(l),t.draw(3),t.end(),e.queue.submit([a.finish()])}B(async()=>{if(!("gpu"in navigator)){console.error("WebGPU not supported by your browser/device");return}if(n=m.getContext("webgpu"),n===null){console.error("Could not get WebGPU Canvas Rendering Context");return}if(o=await navigator.gpu.requestAdapter(),o===null){console.error("Could not find valid GPU Adapter. Maybe WebGPU isn't supported by your browser/device?");return}e=await o.requestDevice(),n.configure({device:e,format:b}),i=e.createBuffer({label:"Settings Buffer",size:w,usage:GPUBufferUsage.UNIFORM|GPUBufferUsage.COPY_DST}),s=e.createBindGroupLayout({entries:[{binding:0,buffer:{type:"uniform"},visibility:GPUShaderStage.FRAGMENT}]}),u=e.createPipelineLayout({bindGroupLayouts:[s]}),d=e.createBindGroup({layout:s,entries:[{binding:0,resource:{buffer:i}}]})});var h={recompile:x},p=X();return L(p,a=>m=a,()=>m),C(()=>{S(p,"width",f.width),S(p,"height",f.height)}),k(v,p),A(h)}var ee=R('<main><h1 class="svelte-1g8lzsd"> </h1> <a>Home</a> <div class="centre svelte-1g8lzsd"><div class="main svelte-1g8lzsd"><div class="canvas svelte-1g8lzsd"><!></div> <div class="editor svelte-1g8lzsd"></div></div></div></main>');function se(v,f){U(f,!0);const w=()=>q(e,"$_project",b),[b,m]=H();let n,o=z(1),e=K(()=>Q.projects.where({id:c(o)}).toArray()),s=I(()=>w()?.[0]??null),d=I(()=>c(s)?.code??""),u,l,i;async function x(r){i!==void 0&&(r.code!=="KeyS"||!r.ctrlKey||(r.preventDefault(),T(d,i.getValue()),await u.recompile(c(d))))}B(async()=>{T(o,parseInt(location.hash.slice(1)),!0),n=await j(()=>import("../chunks/Bexqu5xa.js").then(r=>r.b),__vite__mapDeps([0,1]),import.meta.url),self.MonacoEnvironment={getWorker:()=>new Y},i=n.editor.create(l,{automaticLayout:!0,theme:"vs-dark"}),i.setModel(n.editor.createModel(c(d)??"","wgsl")),await u.recompile(c(d))}),V(()=>{n?.editor.getModels().forEach(r=>r.dispose()),i?.dispose()});var g=ee();W(r=>{C(()=>O.title=`WGSL Playground - ${c(s)?.name??"Loading..."??""}`)});var h=y(g),p=y(h,!0);_(h);var a=E(h,2),t=E(a,2),P=y(t),G=y(P),$=y(G);L(Z($,{width:800,height:450}),r=>u=r,()=>u),_(G);var M=E(G,2);M.__keydown=x,L(M,r=>l=r,()=>l),_(P),_(t),_(g),C(r=>{F(p,c(s)?.name??"Loading..."),S(a,"href",r)},[()=>N("/")]),k(v,g),A(),m()}D(["keydown"]);export{se as component};
