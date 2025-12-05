<script lang="ts">
  import { database } from "$lib/Database";
  import { onMount } from "svelte";

  let { children }: WithChildren = $props();

  onMount(async () => {
    await database.open();
  });
</script>

{@render children?.()}
