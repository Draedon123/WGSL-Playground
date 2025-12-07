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
  <div class="title">
    <h1>WGSL Playground</h1>
  </div>

  <ShaderShowcase />
</main>

<!-- svelte-ignore a11y_consider_explicit_label -->
<!-- svelte-ignore a11y_missing_attribute -->
<a style="display: none;" bind:this={redirect}></a>

<style lang="scss">
  .title {
    display: flex;
    justify-content: center;

    margin-top: 1.25em;
    margin-bottom: 1.25em;
  }

  h1 {
    width: max-content;
  }
</style>
