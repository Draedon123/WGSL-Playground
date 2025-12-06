<script lang="ts">
  import defaultShader from "$lib/shaders/default.wgsl?raw";
  import showcaseShaders from "$lib/shaders/list.json";

  import { resolve } from "$app/paths";
  import { database, type Project } from "$lib/Database";
  import { onMount } from "svelte";

  let { children }: WithChildren = $props();

  async function loadBuiltins(): Promise<void> {
    if (localStorage.getItem("loadedBuiltins") !== null) {
      return;
    }

    const defaultThumbnail = await (
      await fetch(resolve("/") + "default_thumbnail.png")
    ).arrayBuffer();

    await database.projects.add({
      name: "My First Shader",
      code: defaultShader,
      thumbnail: defaultThumbnail,
      channels: [
        new ArrayBuffer(),
        new ArrayBuffer(),
        new ArrayBuffer(),
        new ArrayBuffer(),
      ],
    });

    const shaders: Project[] = [];
    for (const shader of showcaseShaders) {
      const folder = resolve("/") + `showcase/shaders/${shader.name}/`;

      const code = await (await fetch(folder + "code.wgsl")).text();
      const thumbnail = await (
        await fetch(folder + "thumbnail.png")
      ).arrayBuffer();
      const channels: ArrayBuffer[] = [
        new ArrayBuffer(),
        new ArrayBuffer(),
        new ArrayBuffer(),
        new ArrayBuffer(),
      ];

      for (let i = 0; i < shader.channels; i++) {
        channels[i] = await (
          await fetch(folder + `channel${i}.png`)
        ).arrayBuffer();
      }

      shaders.push({
        name: shader.name,
        code,
        thumbnail,
        channels,
      });
    }

    await database.showcase.bulkAdd(shaders);

    localStorage.setItem("loadedBuiltins", "true");
  }

  onMount(async () => {
    // preload
    import("monaco-editor");

    await database.open();
    loadBuiltins();
  });
</script>

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

  {@render Item(resolve("/shaders"), "Shaders")}
  {@render Item(resolve("/"), "Home")}
</nav>

<div class="content">
  {@render children?.()}
</div>

<style lang="scss">
  $navigation-height: 2.5rem;

  nav {
    position: fixed;
    top: 0;
    left: 0;

    width: 100vw;
    height: $navigation-height;
    font-size: calc(0.7 * $navigation-height);
    align-content: center;

    background-color: #666;

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
    margin-top: $navigation-height;
  }
</style>
