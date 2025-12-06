<script lang="ts">
  import { resolve } from "$app/paths";
  import { database } from "$lib/Database";
  import { onMount } from "svelte";
  import defaultShader from "$lib/shaders/default.wgsl?raw";

  let { children }: WithChildren = $props();

  async function setDefaultProject(): Promise<void> {
    if (localStorage.getItem("hasAddedDefaultProject") === null) {
      const thumbnail = await (
        await fetch(resolve("/") + "default_thumbnail.png")
      ).arrayBuffer();

      await database.projects.add({
        name: "My First Shader",
        code: defaultShader,
        thumbnail,
      });

      localStorage.setItem("hasAddedDefaultProject", "true");
    }
  }

  onMount(async () => {
    // preload
    import("monaco-editor");

    await database.open();
    setDefaultProject();
  });
</script>

<nav>
  {#snippet Item(href: string, content: string)}
    <a {href}>{content}</a>
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
