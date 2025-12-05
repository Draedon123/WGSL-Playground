<script>
  import { resolve } from "$app/paths";
</script>

<svelte:head>
  <title>WGSL Playground</title>
</svelte:head>

<main>
  <a href="{resolve('/shaders/')}#test1">Test Shader 1</a>
  <br />
  <a href="{resolve('/shaders/')}#test2">Test Shader 2</a>
</main>
