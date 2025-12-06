<script lang="ts">
  import { resolve } from "$app/paths";
  import type { Project } from "$lib/Database";
  import { onDestroy } from "svelte";

  type Props = {
    project: Project;
  };

  let { project }: Props = $props();

  let thumbnailBlob = new Blob([project.thumbnail]);
  let thumbnailSrc = URL.createObjectURL(thumbnailBlob);

  onDestroy(() => {
    URL.revokeObjectURL(thumbnailSrc);
  });
</script>

<a class="container" href="{resolve('/shaders')}#{project.id}">
  <h2>{project.name}</h2>
  <img src={thumbnailSrc} alt={project.name} />
</a>

<style lang="scss">
  .container {
    display: block;

    width: 100%;
    height: 100%;

    border: 1px solid #000;
    border-radius: 10px;

    cursor: pointer;
    color: #000;
    text-decoration: none;

    transition:
      transform 0.15s ease-in,
      box-shadow 0.15s;
    &:hover {
      transform: scale(1.05);
      box-shadow: #0006 0px 5px 15px;
    }
  }

  h2 {
    text-align: center;
  }

  img {
    width: 100%;
  }
</style>
