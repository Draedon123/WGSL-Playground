<script lang="ts">
  import Shader from "./Shader.svelte";
  import { database } from "$lib/Database";
  import { liveQuery } from "dexie";

  const shaders = liveQuery(() => database.showcase.toArray());
</script>

<h2>Showcase</h2>
<small>From shaders ported from Shadertoy</small>

<br />

<!-- assume that there is always more than one showcase shader -->
{#if $shaders && $shaders.length > 0}
  <div class="centre">
    <div class="shaders">
      {#each $shaders as shader (shader.name)}
        <div class="shader">
          <Shader project={shader} showcase={true} />
        </div>
      {/each}
    </div>
  </div>
{:else}
  <p class="loading">Loading...</p>
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

  .loading {
    display: block;
    text-align: center;
    font-size: large;
  }
</style>
