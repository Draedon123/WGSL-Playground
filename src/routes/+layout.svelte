<script lang="ts">
  import defaultShader from "$lib/shaders/default.wgsl?raw";
  import showcaseShaders from "$lib/shaders/list.json";

  import { resolve } from "$app/paths";
  import { database, type Project } from "$lib/Database";
  import { onMount } from "svelte";
  import { fetchBuffer, fetchText } from "$lib/fetch";

  let { children }: WithChildren = $props();

  async function loadBuiltins(): Promise<void> {
    if (
      parseInt(localStorage.getItem("shaderVersion") ?? "-1") ===
      showcaseShaders.version
    ) {
      return;
    }

    await database.showcase.clear();
    const shaders: Project[] = [];
    for (const shader of showcaseShaders.shaders) {
      const folder = `showcase/shaders/${shader.name}/`;

      const code = await fetchText(folder + "code.wgsl");
      const thumbnail = await fetchBuffer(folder + "thumbnail.png");
      const channels: [ArrayBuffer, ArrayBuffer, ArrayBuffer, ArrayBuffer] = [
        new ArrayBuffer(),
        new ArrayBuffer(),
        new ArrayBuffer(),
        new ArrayBuffer(),
      ];

      for (let i = 0; i < shader.channels; i++) {
        channels[i] = await fetchBuffer(folder + `channel${i}.png`);
      }

      shaders.push({
        name: shader.name,
        code,
        thumbnail,
        channels,
      });
    }

    await database.showcase.bulkAdd(shaders);

    localStorage.setItem("shaderVersion", showcaseShaders.version.toString());
  }

  onMount(async () => {
    // preload
    import("monaco-editor");

    await database.open();
    loadBuiltins();
  });
</script>

<svelte:head>
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" />
  <link
    href="https://fonts.googleapis.com/css2?family=Montserrat:ital,wght@0,100..900;1,100..900&display=swap"
    rel="stylesheet"
  />
</svelte:head>

<nav>
  {#snippet Item(href: string, content: string)}
    <a
      {href}
      onclick={() => {
        // assume item doesn't link to page with hash
        location.hash = "";
      }}>{content}</a
    >
  {/snippet}

  {@render Item(resolve("/new"), "New")}
  {@render Item(resolve("/shaders"), "My Shaders")}
  {@render Item(resolve("/"), "Home")}
</nav>

<div class="content">
  {@render children?.()}
</div>

<div
  class="background"
  style="background-image: url({resolve('/')}background.jpg)"
></div>
<div class="filter"></div>

<style lang="scss">
  $navigation-height: 2.5rem;

  :global(*):where(*) {
    color: #fff;
    font-family: Montserrat, sans-serif;
  }

  nav {
    position: fixed;
    top: 0;
    left: 0;

    width: 100vw;
    height: $navigation-height;
    align-content: center;

    z-index: 999;
    font-size: calc(0.7 * $navigation-height);

    background-color: #3338;
    border-bottom: 1px solid #fff4;

    a {
      color: #fff;
      text-decoration: none;
      transition: color 0.3s;

      margin: 0 1ch;
      float: right;

      // first child is on the right because of `float: right`
      &:first-child {
        margin-right: 1.5ch;
      }

      &:hover {
        color: #c56dee;
      }
    }
  }

  .content {
    margin-top: calc($navigation-height + 10px);
  }

  .background,
  .filter {
    position: fixed;
    top: 0;
    left: 0;

    width: 100vw;
    height: 100vh;
  }

  .background {
    z-index: -2;
    background-size: cover;
  }

  .filter {
    z-index: -1;
    backdrop-filter: blur(7px);
    background: radial-gradient(
      circle at center,
      #0004 0%,
      #0009 60%,
      #000c 100%
    );
  }
</style>
