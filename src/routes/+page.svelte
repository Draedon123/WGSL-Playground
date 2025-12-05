<script lang="ts">
  import { resolve } from "$app/paths";
  import { onMount } from "svelte";
  import { liveQuery } from "dexie";
  import { database } from "$lib/Database";

  let redirect: HTMLAnchorElement;

  let projects = liveQuery(() =>
    database.projects
      .toArray()
      .then((projects) => projects.sort((a, b) => a.name.localeCompare(b.name)))
  );

  onMount(() => {
    setDefaultProject();
    redirectUser();
  });

  function redirectUser(): void {
    const match = location.hash.match(/#redirect=.+$/);

    if (match === null || match.length === 0) {
      return;
    }

    const redirectPath = decodeURIComponent(match[0].split("=")[1]);

    redirect.href = resolve("/") + redirectPath;

    // ???
    setTimeout(() => {
      redirect.click();
    }, 1);
  }

  async function setDefaultProject(): Promise<void> {
    if (localStorage.getItem("hasAddedDefaultProject") === null) {
      await database.projects.add({
        name: "Default",
        // TODO: add default code
        code: "",
      });

      localStorage.setItem("hasAddedDefaultProject", "true");
    }
  }
</script>

<svelte:head>
  <title>WGSL Playground</title>
</svelte:head>

<main>
  <h1>WGSL Playground</h1>

  {#each $projects as project (project.id)}
    <a href="{resolve('/shaders')}#{project.id}">{project.name}</a>
    <br />
  {/each}
</main>

<!-- svelte-ignore a11y_consider_explicit_label -->
<!-- svelte-ignore a11y_missing_attribute -->
<a style="display: none;" bind:this={redirect}></a>
