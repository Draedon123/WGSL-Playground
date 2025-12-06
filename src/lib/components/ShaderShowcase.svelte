<script lang="ts">
  import { resolve } from "$app/paths";
  import type { Project } from "$lib/Database";
  import Shader from "./Shader.svelte";

  const shaders = getShaders();

  async function getShaders(): Promise<Project[]> {
    const SHADERS = ["[SIG15] EntryLevel"];
    const promises: Promise<Project>[] = SHADERS.map(async (shader) => {
      const shaderSource = await (
        await fetch(resolve("/") + `showcase/shaders/${shader}.wgsl`)
      ).text();
      const thumbnail = await (
        await fetch(resolve("/") + `showcase/thumbnails/${shader}.png`)
      ).arrayBuffer();
      const data = await (
        await fetch(resolve("/") + `showcase/shaders/${shader}.json`)
      ).json();
      const channelCount: number = data.channels;
      const channels = [
        new ArrayBuffer(),
        new ArrayBuffer(),
        new ArrayBuffer(),
        new ArrayBuffer(),
      ];

      for (let i = 0; i < channelCount; i++) {
        channels[i] = await (
          await fetch(
            resolve("/") + `showcase/shaders/channels/${shader}${i}.png`
          )
        ).arrayBuffer();
      }

      const project: Project = {
        name: shader,
        code: shaderSource,
        thumbnail,
        channels,
      };

      return project;
    });

    return Promise.all(promises);
  }
</script>

<h2>Showcase</h2>
<small>From shaders ported from Shadertoy</small>

<br />

{#await shaders}
  <p>Loading showcase...</p>
{:then shaders}
  <div class="centre">
    <div class="shaders">
      {#each shaders as shader (shader.name)}
        <div class="shader">
          <Shader project={shader} />
        </div>
      {/each}
    </div>
  </div>
{/await}

<style lang="scss">
  .shaders {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;

    width: 90%;
    gap: 15px;
  }

  .shader {
    width: 400px;
  }

  .centre {
    display: flex;
    justify-content: center;

    width: 100%;
  }

  h2,
  small {
    text-align: center;
    display: block;
  }
</style>
