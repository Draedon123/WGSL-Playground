<script lang="ts">
  import Shader from "./Shader.svelte";

  import { database } from "$lib/Database";
  import { liveQuery } from "dexie";

  let projects = liveQuery(() =>
    database.projects
      .toArray()
      .then((projects) => projects.sort((a, b) => a.name.localeCompare(b.name)))
  );
</script>

<h1>My Shaders</h1>
<div class="centre">
  <div class="shader-container">
    {#each $projects as project (project.id)}
      <div class="shader">
        <Shader {project} />
      </div>
    {/each}
  </div>
</div>

<style lang="scss">
  h1 {
    text-align: center;
  }

  .shader-container {
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
</style>
