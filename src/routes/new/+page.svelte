<script lang="ts">
  import defaultShader from "$lib/shaders/default.wgsl?raw";

  import { onMount } from "svelte";
  import { resolve } from "$app/paths";
  import { database } from "$lib/Database";
  import { fetchBuffer } from "$lib/fetch";

  let redirect: HTMLAnchorElement;

  onMount(async () => {
    const id = await database.projects.add({
      name: "Untitled",
      code: defaultShader,
      thumbnail: await fetchBuffer("default_thumbnail.png"),
      channels: [
        new ArrayBuffer(),
        new ArrayBuffer(),
        new ArrayBuffer(),
        new ArrayBuffer(),
      ],
    });

    redirectUser(resolve("/shaders") + `#id=${id}`);
  });

  function redirectUser(path: string): void {
    redirect.href = path;

    // ???
    setTimeout(() => {
      redirect.click();
    }, 1);
  }
</script>

<main>
  <h1>Creating new shader...</h1>
</main>

<!-- svelte-ignore a11y_consider_explicit_label -->
<!-- svelte-ignore a11y_missing_attribute -->
<a style="display: none;" bind:this={redirect}></a>
