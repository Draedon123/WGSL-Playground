<script lang="ts">
  import bin from "$lib/icons/bin.svg";

  import { resolve } from "$app/paths";
  import { onDestroy } from "svelte";
  import { setHash } from "$lib/hash";
  import { database, type Project } from "$lib/Database";

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

  async function deleteShader(event: MouseEvent): Promise<void> {
    event.preventDefault();

    if (showcase) {
      return;
    }

    // TODO: REPLACE WITH <dialog>
    if (confirm(`Do you want to delete "${project.name}"?`)) {
      // surely project.id is always defined...
      await database.projects.delete(project.id as number);
    }
  }

  onDestroy(() => {
    URL.revokeObjectURL(thumbnailSrc);
  });
</script>

<a class="container" href="{resolve('/shaders')}{hash}">
  <h2>{project.name}</h2>
  <img src={thumbnailSrc} alt={project.name} />
  <input
    type="image"
    src={bin}
    alt="Delete"
    title="Delete"
    class:hidden={showcase}
    onclick={deleteShader}
  />
</a>

<style lang="scss">
  .container {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: flex-end;
    row-gap: 2px;

    position: relative;
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
    width: 80%;
    height: 100%;
    border-bottom: 1px solid #fff3;
  }

  img {
    width: 100%;
    align-self: flex-end;
  }

  input {
    position: absolute;
    top: 0.5em;
    right: 0.5em;

    height: 2em;
  }

  .hidden {
    display: none;
  }
</style>
