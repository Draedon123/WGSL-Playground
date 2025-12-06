<script lang="ts">
  import { resolve } from "$app/paths";
  import { onMount } from "svelte";
  import { database } from "$lib/Database";
  import defaultShader from "$lib/shaders/default.wgsl?raw";
  import ShaderShowcase from "$lib/components/ShaderShowcase.svelte";

  let redirect: HTMLAnchorElement;

  onMount(() => {
    setDefaultProject();
    redirectUser();
  });

  function redirectUser(): void {
    const match = location.hash.match(/#redirect=.+$/);

    if (match === null || match.length === 0) {
      return;
    }

    const redirectPath = decodeURIComponent(match[0].split("=")[1]);

    redirect.href = resolve("/") + redirectPath;

    // ???
    setTimeout(() => {
      redirect.click();
    }, 1);
  }

  async function setDefaultProject(): Promise<void> {
    if (localStorage.getItem("hasAddedDefaultProject") === null) {
      await database.projects.add({
        name: "My First Shader",
        code: defaultShader,
      });

      localStorage.setItem("hasAddedDefaultProject", "true");
    }
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
