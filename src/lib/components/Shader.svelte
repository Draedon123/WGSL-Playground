<script lang="ts">
  import { resolve } from "$app/paths";
  import { onDestroy } from "svelte";
  import { setHash } from "$lib/hash";
  import type { Project } from "$lib/Database";
  import { fromArrayBuffer } from "$lib/base64";

  type Props = {
    project: Project;
  };

  let { project }: Props = $props();

  const thumbnailBlob = new Blob([project.thumbnail]);
  const thumbnailSrc = URL.createObjectURL(thumbnailBlob);
  const hash = project.id
    ? setHash("id", project.id.toString(), "")
    : (() => {
        let hash = "";

        hash = setHash("raw", encodeURIComponent(project.code), hash);
        hash = setHash("name", encodeURIComponent(project.name), hash);

        for (let i = 0; i < 4; i++) {
          const channel = project.channels[i];

          if (channel.byteLength === 0) {
            continue;
          }

          hash = setHash(
            `channel${i}`,
            encodeURIComponent(fromArrayBuffer(channel)),
            hash
          );
        }

        console.log(hash.length);
        return hash;
      })();

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
