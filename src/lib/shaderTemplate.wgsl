struct Vertex {
  @builtin(vertex_index) index: u32,
}

struct Fragment {
  @builtin(position) position: vec4f,
  @location(0) uv: vec2f,
}

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
