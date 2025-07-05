<script lang="ts">
	import { get } from 'svelte/store';
	import { MENU_WIDE, searchActions, BROWSER_MODE } from '@store/stores'
	import { PLAYER, PLAYER_VEHICLES, SELECTED_PLAYER } from '@store/players';
	import { ACTION, ALL_ACTIONS } from '@store/actions'
	import { onMount } from 'svelte';
	import { SendNUI } from '@utils/SendNUI';
	import Header from '@components/Header.svelte'
	import Tabs from './components/Tabs.svelte'
	import Button from './components/Button.svelte'
	import Dropdown from './components/Dropdown.svelte'
	import ButtonState from '@pages/Server/components/ButtonState.svelte'

	let loading = false;
	let playersOnline = [];
	let playersOffline = [];

	onMount(async () => {
		const browserMode = get(BROWSER_MODE);

		if (browserMode) {
			// Só em modo browser: escuta mock do debugData
			window.addEventListener('message', (event) => {
				if (!event.data?.action) return;

				switch (event.data.action) {
					case 'setPlayersData':
						playersOnline = event.data.data.filter((p) => p.online);
						playersOffline = event.data.data.filter((p) => !p.online);
						PLAYER.set(event.data.data);
						break;
					case 'setActionData':
						ACTION.set(event.data.data);
						break;
				}
			});
		} else {
			// Ambiente normal no jogo (FiveM)
			try {
				loading = true;
				const players = await SendNUI('getPlayers');
				if (players) {
					playersOnline = players.filter((player) => player.online);
					playersOffline = players.filter((player) => !player.online);
					PLAYER.set(players);
				}
			} catch (error) {
				console.error('Erro ao carregar jogadores:', error);
			} finally {
				loading = false;
			}
		}
	});
</script>

<div class="h-full w-[99vh] px-[2vh]">
	<Header 
		title={'Ações'} 
		hasSearch={true} 
		hasLargeMenu={true} 
		onSearchInput={event => $searchActions = event.target.value}
		search={$searchActions}
	/>
	<Tabs />
	<div class="w-full h-[77%] flex flex-col gap-[1vh] mt-[1vh] overflow-auto scroll-visble">
		{#if $ACTION}
			{#each Object.entries($ACTION)
			.filter(([actionKey, actionValue]) => {
				if ($ALL_ACTIONS) {
					return actionValue.label.toLowerCase().includes($searchActions.toLowerCase());
				} else {
					return localStorage.getItem(`favorite-${actionKey}`) === 'true';
				}
			})
			.sort(([aKey, aValue], [bKey, bValue]) =>
				aValue.label.localeCompare(bValue.label)
			) as [actionKey, actionValue]}
				{#if actionValue.dropdown}
					<Dropdown data={actionValue} id={actionKey} />
				{:else}
					<Button data={actionValue} id={actionKey} />
				{/if}
			{/each}
		{/if}
	</div>
</div>
