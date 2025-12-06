<script lang="ts">
  import { resolve } from "$app/paths";
  import { database } from "$lib/Database";
  import { liveQuery } from "dexie";

  let projects = liveQuery(() =>
    database.projects
      .toArray()
      .then((projects) => projects.sort((a, b) => a.name.localeCompare(b.name)))
  );
</script>

<h1>My Shaders</h1>
{#each $projects as project (project.id)}
  <a href="{resolve('/shaders')}#{project.id}">{project.name}</a>
  <br />
{/each}

<style lang="scss">
  h1 {
    text-align: center;
  }
</style>
