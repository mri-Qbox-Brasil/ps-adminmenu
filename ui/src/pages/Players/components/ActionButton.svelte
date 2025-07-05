<script lang="ts">
  export let icon = '';
  export let label = '';
  export let onClick: () => void;
</script>

<button
  class="h-[5vh] w-full rounded-[0.5vh] hover:bg-secondary"
  on:click={onClick}
>
  <i class={icon}></i>
  <p class="text-[1.2vh]">{label}</p>
</button>
