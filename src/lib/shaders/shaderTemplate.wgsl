struct Vertex {
  @builtin(vertex_index) index: u32,
}

struct Fragment {
  @builtin(position) position: vec4f,
  @location(0) uv: vec2f,
}

struct _Parameters {
  resolution: vec2u,
  time: f32,
  deltaTime: f32,
  frame: u32,
  frameRate: f32,
}

@group(0) @binding(0) var <uniform> params: _Parameters;
@group(0) @binding(1) var textureSampler: sampler;

@group(1) @binding (0) var channel0: texture_2d<f32>;
@group(1) @binding (1) var channel1: texture_2d<f32>;
@group(1) @binding (2) var channel2: texture_2d<f32>;
@group(1) @binding (3) var channel3: texture_2d<f32>;

const VERTICES: array<vec2f, 3> = array(
  vec2f(-1.0,  3.0),
  vec2f(-1.0, -1.0),
  vec2f( 3.0, -1.0),
);

@vertex
fn _vertexMain(vertex: Vertex) -> Fragment {
  var output: Fragment;

  output.position = vec4f(VERTICES[vertex.index], 1.0, 1.0);
  output.uv = vec2f(output.position.xy * 0.5 + 0.5);

  return output;
}
