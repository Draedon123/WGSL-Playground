<script lang="ts">
  import Shader from "./Shader.svelte";
  import { database } from "$lib/Database";
  import { liveQuery } from "dexie";

  const shaders = liveQuery(() => database.showcase.toArray());
</script>

<h2>Showcase</h2>
<small>From shaders ported from Shadertoy</small>

<br />

{#if shaders}
  <div class="centre">
    <div class="shaders">
      {#each $shaders as shader (shader.name)}
        <div class="shader">
          <Shader project={shader} showcase={true} />
        </div>
      {/each}
    </div>
  </div>
{/if}

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
