<script>
	import { PLAYER_VEHICLES, SELECTED_PLAYER } from '@store/players'
	import { MENU_WIDE } from '@store/stores'

	export let player

	$: truncatedName = player.name && player.name.length > 20 
		? player.name.slice(0, 20) + '...' 
		: player.name

    function SelectPlayer(player) {
        SELECTED_PLAYER.set(player);
        MENU_WIDE.set(true);
        PLAYER_VEHICLES.set(player.vehicles ?? []);
    }
</script>

<button
    class="
        w-full 
        flex items-center 
        px-[1.5vh] py-[1vh]
        rounded-[0.5vh] 
        bg-tertiary 
        hover:bg-opacity-90
    "
    on:click={() => SelectPlayer(player)}
>
    <div class="w-full flex items-center justify-between gap-[1vh]">
        <p class:text-green-400={player.metadata?.verified}>
            {player.id ? `${player.id} - ${truncatedName}` : truncatedName}
        </p>
        <i class="fas fa-angle-right" />
    </div>
</button>
