<script lang="ts">
  import { resolve } from "$app/paths";
  import { onDestroy } from "svelte";
  import { setHash } from "$lib/hash";
  import type { Project } from "$lib/Database";

  type Props = {
    project: Project;
    showcase?: boolean;
  };

  let { project, showcase = false }: Props = $props();

  const thumbnailBlob = new Blob([project.thumbnail]);
  const thumbnailSrc = URL.createObjectURL(thumbnailBlob);
  const hash = project.id
    ? setHash(
        "id",
        project.id.toString(),
        showcase ? setHash("showcase", "1", "") : ""
      )
    : "";

  onDestroy(() => {
    URL.revokeObjectURL(thumbnailSrc);
  });
</script>

<a class="container" href="{resolve('/shaders')}{hash}">
  <h2>{project.name}</h2>
  <img src={thumbnailSrc} alt={project.name} />
</a>

<style lang="scss">
  .container {
    display: block;

    width: 100%;
    height: calc(100% - 5px);
    overflow: hidden;
    box-sizing: border-box;

    border: 1px solid #000;
    border-radius: 10px;

    cursor: pointer;
    color: #fff;
    background-color: #fff5;
    text-decoration: none;
    box-shadow: #fff2 0px 4px 15px 3px;

    transition:
      transform 0.2s ease-in,
      box-shadow 0.2s;
    &:hover {
      transform: scale(1.05);
      box-shadow: #fff5 0px 4px 15px 3px;
    }
  }

  h2 {
    text-align: center;
  }

  img {
    width: 100%;
  }
</style>
