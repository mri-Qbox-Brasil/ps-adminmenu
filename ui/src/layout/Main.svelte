<script>
	import { fly } from 'svelte/transition'
	import { MENU_WIDE, ACTIVE_PAGE } from '@store/stores'
	import Sidebar from './Sidebar/Sidebar.svelte'

	import Actions from '@pages/Actions/Actions.svelte'
	import Server from '@pages/Server/Server.svelte'
	import StaffChat from '@pages/Chat/Chat.svelte'
	import Players from '@pages/Players/Players.svelte'
	import Commands from '@pages/Commands/Commands.svelte'
	import Items from '@pages/Items/Items.svelte'
	import Vehicles from '@pages/Vehicles/Vehicles.svelte'
	import Credits from '@pages/Credits/MRIQbox.svelte'
	import Dashboard from '@pages/Dashboard/Dashboard.svelte'
	import Groups from '@pages/Groups/Groups.svelte'
	import Bans from '@pages/Bans.svelte'
</script>

<div
	class="h-[85vh] flex rounded-[0.5vh] bg-primary bg-opacity-95 {!$MENU_WIDE ? 'w-[40vh] mr-[5vh] ' : 'w-[106vh]'}" transition:fly={{ x: 100 }}
>
	<Sidebar />
	<div class="h-full flex {!$MENU_WIDE ? 'w-[33vh]' : 'w-[99vh]'}">
		{#if $ACTIVE_PAGE == 'Ações'}
			<Actions />
		{:else if $ACTIVE_PAGE == 'Resources'}
			<Server />
		{:else if $ACTIVE_PAGE == 'Chat Staff'}
			<StaffChat />
		{:else if $ACTIVE_PAGE == 'Jogadores'}
			<Players />
		{:else if $ACTIVE_PAGE == 'Grupos'}
			<Groups />
		{:else if $ACTIVE_PAGE == 'Comandos'}
			<Commands />
		{:else if $ACTIVE_PAGE == 'Itens'}
			<Items />
		{:else if $ACTIVE_PAGE == 'Veículos'}
			<Vehicles />
		{:else if $ACTIVE_PAGE == 'Créditos'}
			<Credits />
		{:else if $ACTIVE_PAGE == 'Dashboard'}
			<Dashboard />
		{:else if $ACTIVE_PAGE == 'Banimentos'}
			<Bans />
		{/if}
	</div>
</div>
