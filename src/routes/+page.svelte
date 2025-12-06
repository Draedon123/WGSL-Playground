<script lang="ts">
  import ShaderShowcase from "$lib/components/ShaderShowcase.svelte";

  import { resolve } from "$app/paths";
  import { onMount } from "svelte";
  import { getHash } from "$lib/hash";

  let redirect: HTMLAnchorElement;

  onMount(() => {
    redirectUser();
  });

  function redirectUser(): void {
    const redirectPath = decodeURIComponent(getHash("redirect") ?? "");

    if (redirectPath === "") {
      return;
    }

    redirect.href = resolve("/") + redirectPath;

    // ???
    setTimeout(() => {
      redirect.click();
    }, 1);
  }
</script>

<svelte:head>
  <title>WGSL Playground</title>
</svelte:head>

<main>
  <h1>WGSL Playground</h1>

  <ShaderShowcase />
</main>

<!-- svelte-ignore a11y_consider_explicit_label -->
<!-- svelte-ignore a11y_missing_attribute -->
<a style="display: none;" bind:this={redirect}></a>

<style lang="scss">
  h1 {
    text-align: center;
  }
</style>
