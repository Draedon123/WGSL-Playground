<script lang="ts">
  import { replaceState } from "$app/navigation";
  import { resolve } from "$app/paths";
  import { onMount } from "svelte";

  onMount(() => {
    const match = location.hash.match(/#redirect=.+$/);

    if (match === null || match.length === 0) {
      return;
    }

    const redirectPath = decodeURIComponent(match[0].split("=")[1]);

    replaceState(redirectPath, {});
  });
</script>

<svelte:head>
  <title>WGSL Playground</title>
</svelte:head>

<main>
  <a href="{resolve('/shaders/')}#test1">Test Shader 1</a>
  <br />
  <a href="{resolve('/shaders/')}#test2">Test Shader 2</a>
</main>
