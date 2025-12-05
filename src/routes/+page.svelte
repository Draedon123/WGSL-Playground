<script lang="ts">
  import { resolve } from "$app/paths";
  import { onMount } from "svelte";

  let redirect: HTMLAnchorElement;

  onMount(() => {
    const match = location.hash.match(/#redirect=.+$/);

    if (match === null || match.length === 0) {
      return;
    }

    const redirectPath = decodeURIComponent(match[0].split("=")[1]);

    redirect.href = redirectPath;
    redirect.click();
  });
</script>

<svelte:head>
  <title>WGSL Playground</title>
</svelte:head>

<main>
  <a href="{resolve('/shaders')}#test1">Test Shader 1</a>
  <br />
  <a href="{resolve('/shaders')}#test2">Test Shader 2</a>
</main>

<!-- svelte-ignore a11y_consider_explicit_label -->
<!-- svelte-ignore a11y_missing_attribute -->
<a style="display: none;" bind:this={redirect} href={resolve("/")}></a>
